//
//  AddLocation.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddLocation.h"
#import "LocAnnotation.h"
#import "ReportedLocationAnnotation.h"
#import "ReportedLocationAnnotationView.h"
#import "Model.h"
#import "Event.h"
#import "Controller.h"
#import "ReportedLocation.h"
#import "Participant.h"
#import "Contact.h"
#import "ABContactsHelper.h"
#import "ABContact.h"

typedef enum {
	SearchAndDetailStateSearch = 0,
	SearchAndDetailStateDetail,
    SearchAndDetailStateBoth,
	SearchAndDetailStateNone,
    SearchAndDetailStateEditName
} SearchAndDetailState;

@interface AddLocation ()
- (void)setupMapView;
- (void)zoomToFitMapAnnotationsAndSkipPreviouslyAdded:(BOOL)skipAdded;
- (void)setupInfoView;
- (void)setupSearchBar;
- (void)removeAnnotations:(MKMapView *)theMapView includingSaved:(Boolean)includeSaved;
- (void)showSearchBar:(Boolean)toShow withAnimationDelay:(float)delay;
- (void)doGoToSearchAndDetailState:(SearchAndDetailState)state;
- (void)handleEndSearchPress:(id)sender;
- (void)resignKeyboardAndRemoveModalCover:(id)target;
- (void)addSearchResultAnnotations;
- (void)addSavedLocationAnnotations;
- (void)updateSavedLocationsAnnotationsStateEnabled:(Boolean)enabled;
- (void)addOrUpdateUserLocationAnnotations;
- (void)showUserActionSheetForUser:(Participant *)part;
- (void)presentMailModalViewController;
- (void)showKeyboardResignerAndEnable:(BOOL)enabled;
- (void)hideKeyboardResigner;
- (void)getDirectionsForLocation:(Location *)loc;
- (void)callLocation:(Location *)loc;
- (void)doSecondaryAddressSearch;
- (void)beginLocationSearchWithSearchString:(NSString *)searchString andRemovePreviousResults:(BOOL)removePreviousResults;
- (BOOL)locationCollection:(NSMutableArray *)collection containsLocation:(Location *)location;
- (void)doShowSearchAgainButton:(BOOL)doShow;
- (void)enableSearchCategoryTable;
- (void)disableSearchCategoryTable;
- (void)showAlertWithCode:(int)code;
- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part;
- (void)reportTimerTick;
@end

@implementation AddLocation

@synthesize selectedSearchLocationKey, selectedLocationKey;

#pragma mark - Initializers
- (id)initWithLocationOpen:(NSString *)locId
{
    selectedLocationId = [locId retain];
    self = [self initWithState:AddLocationInitStateFromExistingEventSelectedLocation];
    return self;
}

- (id)initWithState:(AddLocationInitState)state
{
    self = [super init];
    if (self)
    {
        initState = state;
    }
    return self;
}

-(id) init {
    self = [self initWithState:AddLocationInitStateFromExistingEvent];
    return self;
}

#pragma mark - Show or Hide search again handler
- (void)doShowSearchAgainButton:(BOOL)doShow
{
    if (doShow)
    {
        searchAgainButtonShowing = YES;
        [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateSearchAgain withTarget:self];
    }
    else
    {
        searchAgainButtonShowing = NO;
        [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
    }
}

#pragma mark - SearchAndDetailState handler
- (void)doGoToSearchAndDetailState:(SearchAndDetailState)state
{
    int searchOffState = (initState == AddLocationInitStateFromExistingEventSelectedLocation)?(NavStateLocationAddSearchOffTab):(NavStateLocationAddSearchOff);
    int searchOnState = (initState == AddLocationInitStateFromExistingEventSelectedLocation)?(NavStateLocationAddSearchOnTab):(NavStateLocationAddSearchOn);
    
    if ( [Model sharedInstance].currentEvent.currentEventState >= EventStateDecided && initState != AddLocationInitStateFromNewEvent ) searchOffState = NavStateLocationDecided;
    
    switch (state) {
        case SearchAndDetailStateNone:
            if (searchBarShowing) {
                [searchBar resetField];
                [self showSearchBar:false withAnimationDelay:0];
            }
            [locWidget setState:WidgetStateClosed withDelay:0];
            [[NavigationSetter sharedInstance] setNavState:searchOffState withTarget:self];
            break;
        case SearchAndDetailStateDetail:
            if (searchBarShowing) {
                [searchBar resetField];
                [self showSearchBar:false withAnimationDelay:0];
                [locWidget setState:WidgetStateOpen withDelay:0.00f];
            } else {
                [locWidget setState:WidgetStateOpen withDelay:0];
            }
            [[NavigationSetter sharedInstance] setNavState:searchOffState withTarget:self];
            break;
        case SearchAndDetailStateSearch:
            if (locWidget.iAmShowing) {
                [locWidget setState:WidgetStateClosed withDelay:0];
                [self showSearchBar:true withAnimationDelay:0.00f];
            } else if (!searchBarShowing) {
                [self showSearchBar:true withAnimationDelay:0];
            }
            [[NavigationSetter sharedInstance] setNavState:searchOnState withTarget:self];
            break;
        case SearchAndDetailStateBoth:
            [self showSearchBar:true withAnimationDelay:0];
            [locWidget setState:WidgetStateOpenWithSearch withDelay:0];
            [[NavigationSetter sharedInstance] setNavState:searchOnState withTarget:self];
            break;
        case SearchAndDetailStateEditName:
            [self showSearchBar:false withAnimationDelay:0];
            [locWidget setState:WidgetStateOpen withDelay:0.00f];
            [[NavigationSetter sharedInstance] setNavState:NavStateLocationNameEdit withTarget:self];
            // nav state
            break;
        default:
            break;
    }
}


#pragma mark - UI setup
- (void)setupMapView
{
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    mapView = [[MKMapView alloc] initWithFrame:rect];
    mapView.delegate = self;
    mapView.showsUserLocation = true;
    [self.view addSubview:mapView];
    [mapView release];
    
    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
        if (!searchAgainButtonShowing && continueToSearchEnabled)
        {
            [self doShowSearchAgainButton:YES];
        }
    };
    [mapView addGestureRecognizer:tapInterceptor];
}

- (void)setupInfoView
{
    CGRect      bounds = [UIScreen mainScreen].bounds;
    CGRect      rect = CGRectMake(0, -50, bounds.size.width, 5);
    locWidget = [[LocationDetailWidget alloc] initWithFrame:rect];
    locWidget.delegate = self;
    [self.view addSubview:locWidget];
    [locWidget release];
}
- (void)setupSearchBar
{
    CGRect searchFrame = CGRectMake(0, -41.0, 320.0, 41.0);
    searchBar = [[SubViewSearchBar alloc] initWithFrame:searchFrame];
    searchBar.delegate = self;
    searchBar.placeholderText = @"Search for a location";
    [self.view addSubview:searchBar];
    [searchBar release];
}

