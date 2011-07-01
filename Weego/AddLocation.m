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

// pad our map by 10% around the farthest annotations
#define MAP_PADDING 1.4
#define MINIMUM_VISIBLE_LATITUDE 0.02

typedef enum {
	SearchAndDetailStateSearch = 0,
	SearchAndDetailStateDetail,
    SearchAndDetailStateBoth,
	SearchAndDetailStateNone,
    SearchAndDetailStateEditName
} SearchAndDetailState;

@interface AddLocation ()
- (void)setupMapView;
- (void)zoomToFitMapAnnotations;
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
@end

@implementation AddLocation

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

#pragma mark - SearchAndDetailState handler
- (void)doGoToSearchAndDetailState:(SearchAndDetailState)state
{

    int searchOffState = (initState == AddLocationInitStateFromExistingEventSelectedLocation)?(NavStateLocationAddSearchOffTab):(NavStateLocationAddSearchOff);
    int searchOnState = (initState == AddLocationInitStateFromExistingEventSelectedLocation)?(NavStateLocationAddSearchOnTab):(NavStateLocationAddSearchOn);
    
    if ( [Model sharedInstance].currentEvent.currentEventState >= EventStateDecided && initState != AddLocationInitStateFromNewEvent ) searchOffState = NavStateLocationDecided;
    
    NSLog(@"currentEventState = %i", [Model sharedInstance].currentEvent.currentEventState);
    NSLog(@"isTemporary = %@", ([Model sharedInstance].currentEvent.isTemporary) ? @"YES" : @"NO");
    
    switch (state) {
        case SearchAndDetailStateNone:
//            [self updateSavedLocationsAnnotationsStateEnabled:true];
//            [self removeAnnotations:mapView includingSaved:false];
            if (searchBarShowing) {
                [searchBar resignFirstResponder];
                [self showSearchBar:false withAnimationDelay:0];
            }
            [locWidget setState:WidgetStateClosed withDelay:0];
            [[NavigationSetter sharedInstance] setNavState:searchOffState withTarget:self];
            break;
        case SearchAndDetailStateDetail:
            if (searchBarShowing) {
                [searchBar resignFirstResponder];
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
    searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = HEXCOLOR(0xE4E4E4FF);
    searchBar.translucent = YES;
    searchBar.delegate = self;
    CGRect searchFrame = CGRectMake(0, -41.0, 320.0, 41.0);
    [searchBar setFrame:searchFrame];
    [self.view addSubview:searchBar];
    searchBar.showsCancelButton = NO;
    [searchBar release];
}

- (void)addOrUpdateUserLocationAnnotations
{
    Model *model = [Model sharedInstance];
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getReportedLocations] count];
//    NSLog(@"ReportedLocations count: %d", searchResults);
    for(int i = 0; i < searchResults; i++)
    {
        ReportedLocation *loc = (ReportedLocation *)[[detail getReportedLocations] objectAtIndex:i];
        Participant *p = [model getParticipantWithEmail:loc.userId fromEventWithId:detail.eventId];
        
        if ([p.email isEqualToString:model.userEmail]) continue; // skip the user if it is you
        
        ReportedLocationAnnotation *placemark = [[[ReportedLocationAnnotation alloc] initWithCoordinate:loc.coordinate andParticipant:p] autorelease];
        [mapView addAnnotation:placemark];
    }
    if (searchResults > 0) {
        userLocationFound = true; // cancels zoom to user location
        [self zoomToFitMapAnnotations];
    }
}