- (void)addOrUpdateUserLocationAnnotations
{
    Model *model = [Model sharedInstance];
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getReportedLocations] count];
//    NSLog(@"ReportedLocations count: %d", searchResults);
    BOOL shouldZoom = true;
    
    for(int i = 0; i < searchResults; i++)
    {
        ReportedLocation *loc = (ReportedLocation *)[[detail getReportedLocations] objectAtIndex:i];
        Participant *p = [model getParticipantWithEmail:loc.userId fromEventWithId:detail.eventId];
        
        if ([p.email isEqualToString:model.userEmail]) continue; // skip the user if it is you
        
        ReportedLocationAnnotation *addedAlready = [self getReportedLocationAnnotationForUser:p];
        
        if (addedAlready)
        {
            //NSLog(@"%@ addedAlready", p.email);
            shouldZoom = false;
            [addedAlready setCoordinate:loc.coordinate];
        }
        else
        {
            ReportedLocationAnnotation *placemark = [[[ReportedLocationAnnotation alloc] initWithCoordinate:loc.coordinate andParticipant:p] autorelease];
            [mapView addAnnotation:placemark];
        }
    }
    if (searchResults > 0 && shouldZoom) {
        userLocationFound = true; // cancels zoom to user location
        [self zoomToFitMapAnnotationsAndSkipPreviouslyAdded:NO];
    }
}

- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part
{
    for (id <MKAnnotation> annotation in mapView.annotations) 
    {
        if ([annotation isKindOfClass:[ReportedLocationAnnotation class]]) {
            ReportedLocationAnnotation *anno = annotation;
            if ([anno.participant.email isEqualToString:part.email]) return anno;
        }
    }
    return nil;
}

- (void)addSavedLocationAnnotations
{
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getLocations] count];
    for(int i = 0; i < searchResults; i++)
    {
        Location *loc = (Location *)[[detail getLocations] objectAtIndex:i];
        
        Boolean iLikedLocation = [detail loginUserDidVoteForLocationWithId:loc.locationId];
        LocAnnoStateType type;
        if (detail.currentEventState >= EventStateDecided && [detail.topLocationId isEqualToString:loc.locationId] && [Model sharedInstance].currentAppState != AppStateCreateEvent) //AppStateCreateEvent used during creation because model currentEvent may point to something else
        {
            type = LocAnnoStateTypeDecided;
        }
        else
        {
            if (iLikedLocation)
            {
                type = LocAnnoStateTypeLiked;
            }
            else
            {
                type = LocAnnoStateTypePlace;
            }
        }
        LocAnnoSelectedState state = LocAnnoSelectedStateDefault;
        
        LocAnnotation *mark = [[[LocAnnotation alloc] initWithLocation:loc withStateType:type andSelectedState:state] autorelease];
        
        mark.hasDeal = loc.hasDeal;
        mark.uuid = loc.g_id;
        mark.iAddedLocation = loc.addedByMe;
        [mapView addAnnotation:mark];
        
        if (selectedLocationId)
        {
            if ([loc.locationId isEqualToString:selectedLocationId])
            {
                [mapView selectAnnotation:mark animated:NO];
            }
        }
        
    }
    if (searchResults > 0) {
        userLocationFound = true; // cancels zoom to user location
        [self zoomToFitMapAnnotationsAndSkipPreviouslyAdded:NO];
    }
    selectedLocationId = nil;
}
- (void)updateSavedLocationsAnnotationsStateEnabled:(Boolean)enabled
{
    for (id annotation in mapView.annotations) {
        NSArray *selectedAnnotations = [mapView selectedAnnotations];
		if ([annotation isKindOfClass:[LocAnnotation class]]) {
            LocAnnotation *anno = annotation; 
            if (anno.isSavedLocation && !anno.isNewlyAdded)  // we dont want to affect search result annotations
            {
                // deselect anno that is marked to enable 
                if ([selectedAnnotations containsObject:anno] && enabled && [anno getSelectedState] == LocAnnoSelectedStateSelected)
                {
                    [mapView deselectAnnotation:anno animated:NO];
                }
                
                [anno setSelectedState:(enabled) ? LocAnnoSelectedStateDefault : LocAnnoSelectedStateDisabled];
                MKAnnotationView *view = [mapView viewForAnnotation:anno];
                view.enabled = enabled;
                view.image = [anno imageForCurrentState];
            }
		}
	}
}

#pragma mark - UISearchBar methods
- (void)showSearchBar:(Boolean)toShow withAnimationDelay:(float)delay
{
    searchBarShowing = toShow;
    CGRect rectIn = CGRectMake(0, 0, searchBar.bounds.size.width, searchBar.bounds.size.height);
    CGRect rectOut = CGRectMake(0, -searchBar.bounds.size.height, searchBar.bounds.size.width, searchBar.bounds.size.height);
    [UIView animateWithDuration:0.30f 
                          delay:delay 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         [searchBar setFrame:(toShow)?(rectIn):(rectOut)];
                     }
                     completion:NULL];
    if (!toShow) [searchBar resetField];
}

- (void)beginLocationSearchWithSearchString:(NSString *)searchString andRemovePreviousResults:(BOOL)removePreviousResults
{
    searchBar.text = searchString;
    [searchBar showNetworkActivity:YES];
    if (removePreviousResults)
    {
        [self resignKeyboardAndRemoveModalCover:self];
        [self removeAnnotations:mapView includingSaved:false];
//        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    }

    Location *searchLocation = [[[Location alloc] init] autorelease];
    searchLocation.latitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.latitude];
    searchLocation.longitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.longitude];
    searchLocation.name = searchString;
    
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
    CLLocation * newLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude+region.span.latitudeDelta longitude:centerCoordinate.longitude] autorelease];
    CLLocation * centerLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude] autorelease];
    int radius = [centerLocation distanceFromLocation:newLocation];
    int radiusKilo = ceil(radius/1000);
    /* trying out simple geo
     if (googlePlacesFetchId) [googlePlacesFetchId release];
     googlePlacesFetchId = [[[Controller sharedInstance] searchGooglePlacesForLocation:searchLocation withRadius:radius] retain];
     */
    
    if (simpleGeoFetchId) [simpleGeoFetchId release];
    simpleGeoFetchId = [[[Controller sharedInstance] searchSimpleGeoForLocation:searchLocation withRadius:radiusKilo] retain];
    
    if (pendingSearchString) [pendingSearchString release];
    pendingSearchString = [searchBar.text retain];
    
    if (pendingSearchCategory) [pendingSearchCategory release];
    pendingSearchCategory = nil;
}

- (void)beginLocationSearchWithCategory:(SearchCategory *)searchCategory andRemovePreviousResults:(BOOL)removePreviousResults
{
    searchBar.text = searchCategory.search_category;
    [searchBar showNetworkActivity:YES];
    if (removePreviousResults)
    {
        [self resignKeyboardAndRemoveModalCover:self];
        [self removeAnnotations:mapView includingSaved:false];
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    }
    Location *searchLocation = [[[Location alloc] init] autorelease];
    searchLocation.latitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.latitude];
    searchLocation.longitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.longitude];
    
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
    CLLocation * newLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude+region.span.latitudeDelta longitude:centerCoordinate.longitude] autorelease];
    CLLocation * centerLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude] autorelease];
    int radius = [centerLocation distanceFromLocation:newLocation];
    int radiusKilo = ceil(radius/1000);

    if (simpleGeoFetchId) [simpleGeoFetchId release];
    simpleGeoFetchId = [[[Controller sharedInstance] searchSimpleGeoForLocation:searchLocation withRadius:radiusKilo andCategory:searchCategory] retain];
    
    if (pendingSearchString) [pendingSearchString release];
    pendingSearchString = nil;
    
    if (pendingSearchCategory) [pendingSearchCategory release];
    pendingSearchCategory = [searchCategory retain];
}

#pragma mark - SubViewSearchBarDelegate methods
- (void)searchBarReturnButtonClicked:(SubViewSearchBar *)theSearchBar
{
    if ([theSearchBar.text length] == 0) return;
    NSLog(@"SEARCH STRING: %@", theSearchBar.text);
    NSString *searchString = [[NSString alloc] initWithString:theSearchBar.text];
    [self beginLocationSearchWithSearchString:theSearchBar.text andRemovePreviousResults:YES];
    [searchString release];
}
- (void)searchBarCancelButtonClicked:(SubViewSearchBar *)theSearchBar
{
    continueToSearchEnabled = false;
    [self doShowSearchAgainButton:NO];
    [self hideKeyboardResigner];
    //[self handleEndSearchPress:self];
}
- (BOOL)searchBarShouldBeginEditing:(SubViewSearchBar *)theSearchBar
{
    continueToSearchEnabled = false;
    [self doShowSearchAgainButton:NO];
    [self showKeyboardResignerAndEnable:YES];
    [self enableSearchCategoryTable];
    return YES;
}
- (void)searchBar:(SubViewSearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    //categoryTable.hidden = [searchText length] == 0;
    [categoryTable updateSearchContentsWithSearchString:searchText];
}
- (void)searchBarBookmarkButtonClicked:(SubViewSearchBar *)theSearchBar
{
    NSArray *allContacts = [[ABContactsHelper contacts] retain];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"addressArrayCount > 0"];
    [allContactsWithAddress release];
    allContactsWithAddress = [[allContacts filteredArrayUsingPredicate:pred] retain];
    [allContacts release];
    [[ViewController sharedInstance] navigateToAddressBookLocations:self];
}
- (void)searchBarClearButtonClicked:(SubViewSearchBar *)theSearchBar
{
    continueToSearchEnabled = false;
    [self doShowSearchAgainButton:NO];
    [categoryTable updateSearchContentsWithSearchString:@""];
}

#pragma mark - SearchCategoryTable
- (void)enableSearchCategoryTable
{
    CGRect viewRect = CGRectMake(0, 40, self.view.bounds.size.width, 160);
    if (categoryTable == nil) categoryTable = [[[SearchCategoryTable alloc] initWithFrame:viewRect] autorelease];
    categoryTable.delegate = self;
    [self.view addSubview:categoryTable];
}
- (void)disableSearchCategoryTable
{
    if (categoryTable != nil) [categoryTable removeFromSuperview];
    categoryTable = nil;
}

#pragma mark - SearchCategoryTableDelegate
- (void)categorySelected:(SearchCategory *)category
{
    [self beginLocationSearchWithCategory:category andRemovePreviousResults:YES];
}

#pragma mark - keyboard model resigner helper methods
- (void)showKeyboardResignerAndEnable:(BOOL)enabled
{
    if (keyboardResigner != nil) [keyboardResigner removeFromSuperview];
    keyboardResigner = nil;
    
    CGRect rect = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height);
    keyboardResigner = [[[UIButton alloc] initWithFrame:rect] autorelease];
    keyboardResigner.frame = rect;
    [keyboardResigner setBackgroundColor:[UIColor blackColor]];
    [keyboardResigner setAlpha:0.5f];
    if (enabled) [keyboardResigner addTarget:self action:@selector(resignKeyboardAndRemoveModalCover:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keyboardResigner];
}
- (void)hideKeyboardResigner
{
    if (keyboardResigner != nil) 
    {
        [keyboardResigner removeTarget:self action:@selector(resignKeyboardAndRemoveModalCover:) forControlEvents:UIControlEventTouchUpInside];
        [keyboardResigner removeFromSuperview];
    }
    keyboardResigner = nil;
}

#pragma mark - UISearchBar helper methods
- (void)resignKeyboardAndRemoveModalCover:(id)target
{
    [self disableSearchCategoryTable];
    [searchBar resignFirstResponder];
    [keyboardResigner removeFromSuperview];
    keyboardResigner = nil;
}