- (void)addSavedLocationAnnotations
{
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getLocations] count];
    for(int i = 0; i < searchResults; i++)
    {
        Location *loc = (Location *)[[detail getLocations] objectAtIndex:i];
        
        NSString *uuid = loc.locationId; //[loc stringWithUUID];
        loc.uuid = uuid;
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
        mark.uuid = uuid;
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
        [self zoomToFitMapAnnotations];
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
    if (!toShow) searchBar.text = nil;
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar 
{
    [self resignKeyboardAndRemoveModalCover:self];
    [self removeAnnotations:mapView includingSaved:false];
    [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    Location *searchLocation = [[[Location alloc] init] autorelease];
    searchLocation.latitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.latitude];
    searchLocation.longitude = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.longitude];
    searchLocation.name = theSearchBar.text;
    
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
    CLLocation * newLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude+region.span.latitudeDelta longitude:centerCoordinate.longitude] autorelease];
    CLLocation * centerLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude] autorelease];
    int radius = [centerLocation distanceFromLocation:newLocation];
    
    if (googlePlacesFetchId) [googlePlacesFetchId release];
    googlePlacesFetchId = [[[Controller sharedInstance] searchGooglePlacesForLocation:searchLocation withRadius:radius] retain];
    if (pendingSearchString) [pendingSearchString release];
    pendingSearchString = [theSearchBar.text retain];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
    [self handleEndSearchPress:self];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar
{
    [self showKeyboardResignerAndEnable:YES]; 
    return YES;
}

#pragma mark - keyboard model resigner helper methods
- (void)showKeyboardResignerAndEnable:(BOOL)enabled
{
    CGRect rect = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height);
    keyboardResigner = [UIButton buttonWithType:UIButtonTypeCustom];
    keyboardResigner.frame = rect;
    [keyboardResigner setBackgroundColor:[UIColor blackColor]];
    [keyboardResigner setAlpha:0.5f];
    if (enabled) [keyboardResigner addTarget:self action:@selector(resignKeyboardAndRemoveModalCover:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:keyboardResigner];
}
- (void)hideKeyboardResigner
{
    if (keyboardResigner != nil) [keyboardResigner removeFromSuperview];
    keyboardResigner = nil;
}

#pragma mark - UISearchBar helper methods
- (void)resignKeyboardAndRemoveModalCover:(id)target
{
    [searchBar resignFirstResponder];
    [keyboardResigner removeFromSuperview];
    keyboardResigner = nil;
}

- (void)addSearchResultAnnotations
{
    int searchResults = [savedGoogleObjects count];
    
    // Add placemarks for each result
    for(int i = 0; i < searchResults; i++)
    {
        Location *place = [savedGoogleObjects objectAtIndex:i];
        // Add a placemark on the map
        LocAnnotation *mark = [[[LocAnnotation alloc] initWithLocation:place withStateType:LocAnnoStateTypeSearch andSelectedState:LocAnnoSelectedStateDefault] autorelease];
        mark.dataLocationIndex = i;
        mark.iAddedLocation = YES;
        [mapView addAnnotation:mark];	
    }
    [self zoomToFitMapAnnotations];
    [self updateSavedLocationsAnnotationsStateEnabled:false];
}

#pragma mark - MKMapViewDelegate methods
- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (userLocationFound) return;
    MKCoordinateRegion region;
    region.center.latitude = userLocation.coordinate.latitude;
    region.center.longitude = userLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.3;
    region.span.longitudeDelta = 0.3;
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
        selectedSearchLocationIndex = -1;
        selectedLocationIndex = -1;
        if (placeMark.isSavedLocation)
        {
            selectedLocationIndex = placeMark.dataLocationIndex;
        }
        else
        {
            selectedSearchLocationIndex = placeMark.dataLocationIndex;
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
            selectedSearchLocationIndex = -1;
            selectedLocationIndex = -1;
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
            selectedSearchLocationIndex = -1;
            selectedLocationIndex = -1;
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
	selectedSearchLocationIndex = -1;
    selectedLocationIndex = -1;
	NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:mapView.annotations.count];
	for (id annotation in mapView.annotations) {
		if ([annotation isKindOfClass:[LocAnnotation class]]) {
            LocAnnotation *anno = annotation;
			if (!anno.isSavedLocation || includeSaved)   [toRemove addObject:annotation];
		}
	}
	[mapView removeAnnotations:toRemove];
}