- (void)addSearchResultAnnotations
{
    BOOL newLocationDetected = NO;
    NSEnumerator *enumerator = [savedSearchResultsDict keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        Location *place = [savedSearchResultsDict objectForKey:key];
        
        if (!place.hasBeenAddedToMapPreviously)
        {
            newLocationDetected = YES;
            place.hasBeenAddedToMapPreviously = YES;
            LocAnnotation *mark = [[LocAnnotation alloc] initWithLocation:place withStateType:LocAnnoStateTypeSearch andSelectedState:LocAnnoSelectedStateDefault];
            mark.uuid = key;
            mark.iAddedLocation = YES;
            mark.scheduledForZoom = YES;
            [mapView addAnnotation:mark];
            
            [mark release];
        }
    }
    
    if (newLocationDetected)    
    {
        [self zoomToFitMapAnnotationsAndSkipPreviouslyAdded:YES];
        [self updateSavedLocationsAnnotationsStateEnabled:false];
    }
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (userLocationFound) return;
    MKCoordinateRegion region;
    region.center.latitude = userLocation.coordinate.latitude;
    region.center.longitude = userLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.101;
    region.span.longitudeDelta = 0.101;
    [theMapView setRegion:region animated:NO];
    theMapView.showsUserLocation = true;
    userLocationFound = true;
}
- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[LocAnnotation class]]) {
        
        LocAnnotation *placeMark = view.annotation;
        [placeMark setSelectedState:LocAnnoSelectedStateSelected];
        view.image = [placeMark imageForCurrentState];
//        selectedSearchLocationIndex = -1;
//        selectedLocationIndex = -1;
        
        self.selectedLocationKey = nil;
        self.selectedSearchLocationKey = nil;
        
        if (placeMark.isSavedLocation)
        {
//            selectedLocationIndex = placeMark.dataLocationIndex;
            self.selectedLocationKey = placeMark.uuid;
        }
        else
        {
//            selectedSearchLocationIndex = placeMark.dataLocationIndex;
            self.selectedSearchLocationKey = placeMark.uuid;
        }
        [locWidget updateInfoViewWithLocationAnnotation:placeMark];
        [self doGoToSearchAndDetailState:(searchBarShowing)?(SearchAndDetailStateBoth):(SearchAndDetailStateDetail)];
        annotationOpenCount++;
    }
    else if([view.annotation isKindOfClass:[ReportedLocationAnnotation class]])
    {
        ReportedLocationAnnotation *placeMark = view.annotation;
        ReportedLocationAnnotationView *myView = (ReportedLocationAnnotationView *)view;
        [myView setCurrentState:ReportedLocationAnnoSelectedStateSelected];
        
        [self doGoToSearchAndDetailState:(searchBarShowing)?(SearchAndDetailStateBoth):(SearchAndDetailStateDetail)];
        [locWidget updateInfoViewWithReportedLocationAnnotation:placeMark];
        annotationOpenCount++;
    }
    //NSLog(@"annotationOpenCount %d", annotationOpenCount);
}

- (void)mapView:(MKMapView *)theMapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[LocAnnotation class]]) {
        LocAnnotation *placeMark = view.annotation;
        if (placeMark.isEnabled) {
            [placeMark setSelectedState:LocAnnoSelectedStateDefault];
            view.image = [placeMark imageForCurrentState];
        }
        annotationOpenCount--;
        if (annotationOpenCount <= 0)
        {
            annotationOpenCount = 0;
//            selectedSearchLocationIndex = -1;
//            selectedLocationIndex = -1;
            
            self.selectedLocationKey = nil;
            self.selectedSearchLocationKey = nil;
            
            [self doGoToSearchAndDetailState:(searchBarShowing)?(SearchAndDetailStateSearch):(SearchAndDetailStateNone)];
        }
    }
    else if([view.annotation isKindOfClass:[ReportedLocationAnnotation class]])
    {
        ReportedLocationAnnotationView *myView = (ReportedLocationAnnotationView *)view;
        [myView setCurrentState:ReportedLocationAnnoSelectedStateDefault];
        annotationOpenCount--;
        if (annotationOpenCount <= 0)
        {
            annotationOpenCount = 0;
//            selectedSearchLocationIndex = -1;
//            selectedLocationIndex = -1;
            
            self.selectedLocationKey = nil;
            self.selectedSearchLocationKey = nil;
            
            [self doGoToSearchAndDetailState:(searchBarShowing)?(SearchAndDetailStateSearch):(SearchAndDetailStateNone)];
        }
    }
    //NSLog(@"annotationOpenCount %d", annotationOpenCount);
}

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) 
    {
		return nil;
	}
    NSString* annotationIdentifier = nil;
	if ([annotation isKindOfClass:[LocAnnotation class]])
    {
        LocAnnotation *placeMark = (LocAnnotation *)annotation;
        // try to dequeue an existing pin view first
        annotationIdentifier = @"LocAnnotationIdentifier";
        MKAnnotationView* pinView = (MKAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];            
            pinView.canShowCallout = NO;
		}
        pinView.enabled = placeMark.isEnabled;
        pinView.image = [placeMark imageForCurrentState];
        return pinView;
    } 
    else if ([annotation isKindOfClass:[ReportedLocationAnnotation class]])
    {
        ReportedLocationAnnotation *placeMark = (ReportedLocationAnnotation *)annotation;
        annotationIdentifier = @"ReportedLocationAnnotationIdentifier";
        ReportedLocationAnnotationView *pinView = (ReportedLocationAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[ReportedLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
            pinView.canShowCallout = NO;
		}
//        [pinView setView:[placeMark imageViewForCurrentState:ReportedLocationAnnoSelectedStateDefault]];
        [pinView setCurrentState:ReportedLocationAnnoSelectedStateDefault andParticipantImageURL:placeMark.participant.avatarURL];
        return pinView;
    }
	return nil;
}

- (void) mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views {
    if ([searchBar respondsToSelector:@selector(showNetworkActivity:)]) [searchBar showNetworkActivity:NO];
   /*
    int delayIndex = 0;
    CGRect visibleRect = [mapView annotationVisibleRect];
    for (MKAnnotationView *view in views) {
        CGRect endFrame = view.frame;
        CGRect startFrame = endFrame; startFrame.origin.y = visibleRect.origin.y - startFrame.size.height;
        view.frame = startFrame;
        view.alpha = 0;
//        [view.superview bringSubviewToFront:view];
        [UIView animateWithDuration:0.20f 
                              delay:delayIndex * 0.03f 
                            options:(UIViewAnimationOptionTransitionNone|UIViewAnimationOptionCurveEaseOut) 
                         animations:^(void){
                             view.frame = endFrame;
                             view.alpha = 1;
                         }
                         completion:NULL];
        delayIndex++;
    }
     */
}

- (void)removeAnnotations:(MKMapView *)theMapView includingSaved:(Boolean)includeSaved
{
	// remove observers and annotation
    currentState = AddLocationStateView;
//	selectedSearchLocationIndex = -1;
//    selectedLocationIndex = -1;
    
    self.selectedLocationKey = nil;
    self.selectedSearchLocationKey = nil;
    
	NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:mapView.annotations.count];
	for (id annotation in mapView.annotations) {
		if ([annotation isKindOfClass:[LocAnnotation class]]) {
            LocAnnotation *anno = annotation;
			if (!anno.isSavedLocation || includeSaved)   [toRemove addObject:annotation];
		}
	}
	[mapView removeAnnotations:toRemove];
}

- (void)zoomToFitMapAnnotationsAndSkipPreviouslyAdded:(BOOL)skipAdded
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        if (mapView.userLocation == annotation) continue;
        
        if (skipAdded)
        {
            if (![annotation isKindOfClass:[LocAnnotation class]]) continue;
            LocAnnotation *loc = (LocAnnotation *)annotation;
            if (!loc.scheduledForZoom) 
            {
                continue;
            }
            loc.scheduledForZoom = NO;
        }
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
                        
            double width = 81920;
            double height = 117760;
            
            MKMapRect r = MKMapRectMake(annotationPoint.x - width * 0.5, annotationPoint.y - height * 0.5, width, height);
            
            zoomRect = r;
            
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
//    zoomRect.size.width *= 1.05;
//    zoomRect.size.height *= 1.05;

    [mapView setVisibleMapRect:zoomRect animated:YES];
}



#pragma mark - LocationDetailWidgetDelegate methods
- (void)addButtonPressed
{
   // Location *aPlace = [savedSearchResults objectAtIndex:selectedSearchLocationIndex];
    
    Location *aPlace = [savedSearchResultsDict objectForKey:self.selectedSearchLocationKey];
    
	Location *location = [[Model sharedInstance] createNewLocationWithPlace:aPlace];
    
    NSString *uuid = location.g_id; //[location stringWithUUID];
    //location.uuid = uuid;
    
	Controller *controller = [Controller sharedInstance];
    NSArray *locations = [NSArray arrayWithObject:location];
    [controller addOrUpdateLocations:locations isAnUpdate:NO];
    
    LocAnnoStateType type = LocAnnoStateTypePlace;
    LocAnnoSelectedState state = LocAnnoSelectedStateSelected;
    
    LocAnnotation *placemark = [[mapView selectedAnnotations]objectAtIndex:0];
    [placemark setStateType:type];
    [placemark setSelectedState:state];
    placemark.isNewlyAdded = true;
    placemark.uuid = uuid;
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    if ([Model sharedInstance].currentAppState == AppStateCreateEvent || [Model sharedInstance].isInTrial) {
//        [locWidget updateInfoViewWithCorrectButtonState:ActionStateLike];
        [locWidget updateInfoViewWithCorrectButtonState:ActionStateUnlike];
        LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
        [placemark setStateType:LocAnnoStateTypeLiked];
        [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    } else {
        [locWidget updateInfoViewWithCorrectButtonState:ActionStateSpinning];
        mapView.userInteractionEnabled = NO;
        isAddingLocation = YES;
    }
}

- (void)likeButtonPressed
{
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
    [placemark setStateType:LocAnnoStateTypeLiked];
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    
    Event *detail = [Model sharedInstance].currentEvent;
    Location *loc = [detail getLocationWithUUID:placemark.uuid];
    
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
    [locWidget updateInfoViewWithCorrectButtonState:ActionStateUnlike];
}
- (void)unlikeButtonPressed
{
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
    [placemark setStateType:LocAnnoStateTypePlace];
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    
    Event *detail = [Model sharedInstance].currentEvent;
    Location *loc = [detail getLocationWithUUID:placemark.uuid];
    
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
    [locWidget updateInfoViewWithCorrectButtonState:ActionStateLike];
}

- (void)winnerButtonPressed
{
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];    
    Event *detail = [Model sharedInstance].currentEvent;
    winningLocationSelected = [detail getLocationWithUUID:placemark.uuid];
    
    //BOOL hasPhoneCapability = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:123"]];
    NSString *phoneButtonCopy = ([winningLocationSelected.formatted_phone_number length] > 0) ? [NSString stringWithFormat:@"Call %@", winningLocationSelected.formatted_phone_number] : nil;
    
    UIActionSheet *userOptions;
    if (phoneButtonCopy != nil)
    {
        locationActionSheetState = LocationActionSheetStateWinnerWithPhone;
        userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:phoneButtonCopy, @"Get Directions", nil];
    }
    else
    {
        locationActionSheetState = LocationActionSheetStateWinnerWithoutPhone;
        userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get Directions", nil];
    }
    
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

- (void)editNameButtonPressed
{
    [self doGoToSearchAndDetailState:SearchAndDetailStateEditName];
    [locWidget transitionToEditNameState];
    [self showKeyboardResignerAndEnable:NO];
}

- (void)editNameSubmittedWithNewName:(NSString *)name
{
    [self hideKeyboardResigner];
    [self doGoToSearchAndDetailState:SearchAndDetailStateBoth];
    NSLog(@"Submit new name for location: %@", name);
    
    Model *model = [Model sharedInstance];
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
    Event *detail = model.currentEvent;
    Location *loc = [detail getLocationWithUUID:placemark.uuid];
//    NSLog(@"loc.uuid = %@ : loc.id = %@ : pm.uuid = %@", loc.uuid, loc.locationId, placemark.uuid);
    if (model.currentAppState == AppStateCreateEvent || loc == nil) // case 1 - create mode OR case 2 - location unsaved
    {
//        Location *aPlace = [savedSearchResults objectAtIndex:selectedSearchLocationIndex];
        
        Location *aPlace = [savedSearchResultsDict objectForKey:self.selectedSearchLocationKey];
        
        aPlace.name = name;
        placemark.title = name;
        if (loc) loc.name = name;
    }
    else // case 3 - location saved
    {
        loc.name = name;
        NSArray *locations = [NSArray arrayWithObject:loc];
        [[Controller sharedInstance] addOrUpdateLocations:locations isAnUpdate:YES];
    }
    [locWidget setState:WidgetStateOpenWithSearch withDelay:0];
}