- (void)zoomToFitMapAnnotations
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MKUserLocation* annotation in mapView.annotations)
    {
        if ((MKUserLocation *)annotation == mapView.userLocation) continue; // dont take user location into account
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude) / 2;
    region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude) / 2;
    
    region.span.latitudeDelta = (bottomRightCoord.latitude - topLeftCoord.latitude) * MAP_PADDING;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
    ? MINIMUM_VISIBLE_LATITUDE 
    : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (bottomRightCoord.longitude - topLeftCoord.longitude) * MAP_PADDING;
    
    MKCoordinateRegion scaledRegion = [mapView regionThatFits:region];
    [mapView setRegion:scaledRegion animated:YES];
}


#pragma mark - LocationDetailWidgetDelegate methods
- (void)addButtonPressed
{
    Location *aPlace = [savedGoogleObjects objectAtIndex:selectedSearchLocationIndex];
	Location *location = [[Model sharedInstance] createNewLocationWithPlace:aPlace];
    
    NSString *uuid = location.locationId; //[location stringWithUUID];
    location.uuid = uuid;
    
	Controller *controller = [Controller sharedInstance];
    NSArray *locations = [NSArray arrayWithObject:location];
    [controller addOrUpdateLocations:locations isAnUpdate:NO];
        
    // add the newly save annotation to the map
//    selectedSearchLocationIndex = -1;
//    selectedLocationIndex = -1;
    
    LocAnnoStateType type = LocAnnoStateTypePlace;
    LocAnnoSelectedState state = LocAnnoSelectedStateSelected;
    
    LocAnnotation *placemark = [[mapView selectedAnnotations]objectAtIndex:0];
    [placemark setStateType:type];
    [placemark setSelectedState:state];
    placemark.isNewlyAdded = true;
    placemark.uuid = uuid;
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    if ([Model sharedInstance].currentAppState == AppStateCreateEvent || [Model sharedInstance].isInTrial) {
        [locWidget updateInfoViewWithCorrectButtonState:ActionStateLike];
    } else {
        [locWidget updateInfoViewWithCorrectButtonState:ActionStateSpinning];
        mapView.userInteractionEnabled = NO;
        isAddingLocation = YES;
    }
}