#pragma mark - Navigation handlers
- (void)handleSearchAgainPress:(id)sender
{
    if (pendingSearchString)
    {
        NSLog(@"pendingSearchString exists, doing beginLocationSearchWithSearchString for: %@", pendingSearchString);
        [self beginLocationSearchWithSearchString:pendingSearchString andRemovePreviousResults:NO];
    }
    else if (pendingSearchCategory)
    {
        NSLog(@"pendingSearchCategory exists, doing beginLocationSearchWithCategory for: %@", pendingSearchCategory.search_category);
        [self beginLocationSearchWithCategory:pendingSearchCategory andRemovePreviousResults:NO];
    }
    [self doShowSearchAgainButton:NO];
}
- (void)handleLeftActionPress:(id)sender // handler for edit location name CANCEL
{
    [self doGoToSearchAndDetailState:SearchAndDetailStateBoth];
    [locWidget recoverFromEditNameState];
    [locWidget setState:WidgetStateOpenWithSearch withDelay:0];
    [self hideKeyboardResigner];
}
- (void)handleRightActionPress:(id)sender // handler for edit location name DONE
{
    [locWidget handleEditingNameSubmit];
}
/*
- (void)handleMorePress:(id)sender
{
    NSLog(@"handleMorePress, TODO");
}
*/
- (void)handleBackPress:(id)sender
{
    tapInterceptor.touchesMovedCallback = nil;
    [mapView removeGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
    
    [[ViewController sharedInstance] goBack];
}
- (void)handleSearchPress:(id)sender
{
    if (locWidget.iAmShowing) {
        [self doGoToSearchAndDetailState:SearchAndDetailStateBoth];
    }
    else
    {
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    }
}
- (void)handleDecidedPress:(id)sender
{
//    NSLog(@"handleDecidedPress");
    if (!isAddingLocation) {
        NSMutableArray *enabledList = [[[NSMutableArray alloc] init] autorelease];
        int winningAnnotationIndex = -1;
        for(LocAnnotation* annotation in mapView.annotations)
        {
            if ((MKUserLocation *)annotation == mapView.userLocation) continue; // dont take user location into account
            if (annotation.isEnabled) {
                [enabledList addObject:annotation];
                Boolean isSelected = [annotation getSelectedState] == LocAnnoSelectedStateSelected;
                Boolean isWinningAnnotation = [annotation getStateType] == LocAnnoStateTypeDecided;
                if (isSelected && isWinningAnnotation) return; // selected annotation is already the winning location
                if (isWinningAnnotation) winningAnnotationIndex = [enabledList count] -1;
                if (isSelected) {
                    [mapView deselectAnnotation:annotation animated:NO];
                }
            }
        }
        if (winningAnnotationIndex > -1)
        {
            LocAnnotation* winningAnno = [enabledList objectAtIndex:winningAnnotationIndex];
            [mapView selectAnnotation:winningAnno animated:NO];
        }
    }
}
- (void)handleEndSearchPress:(id)sender
{
    if (!isAddingLocation) {
        continueToSearchEnabled = false;
        [self doShowSearchAgainButton:NO];
        [self hideKeyboardResigner];
        [self disableSearchCategoryTable];
        if (locWidget.iAmShowing && currentState == AddLocationStateView) {
            [self doGoToSearchAndDetailState:SearchAndDetailStateDetail];
            return;
        }
        else if(locWidget.iAmShowing && currentState == AddLocationStateSearch)
        {
            NSArray *selectedAnnotations = [mapView selectedAnnotations];
            if ([selectedAnnotations count] > 0) {
                LocAnnotation *anno = [selectedAnnotations objectAtIndex:0];
                if (anno.isSavedLocation)
                {
                    [self removeAnnotations:mapView includingSaved:false];
                    [self updateSavedLocationsAnnotationsStateEnabled:true];
                    [self doGoToSearchAndDetailState:SearchAndDetailStateDetail];
                    currentState = AddLocationStateView;
                    return;
                }
            }
        }
        [self doGoToSearchAndDetailState:SearchAndDetailStateNone];
        [self updateSavedLocationsAnnotationsStateEnabled:true];
        [self removeAnnotations:mapView includingSaved:false];
    }
}
- (void)handlePrevPress:(id)sender
{
//	NSLog(@"prev clicked");
    if (!isAddingLocation) {
        NSMutableArray *enabledList = [[[NSMutableArray alloc] init] autorelease];
        int selectedAnnotationIndex = -1;
        for(LocAnnotation* annotation in mapView.annotations)
        {
            if ((MKUserLocation *)annotation == mapView.userLocation) continue; // dont take user location into account
            if (annotation.isEnabled) {
                [enabledList addObject:annotation];
                Boolean isSelected = [annotation getSelectedState] == LocAnnoSelectedStateSelected;
                if (isSelected) {
                    selectedAnnotationIndex = [enabledList count] -1;
                    [mapView deselectAnnotation:annotation animated:NO];
                }
            }
        }
        if ( [enabledList count] == 0 ) return;
        if (selectedAnnotationIndex == 0) selectedAnnotationIndex = [enabledList count];
        if (selectedAnnotationIndex > -1) {
            int nextIndex = selectedAnnotationIndex - 1;
            LocAnnotation* nextSelectedAnno = [enabledList objectAtIndex:nextIndex];
            [mapView selectAnnotation:nextSelectedAnno animated:NO];
        } else {
            [mapView selectAnnotation:[enabledList objectAtIndex:0] animated:NO];
        }
    }
}
- (void)handleNextPress:(id)sender
{
//	NSLog(@"next clicked");
    if (!isAddingLocation) {
        NSMutableArray *enabledList = [[[NSMutableArray alloc] init] autorelease];
        int selectedAnnotationIndex = -1;
        for(LocAnnotation* annotation in mapView.annotations)
        {
            if ((MKUserLocation *)annotation == mapView.userLocation) continue; // dont take user location into account
            if (annotation.isEnabled) {
                [enabledList addObject:annotation];
                Boolean isSelected = [annotation getSelectedState] == LocAnnoSelectedStateSelected;
                if (isSelected) {
                    selectedAnnotationIndex = [enabledList count] -1;
                    [mapView deselectAnnotation:annotation animated:NO];
                }
            }
        }
        if ( [enabledList count] == 0 ) return;
        if (selectedAnnotationIndex > -1) {
            int nextIndex = (selectedAnnotationIndex+1) % ([enabledList count]);
            LocAnnotation* nextSelectedAnno = [enabledList objectAtIndex:nextIndex];
            [mapView selectAnnotation:nextSelectedAnno animated:NO];
        } else {
            [mapView selectAnnotation:[enabledList objectAtIndex:0] animated:NO];
        }
    }
}


#pragma mark - Memory mgmt
- (void)dealloc
{
    NSLog(@"AddLocation dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_TEN_SECOND_TIMER_TICK object:nil];
    [self removeDataFetcherMessageListeners];
    [selectedLocationId release];
    [self removeAnnotations:mapView includingSaved:true];
    
    //[savedSearchResults release];
    [savedSearchResultsDict release];
    
    mapView.delegate = nil;
    searchBar.delegate = nil;
    if (participantSelectedOnMap) [participantSelectedOnMap release];
    [simpleGeoFetchId release];
    [googlePlacesFetchId release];
    [googleGeoFetchId release];
    [pendingSearchString release];
    [pendingSearchCategory release];
    [allContactsWithAddress release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
//    mapView.delegate = nil;
    mapView = nil;
    
//    searchBar.delegate = nil;
    searchBar = nil;
    
    userLocationFound = NO;
    isAddingLocation = NO;
    continueToSearchEnabled = NO;
    searchAgainButtonShowing = NO;
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)doSecondaryAddressSearch
{
    NSLog(@"No place results found, searching GEO for query: %@", pendingSearchString);
    if (googleGeoFetchId != nil) [googleGeoFetchId release];
    
    CLLocationCoordinate2D northEast, southWest;
    northEast = [mapView convertPoint:CGPointMake(mapView.frame.size.width, 0) toCoordinateFromView:mapView];
    southWest = [mapView convertPoint:CGPointMake(0, mapView.frame.size.height) toCoordinateFromView:mapView];
    
    googleGeoFetchId = [[[Controller sharedInstance] searchGoogleGeoForAddress:pendingSearchString northEastBounds:northEast southWestBounds:southWest] retain];
}

#pragma mark - DataFetcherMessageHandler

- (void)setUpDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherSuccessMessage:) name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherErrorMessage:) name:DATA_FETCHER_ERROR object:nil];
}

- (void)removeDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_ERROR object:nil];
}

- (BOOL)locationCollection:(NSMutableArray *)collection containsLocation:(Location *)location
{
    for (Location *loc in collection) {
        if ([loc.g_id isEqualToString: location.g_id]) return true;
    }
    return false;
}

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    
    switch (fetchType) {
        case DataFetchTypeAddNewLocationToEvent:
//            [locWidget updateInfoViewWithCorrectButtonState:ActionStateLike];
            
            [locWidget updateInfoViewWithCorrectButtonState:ActionStateUnlike];
            LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
            [placemark setStateType:LocAnnoStateTypeLiked];
            [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
            
            mapView.userInteractionEnabled = YES;
            isAddingLocation = NO;
            break;
        case DataFetchTypeUpdateLocationToEvent:
            // nothing to do here
            break;
        case DataFetchTypeGetReportedLocations:
            mapView.userInteractionEnabled = YES;
            [self addOrUpdateUserLocationAnnotations];
            break;
        case DataFetchTypeSearchSimpleGeo:
            if ( [fetchId isEqualToString:simpleGeoFetchId] )
            {
                
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                // if this is a continue, simply add to the result collection
                if (continueToSearchEnabled)
                {
                    // remove any existing added locations from results
                    NSMutableArray *toRemoveDupes = [[[NSMutableArray alloc] init] autorelease];
                    for (Location *obj in locations) {
                        //NSLog(@"location uid: %@", obj.g_id);
                        Location *detectedDupe = [savedSearchResultsDict objectForKey:obj.g_id];
                        if (detectedDupe)
                        {
                            //NSLog(@"Found duplicate: %@", detectedDupe.g_id);
                            [toRemoveDupes addObject:obj];
                        }
                    }
                    [locations removeObjectsInArray:toRemoveDupes];
                    //NSLog(@"Location count after removing dupes: %d", [locations count]);
                    for (Location *loc in locations) [savedSearchResultsDict setObject:loc forKey:loc.g_id];
                    
                }
                else
                {                    
                    [savedSearchResultsDict removeAllObjects];
                    for (Location *loc in locations) 
                    {
                        [savedSearchResultsDict setObject:loc forKey:loc.g_id];
                    }
                }
                
                // remove any existing saved locations from results
                NSMutableArray *toRemoveKeys = [[[NSMutableArray alloc] init] autorelease];
                
                NSEnumerator *enumerator = [savedSearchResultsDict keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    Location *loc = [savedSearchResultsDict objectForKey:key];
                    if ([[Model sharedInstance] locationExistsInCurrentEvent:loc]) [toRemoveKeys addObject:loc.g_id];
                }
                [savedSearchResultsDict removeObjectsForKeys:toRemoveKeys];
            }
            if ([savedSearchResultsDict count] == 0 && !continueToSearchEnabled && pendingSearchString != nil) 
            {
                [self doSecondaryAddressSearch];
            }
            else 
            {
                continueToSearchEnabled = true;
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
                [searchBar showNetworkActivity:NO];
            }
            
            break;
        case DataFetchTypeGooglePlaceSearch:
            /*
            if ( [fetchId isEqualToString:googlePlacesFetchId] )
            {
                [savedSearchResults release];
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                savedSearchResults = [[NSMutableArray alloc] initWithArray:locations];
                
                // remove any existing locations from results
                NSMutableArray *toRemove = [[[NSMutableArray alloc] init] autorelease];
                for (Location *obj in savedSearchResults) {
                    if ([[Model sharedInstance] locationExistsInCurrentEvent:obj]) [toRemove addObject:obj];
                }
                [savedSearchResults removeObjectsInArray:toRemove];
            }
            if ([savedSearchResults count] == 0 && !continueToSearchEnabled) 
            {
                [self doSecondaryAddressSearch];
            }
            else 
            {
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
            }
            */
            break;
        case DataFetchTypeGoogleAddressSearch:
            if ( [fetchId isEqualToString:googleGeoFetchId] )
            {
                [savedSearchResultsDict removeAllObjects];
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                
                for (Location *loc in locations) [savedSearchResultsDict setObject:loc forKey:loc.g_id];
                                
                // remove any existing locations from results
                NSMutableArray *toRemoveKeys = [[[NSMutableArray alloc] init] autorelease];

                NSEnumerator *enumerator = [savedSearchResultsDict keyEnumerator];
                id key;
                while ((key = [enumerator nextObject])) {
                    Location *loc = [savedSearchResultsDict objectForKey:key];
                    if ([[Model sharedInstance] locationExistsUsingLatLngInCurrentEvent:loc]) [toRemoveKeys addObject:loc.g_id];
                }
                
                [savedSearchResultsDict removeObjectsForKeys:toRemoveKeys];
                
            }
            if ([savedSearchResultsDict count] == 0) {
                NSLog(@"No address results found for query: %@, giving up", pendingSearchString);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
                [self updateSavedLocationsAnnotationsStateEnabled:true];
                currentState = AddLocationStateView;
                [searchBar showNetworkActivity:NO];
            }
            else 
            {
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
//                [searchBar showNetworkActivity:NO];
            }
//            [searchBar showNetworkActivity:NO];
            break;
        case DataFetchTypeAddVoteToLocation:
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            break;
        case DataFetchTypeRemoveVoteFromLocation:
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            break;
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeAddNewLocationToEvent:
            NSLog(@"Unhandled Error: %d", DataFetchTypeAddNewLocationToEvent);
            mapView.userInteractionEnabled = YES;
            isAddingLocation = NO;
            break;
        case DataFetchTypeGetReportedLocations:
            NSLog(@"Unhandled Error: %d", DataFetchTypeGetReportedLocations);
            mapView.userInteractionEnabled = YES;
            break;
        case DataFetchTypeSearchSimpleGeo:
            NSLog(@"Unhandled Error: %d", DataFetchTypeSearchSimpleGeo);
            [searchBar showNetworkActivity:NO];
            break;
        case DataFetchTypeGooglePlaceSearch:
            NSLog(@"Unhandled Error: %d", DataFetchTypeGooglePlaceSearch);
            [searchBar showNetworkActivity:NO];
            break;
        case DataFetchTypeGoogleAddressSearch:
            NSLog(@"Unhandled Error: %d", DataFetchTypeGoogleAddressSearch);
            [searchBar showNetworkActivity:NO];
            break;
        case DataFetchTypeAddVoteToLocation:
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            break;
        case DataFetchTypeRemoveVoteFromLocation:
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            break;
        default:
            break;
    }
    if (!alertViewShowing) [self showAlertWithCode:errorType];
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
    NSString *message = @"";
    
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"Not Connected To Internet", @"Error Status");
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"Request Timed Out, Try Again...", @"Error Status");
            break;
        default:
            message = NSLocalizedString(@"An Error Occurred, Try Again...", @"Error Status");
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
    alertViewShowing = YES;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertViewShowing = NO;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (locationActionSheetState == LocationActionSheetStateEmailParticipant)
            {
                [self presentMailModalViewController];
            }
            else if (locationActionSheetState == LocationActionSheetStateWinnerWithPhone)
            {
                [self callLocation:winningLocationSelected];
            }
            else if (locationActionSheetState == LocationActionSheetStateWinnerWithoutPhone)
            {
                [self getDirectionsForLocation:winningLocationSelected];
            }
            break;
        case 1:
            if (locationActionSheetState == LocationActionSheetStateEmailParticipant)
            {
                // cancel, do nothing
            } 
            else if (locationActionSheetState == LocationActionSheetStateWinnerWithPhone)
            {
                [self getDirectionsForLocation:winningLocationSelected];
            }
            else if (locationActionSheetState == LocationActionSheetStateWinnerWithoutPhone)
            {
                // cancel, do nothing
            }
            break;
        case 2:
            // cancel, do nothing in all cases
            break;
        default:
            break;
    }
}