- (void)likeButtonPressed
{
//    NSLog(@"likeButtonPressed dataLocationIndex: %d", selectedLocationIndex);
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
    [placemark setStateType:LocAnnoStateTypeLiked];
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    
    Event *detail = [Model sharedInstance].currentEvent;
    Location *loc = [detail getLocationWithUUID:placemark.uuid];
    
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
//    [controller voteForLocationWithId:loc.locationId];
    [locWidget updateInfoViewWithCorrectButtonState:ActionStateUnlike];
}
- (void)unlikeButtonPressed
{
//    NSLog(@"unlikeButtonPressed dataLocationIndex: %d", selectedLocationIndex);
    LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
    [placemark setStateType:LocAnnoStateTypePlace];
    [mapView viewForAnnotation:placemark].image = [placemark imageForCurrentState];
    
    Event *detail = [Model sharedInstance].currentEvent;
    Location *loc = [detail getLocationWithUUID:placemark.uuid];
    
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
//    [controller removeVoteForLocationWithId:loc.locationId];
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
    NSLog(@"loc.uuid = %@ : loc.id = %@ : pm.uuid = %@", loc.uuid, loc.locationId, placemark.uuid);
    if (model.currentAppState == AppStateCreateEvent || loc == nil) // case 1 - create mode OR case 2 - location unsaved
    {
        Location *aPlace = [savedGoogleObjects objectAtIndex:selectedSearchLocationIndex];
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
        [self hideKeyboardResigner];
        
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
    [self removeDataFetcherMessageListeners];
    [selectedLocationId release];
    [self removeAnnotations:mapView includingSaved:true];
    [savedGoogleObjects release];
    mapView.delegate = nil;
    searchBar.delegate = nil;
    if (participantSelectedOnMap) [participantSelectedOnMap release];
    [googlePlacesFetchId release];
    [googleGeoFetchId release];
    [pendingSearchString release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    
    switch (fetchType) {
        case DataFetchTypeAddNewLocationToEvent:
            [locWidget updateInfoViewWithCorrectButtonState:ActionStateLike];
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
        case DataFetchTypeGooglePlaceSearch:
            if ( [fetchId isEqualToString:googlePlacesFetchId] )
            {
                [savedGoogleObjects release];
                NSMutableArray *locations = [Model sharedInstance].googleLocalSearchResults;
                savedGoogleObjects = [[NSMutableArray alloc] initWithArray:locations];
                
                // remove any existing locations from results
                NSMutableArray *toRemove = [[[NSMutableArray alloc] init] autorelease];
                for (Location *obj in savedGoogleObjects) {
                    if ([[Model sharedInstance] locationExistsInCurrentEvent:obj]) [toRemove addObject:obj];
                }
                [savedGoogleObjects removeObjectsInArray:toRemove];
            }
            if ([savedGoogleObjects count] == 0) {
                NSLog(@"No place results found, searching GEO for query: %@", pendingSearchString);
                if (googleGeoFetchId != nil) [googleGeoFetchId release];
                
                CLLocationCoordinate2D northEast, southWest;
                northEast = [mapView convertPoint:CGPointMake(mapView.frame.size.width, 0) toCoordinateFromView:mapView];
                southWest = [mapView convertPoint:CGPointMake(0, mapView.frame.size.height) toCoordinateFromView:mapView];
                
                googleGeoFetchId = [[[Controller sharedInstance] searchGoogleGeoForAddress:pendingSearchString northEastBounds:northEast southWestBounds:southWest] retain];
                
            }
            else 
            {
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
            }
            
            break;
        case DataFetchTypeGoogleAddressSearch:
            if ( [fetchId isEqualToString:googleGeoFetchId] )
            {
                [savedGoogleObjects release];
                NSMutableArray *locations = [Model sharedInstance].googleLocalSearchResults;
                savedGoogleObjects = [[NSMutableArray alloc] initWithArray:locations];
                
                // remove any existing locations from results
                NSMutableArray *toRemove = [[[NSMutableArray alloc] init] autorelease];
                for (Location *obj in savedGoogleObjects) {
                    if ([[Model sharedInstance] locationExistsUsingLatLngInCurrentEvent:obj]) [toRemove addObject:obj];
                }
                [savedGoogleObjects removeObjectsInArray:toRemove];
            }
            if ([savedGoogleObjects count] == 0) {
                NSLog(@"No address results found for query: %@, giving up", pendingSearchString);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
                [self updateSavedLocationsAnnotationsStateEnabled:true];
                currentState = AddLocationStateView;
            }
            else 
            {
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
            }
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
        case DataFetchTypeGooglePlaceSearch:
            NSLog(@"Unhandled Error: %d", DataFetchTypeGooglePlaceSearch);
            //
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
//    [userOptions showInView:self.view];
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
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
    
    Event *detail = [Model sharedInstance].currentEvent;
    BOOL eventIsWithinTimeRange = detail.minutesToGo < (CHECKIN_TIME_RANGE_MINUTES/2) && detail.minutesToGo >  (-CHECKIN_TIME_RANGE_MINUTES/2);
    BOOL eventIsBeingCreated = detail.isTemporary;
    // grab any users reported locations if in the window
    if (eventIsWithinTimeRange && !eventIsBeingCreated) [[Controller sharedInstance] fetchReportedLocations];
    
//    NSLog(@"loadView");
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateMap;
    [[ViewController sharedInstance] showDropShadow:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"AddLocation viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