- (void)getDirectionsForLocation:(Location *)loc
{
    NSLog(@"directions %@", loc.formatted_address);
    NSString* addr = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=Current Location&saddr=%@",loc.formatted_address];
    NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
    [url release];
}

- (void)callLocation:(Location *)loc
{
    NSLog(@"call %@", loc.formatted_phone_number);
    NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", loc.stripped_phone_number];
    NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
    [[UIApplication sharedApplication] openURL:phoneLinkURL];
}

#pragma mark -
#pragma mark MFMailComposeViewController Methods

- (void)presentMailModalViewController
{
    //participantSelectedOnMap
    Model *model = [Model sharedInstance];
    Participant *me = [model getParticipantWithEmail:model.userEmail fromEventWithId:model.currentEvent.eventId];
    NSString *title = @"weego";
    NSString *subject = [NSString stringWithFormat:@"weego message from %@", me.fullName];
    NSString *body = @"";
    NSArray *recipients = [NSArray arrayWithObject:participantSelectedOnMap.email];
    
    [[ViewController sharedInstance] showMailModalViewControllerInView:self withTitle:title andSubject:subject andMessageBody:body andToRecipients:recipients];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {    
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheet

-(void) userActionButtonPressedForParticipant:(Participant *)part
{
    locationActionSheetState = LocationActionSheetStateEmailParticipant;
    if (participantSelectedOnMap) [participantSelectedOnMap release];
    participantSelectedOnMap = [part retain];
    [self showUserActionSheetForUser:part];
}
- (void)showUserActionSheetForUser:(Participant *)part
{
    NSString *title = [NSString stringWithFormat:@"How would you like to contact %@?", part.fullName];
    UIActionSheet *userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Email", nil];
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

#pragma mark - AddressBookTVCDataSource

- (NSArray *)dataForAddressBookLocationsTVC
{
    NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
    for (ABContact *abc in allContactsWithAddress) {
        for (int i=0; i<[[abc addressArray] count]; i++) {
            NSDictionary *addressDict = [[abc addressArray] objectAtIndex:i];
            Contact *c = [[Contact alloc] init];
            c.contactName = abc.contactName;
            c.streetAddress = [addressDict objectForKey:@"Street"]; //address;
            c.city = [addressDict objectForKey:@"City"];
            c.state = [addressDict objectForKey:@"State"];
            c.zip = [addressDict objectForKey:@"ZIP"];
            c.countryCode = [addressDict objectForKey:@"CountryCode"];
            if (![[c addressSingleLine] isEqualToString:@""]) [matchedContacts addObject:c];
            [c release];
        }
    }
    NSSortDescriptor *contactSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
	[matchedContacts sortUsingDescriptors:[NSArray arrayWithObjects:contactSortDescriptor, nil]];
    return [matchedContacts autorelease];
}

#pragma mark - AddressBookLocationsTVCDelegate

- (void)addressBookLocationsTVCDidSelectAddress:(NSString *)anAddress
{
    NSLog(@"search for: %@", anAddress);
    continueToSearchEnabled = NO;
    [self doShowSearchAgainButton:NO];
    [[ViewController sharedInstance] goBack];
    [self beginLocationSearchWithSearchString:anAddress andRemovePreviousResults:YES];
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    savedSearchResultsDict = [[NSMutableDictionary alloc] init];
    continueToSearchEnabled = false;
    annotationOpenCount = 0;
    searchBarShowing = false;
    [self setupMapView];
    [self setupInfoView];
    [self setupSearchBar];
    if (initState == AddLocationInitStateFromNewEvent)
    {
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
        currentState = AddLocationStateView;
    }
    else if (initState == AddLocationInitStateFromExistingEvent) // add location button
    {
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
        currentState = AddLocationStateSearch;
    }
    
    [self addSavedLocationAnnotations];
    
    if (initState == AddLocationInitStateFromExistingEventSelectedLocation) 
    {
        currentState = AddLocationStateView;
    }
    
    [self.view setClipsToBounds:YES];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
    
    [self setUpDataFetcherMessageListeners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportTimerTick) name:SYNCH_TEN_SECOND_TIMER_TICK object:nil];
    [self reportTimerTick];
    
}

- (void)reportTimerTick
{ 
    Event *detail = [Model sharedInstance].currentEvent;
    BOOL eventIsWithinTimeRange = detail.minutesToGoUntilEventStarts < (FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2) && detail.minutesToGoUntilEventStarts >  (-FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2);
    BOOL eventIsBeingCreated = detail.isTemporary;
    // grab any users reported locations if in the window
    if (eventIsWithinTimeRange && !eventIsBeingCreated) [[Controller sharedInstance] fetchReportedLocations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateMap;
    [[ViewController sharedInstance] showDropShadow:0];
    
//    mapView.showsUserLocation = true;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self doShowSearchAgainButton:NO];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
