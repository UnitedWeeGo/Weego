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
#import "GetDirectionsActionSheetController.h"

typedef enum {
	SearchAndDetailStateSearch = 0,
	SearchAndDetailStateDetail,
    SearchAndDetailStateBoth,
	SearchAndDetailStateNone,
    SearchAndDetailStateEditName,
    SearchAndDetailStateNoLocation
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
- (void)doSecondaryAddressSearch;
- (void)beginLocationSearchWithSearchString:(NSString *)searchString andRemovePreviousResults:(BOOL)removePreviousResults;
- (void)beginCurrentLocationSearchWithCoordinate:(CLLocationCoordinate2D)coord;
- (BOOL)locationCollection:(NSMutableArray *)collection containsLocation:(Location *)location;
- (void)doShowSearchAgainButton:(BOOL)doShow;
- (void)enableSearchCategoryTable;
- (void)disableSearchCategoryTable;
- (void)showAlertWithCode:(int)code;
- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part;
- (void)reportTimerTick;
- (void)checkReportedLocations;
- (void)resetMapViewFrameWithState:(SearchAndDetailState)state andShowsToolbarButton:(BOOL)showsToolbarButton;
- (BOOL)mapZoomLevelAppropriateForSearch;
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
    feedShowing = false;
    BOOL isTemp = [Model sharedInstance].currentEvent.isTemporary;
    Event *detail = [Model sharedInstance].currentEvent;
    int searchOffState = NavStateLocationAddSearchOff;
    int searchOnState = NavStateLocationAddSearchOn;
    
    if ( [Model sharedInstance].currentEvent.currentEventState >= EventStateDecided && initState != AddLocationInitStateFromNewEvent ) {
        searchOffState = NavStateLocationDecided;
        decidedShowing = YES;
    }
    
    switch (state) {
        case SearchAndDetailStateNone:
            if (searchBarShowing) {
                [searchBar resetField];
                [self showSearchBar:false withAnimationDelay:0];
            }
            [locWidget setState:WidgetStateClosed withDelay:0];
            [[NavigationSetter sharedInstance] setNavState:searchOffState withTarget:self];
            if (!isTemp)
            {
                feedShowing = true;
                [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[detail.unreadMessageCount intValue]];
            }
            [self resetMapViewFrameWithState:SearchAndDetailStateNone andShowsToolbarButton:!isTemp];
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
            if (!isTemp)
            {
                feedShowing = true;
                [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[detail.unreadMessageCount intValue]];
            }
            [self resetMapViewFrameWithState:SearchAndDetailStateDetail andShowsToolbarButton:!isTemp];
            break;
        case SearchAndDetailStateSearch:
            if (locWidget.iAmShowing) {
                [locWidget setState:WidgetStateClosed withDelay:0];
                [self showSearchBar:true withAnimationDelay:0.00f];
            } else if (!searchBarShowing) {
                [self showSearchBar:true withAnimationDelay:0];
            }
            [[NavigationSetter sharedInstance] setNavState:searchOnState withTarget:self];
            [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
            [self resetMapViewFrameWithState:SearchAndDetailStateSearch andShowsToolbarButton:NO];
            break;
        case SearchAndDetailStateBoth:
            [self showSearchBar:true withAnimationDelay:0];
            [locWidget setState:WidgetStateOpenWithSearch withDelay:0];
            [[NavigationSetter sharedInstance] setNavState:searchOnState withTarget:self];
            [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
            [self resetMapViewFrameWithState:SearchAndDetailStateBoth andShowsToolbarButton:NO];
            break;
        case SearchAndDetailStateEditName:
            [self showSearchBar:false withAnimationDelay:0];
            [locWidget setState:WidgetStateOpen withDelay:0.00f];
            [[NavigationSetter sharedInstance] setNavState:NavStateLocationNameEdit withTarget:self];
            if (!isTemp)
            {
                feedShowing = true;
                [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[detail.unreadMessageCount intValue]];
            }
            [self resetMapViewFrameWithState:SearchAndDetailStateEditName andShowsToolbarButton:!isTemp];
            break;
            
        case SearchAndDetailStateNoLocation:
            [self showSearchBar:true withAnimationDelay:0];
            [locWidget transitionToNoLocationState];
            [[NavigationSetter sharedInstance] setNavState:searchOnState withTarget:self];
            [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
            [self resetMapViewFrameWithState:SearchAndDetailStateBoth andShowsToolbarButton:NO];
            break;
        default:
            break;
    }
}


#pragma mark - UI setup
- (void)setupMapView
{
    CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44);
    mapView = [[MKMapView alloc] initWithFrame:rect];
    mapView.delegate = self;
    mapView.showsUserLocation = true;
    [self.view addSubview:mapView];
    [mapView release];
}
- (void)resetMapViewFrameWithState:(SearchAndDetailState)state andShowsToolbarButton:(BOOL)showsToolbarButton
{
    int y = state == SearchAndDetailStateSearch || state == SearchAndDetailStateBoth ? 40 : 0;
    int height = showsToolbarButton ? 375-y : 418-y;
    // y=0 h375 - with bottom button search off
    // y=44 h375 - NO bottom button search on
    
    CGRect rect = CGRectMake(0, y, self.view.bounds.size.width, height);
    [UIView animateWithDuration:0.20f 
                          delay:0.0f 
                        options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         mapView.frame = rect;
                     }
                     completion:NULL];
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
    searchBar.returnKey = UIReturnKeySearch;
    searchBar.placeholderText = @"Search for a location";
    [self.view addSubview:searchBar];
    [searchBar release];
}

- (void)setupSearchCatView
{
    CGRect viewRect = CGRectMake(0, 40, self.view.bounds.size.width, 160);
    if (categoryTable == nil) categoryTable = [[[SearchCategoryTable alloc] initWithFrame:viewRect] autorelease];
    categoryTable.delegate = self;
    [self.view addSubview:categoryTable];
}

#pragma mark - User location annotation management
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
        
        ReportedLocationAnnotation *addedAlready = [self getReportedLocationAnnotationForUser:p];
        
        if (addedAlready)
        {
            if (loc.disableLocationReporting)
            {
                [mapView removeAnnotation:addedAlready];
            }
            else
            {
                [addedAlready setCoordinate:loc.coordinate];
            }
        }
        else if (!loc.disableLocationReporting)
        {
            ReportedLocationAnnotation *placemark = [[[ReportedLocationAnnotation alloc] initWithCoordinate:loc.coordinate andParticipant:p] autorelease];
            [mapView addAnnotation:placemark];
        }
    }
    if (searchResults > 0 && !alreadyZoomedToShowOthersLocations) {
        userLocationFound = true; // cancels zoom to user location
        [self zoomToFitMapAnnotationsAndSkipPreviouslyAdded:NO];
    }
    alreadyZoomedToShowOthersLocations = YES;
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
    [UIView animateWithDuration:0.20f 
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
    if (pendingSearchString != nil && ![pendingSearchString isEqualToString:searchString])
    {
        [pendingSearchString release];
        pendingSearchString = nil;
    }
    if (pendingSearchCategory != nil)
    {
        [pendingSearchCategory release];
        pendingSearchCategory = nil;
    }
    
    searchBar.text = searchString;
    [searchBar showNetworkActivity:YES];
    if (removePreviousResults)
    {
        [self resignKeyboardAndRemoveModalCover:self];
        [self removeAnnotations:mapView includingSaved:false];
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    }

    if (genericSearchFetchId != nil) 
    {
        [genericSearchFetchId release];
        genericSearchFetchId = nil;
    }
    
    if ([Model sharedInstance].searchAPIType == SearchAPITypeSimpleGeo) 
    {
        MKMapRect mRect = mapView.visibleMapRect;
        MKMapPoint neMapPoint = MKMapPointMake(mRect.origin.x + mRect.size.width, mRect.origin.y);
        MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, mRect.origin.y + mRect.size.height);
        CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
        CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
        
        SGEnvelope *envelope = [SGEnvelope envelopeWithNorth:neCoord.latitude west:swCoord.longitude south:swCoord.latitude east:neCoord.longitude];
        genericSearchFetchId = [[[Controller sharedInstance] searchSimpleGeoWithEnvelope:envelope andName:searchString] retain];
    }
    else if ([Model sharedInstance].searchAPIType == SearchAPITypeYelp)
    {        
        BOOL locationServicesEnabled = [[LocationService sharedInstance] locationServicesEnabledInSystemPrefs];
        NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
        
        
        if (![self mapZoomLevelAppropriateForSearch]) // search area too large!!
        {
            if (!locationServicesEnabled)
            {
                alertViewIsNoLocation = YES;
                UIAlertView *areaTooLargeAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:(canOpenPrefs ? @"You have location services disabled. Would you like to open your location preferences? Additionally, you'll need to zoom in to search.":@"You have location services disabled for Weego. Additionally, you'll need to zoom in to search.") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] autorelease];
                [areaTooLargeAlert show]; 
            }
            else
            {
                UIAlertView *areaTooLargeAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"You are zoomed too far out to search. Please zoom the map in a bit and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                [areaTooLargeAlert show];
            }
            [searchBar showNetworkActivity:NO];
            return;
            
        }
        else
        {
            NSLog(@"is pendingSearchString nil: %d", pendingSearchString==nil);
            /*
             If the user has moved the map to search again, then we will search the bounds of the view.
             Otherwise, it is a new search and we will search by radius
             */
            if (pendingSearchString==nil)
            {
                genericSearchFetchId = [[[Controller sharedInstance] searchYelpForName:searchString andCenterCoordinate:mapView.centerCoordinate] retain]; 
            }
            else {
                CLLocationCoordinate2D northEast, southWest;
                northEast = [mapView convertPoint:CGPointMake(mapView.frame.size.width, 0) toCoordinateFromView:mapView];
                southWest = [mapView convertPoint:CGPointMake(0, mapView.frame.size.height) toCoordinateFromView:mapView];
                genericSearchFetchId = [[[Controller sharedInstance] searchYelpForName:searchString northEastBounds:northEast southWestBounds:southWest] retain];
            }
        }
    }
    
    if (pendingSearchString) [pendingSearchString release];
    pendingSearchString = [searchBar.text retain];
    
    if (pendingSearchCategory) [pendingSearchCategory release];
    pendingSearchCategory = nil;
}

- (BOOL)mapZoomLevelAppropriateForSearch
{
    CLLocationCoordinate2D northEast, southWest;
    northEast = [mapView convertPoint:CGPointMake(mapView.frame.size.width, 0) toCoordinateFromView:mapView];
    southWest = [mapView convertPoint:CGPointMake(0, mapView.frame.size.height) toCoordinateFromView:mapView];
    
    
    float distanceLatInDegrees = northEast.latitude - southWest.latitude;
    float numLatMiles = 69.172 * distanceLatInDegrees;
    
    float distanceLonInDegrees = northEast.longitude - southWest.longitude;
    float numLonMiles = 69.172 * distanceLonInDegrees;
    
    float numSquareMiles = numLatMiles*numLonMiles;
    
    return numSquareMiles < 2500;
}

- (void)beginCurrentLocationSearchWithCoordinate:(CLLocationCoordinate2D)coord
{
    searchBar.text = @"";
    [searchBar showNetworkActivity:YES];

    [self resignKeyboardAndRemoveModalCover:self];
    [self removeAnnotations:mapView includingSaved:false];
    [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    
    if (genericSearchFetchId != nil) 
    {
        [genericSearchFetchId release];
        genericSearchFetchId = nil;
    }
    
    genericSearchFetchId = [[[Controller sharedInstance] searchSimpleGeoForAddressWithCoordinate:coord] retain];
    
    if (pendingSearchString) [pendingSearchString release];
    pendingSearchString = nil;
    
    if (pendingSearchCategory) [pendingSearchCategory release];
    pendingSearchCategory = nil;
    
    continueToSearchEnabled = false;
}

- (void)beginLocationSearchWithCategory:(SearchCategory *)searchCategory andRemovePreviousResults:(BOOL)removePreviousResults
{
    if (pendingSearchString != nil)
    {
        [pendingSearchString release];
        pendingSearchString = nil;
    }
    if (pendingSearchCategory != nil && ![pendingSearchCategory.category isEqualToString:searchCategory.category])
    {
        [pendingSearchCategory release];
        pendingSearchCategory = nil;
    }
    
    
    searchBar.text = searchCategory.search_category;
    [searchBar showNetworkActivity:YES];
    if (removePreviousResults)
    {
        [self resignKeyboardAndRemoveModalCover:self];
        [self removeAnnotations:mapView includingSaved:false];
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
    }
    
    if (genericSearchFetchId != nil) 
    {
        [genericSearchFetchId release];
        genericSearchFetchId = nil;
    }
    
    if ([Model sharedInstance].searchAPIType == SearchAPITypeSimpleGeo) 
    {
        MKMapRect mRect = mapView.visibleMapRect;
        MKMapPoint neMapPoint = MKMapPointMake(mRect.origin.x + mRect.size.width, mRect.origin.y);
        MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, mRect.origin.y + mRect.size.height);
        CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
        CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
        
        SGEnvelope *envelope = [SGEnvelope envelopeWithNorth:neCoord.latitude west:swCoord.longitude south:swCoord.latitude east:neCoord.longitude];
        genericSearchFetchId = [[[Controller sharedInstance] searchSimpleGeoWithCategory:searchCategory andEnvelope:envelope] retain];
    }
    else if ([Model sharedInstance].searchAPIType == SearchAPITypeYelp)
    {
        BOOL locationServicesEnabled = [[LocationService sharedInstance] locationServicesEnabledInSystemPrefs];
        NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
        
        
        if (![self mapZoomLevelAppropriateForSearch]) // search area too large!!
        {
            if (!locationServicesEnabled)
            {
                alertViewIsNoLocation = YES;
                UIAlertView *areaTooLargeAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:(canOpenPrefs ? @"You have location services disabled. Would you like to open your location preferences? Additionally, you'll need to zoom in to search.":@"You have location services disabled for Weego. Additionally, you'll need to zoom in to search.") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] autorelease];
                [areaTooLargeAlert show]; 
            }
            else
            {
                UIAlertView *areaTooLargeAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"You are zoomed too far out to search. Please zoom the map in a bit and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                [areaTooLargeAlert show];
            }
            [searchBar showNetworkActivity:NO];
            return;
            
        }
        else
        {
            NSLog(@"is pendingSearchCategory nil: %d", pendingSearchCategory==nil);
            
            /*
             If the user has moved the map to search again, then we will search the bounds of the view.
             Otherwise, it is a new search and we will search by radius
             */
            if (pendingSearchCategory==nil)
            {
                genericSearchFetchId = [[[Controller sharedInstance] searchYelpForName:searchCategory.category andCenterCoordinate:mapView.centerCoordinate] retain]; 
            }
            else {
                CLLocationCoordinate2D northEast, southWest;
                northEast = [mapView convertPoint:CGPointMake(mapView.frame.size.width, 0) toCoordinateFromView:mapView];
                southWest = [mapView convertPoint:CGPointMake(0, mapView.frame.size.height) toCoordinateFromView:mapView];
                genericSearchFetchId = [[[Controller sharedInstance] searchYelpForName:searchCategory.category northEastBounds:northEast southWestBounds:southWest] retain];
            }
        }
    }
    
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
    [categoryTable updateSearchContentsWithSearchString:searchText];
}
- (void)searchBarBookmarkButtonClicked:(SubViewSearchBar *)theSearchBar
{
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
    categoryTable.hidden = NO;
    [categoryTable updateSearchContentsWithSearchString:@""];
    [self.view bringSubviewToFront:categoryTable];
}
- (void)disableSearchCategoryTable
{    
    categoryTable.hidden = YES;
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
            NSString *friendlyName = [friendlyNameDict valueForKey:pendingSearchString];
            if (friendlyName) place.name = friendlyName;
            
            newLocationDetected = YES;
            place.hasBeenAddedToMapPreviously = YES;
            LocAnnotation *mark = [[LocAnnotation alloc] initWithLocation:place withStateType:LocAnnoStateTypeSearch andSelectedState:LocAnnoSelectedStateDefault];
            mark.uuid = key;
            mark.iAddedLocation = YES;
            mark.scheduledForZoom = YES;
            [mapView addAnnotation:mark];
            
            if (place.topRankingResult) [mapView selectAnnotation:mark animated:NO];
            
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
    // zooming moved for iOS5
}

- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[LocAnnotation class]]) {
        
        LocAnnotation *placeMark = view.annotation;
        [placeMark setSelectedState:LocAnnoSelectedStateSelected];
        view.image = [placeMark imageForCurrentState];
        
        self.selectedLocationKey = nil;
        self.selectedSearchLocationKey = nil;
        
        if (placeMark.isSavedLocation)
        {
            self.selectedLocationKey = placeMark.uuid;
        }
        else
        {
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
        pinView.centerOffset = [placeMark offsetForCurrentState];
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
            pinView.centerOffset = CGPointMake(7,-20);
		}
        [pinView setCurrentState:ReportedLocationAnnoSelectedStateDefault andParticipantImageURL:placeMark.participant.avatarURL];
        return pinView;
    }
	return nil;
}

- (void) mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views {
    if ([searchBar respondsToSelector:@selector(showNetworkActivity:)]) [searchBar showNetworkActivity:NO];
    
    for (MKAnnotationView *view in views) {
        if(view.annotation == theMapView.userLocation) {
            if (alreadyZoomedToShowUserLocation) return;
            if (theMapView.userLocation.location == nil) return;
            
            [self zoomToFitMapAnnotationsAndSkipPreviouslyAdded:NO];
        }
    }
}

- (void)removeAnnotations:(MKMapView *)theMapView includingSaved:(Boolean)includeSaved
{
	// remove observers and annotation
    currentState = AddLocationStateView;
    
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
        BOOL isUserLocation = mapView.userLocation == annotation;
        if (isUserLocation && !alreadyZoomedToShowUserLocation) 
        {
            alreadyZoomedToShowUserLocation = YES;
        }
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
            
            double z_width = 1;
            double z_height = 1;
            
            MKMapRect r = MKMapRectMake(annotationPoint.x - z_width, annotationPoint.y - z_height, z_width, z_height);
            
            zoomRect = r;
            
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    float origWidth = zoomRect.size.width;
    float paddedWidth = zoomRect.size.width *= 1.5;
    float origHeight = zoomRect.size.height;
    float paddedHeight = zoomRect.size.height *= 1.5;
    
    if (paddedWidth < 1000)
    {
        paddedWidth = 20000;
    }
    
    zoomRect.origin.x += (origWidth - paddedWidth) / 2;
    zoomRect.origin.y += (origHeight - paddedHeight);
    
    zoomRect.size.width = paddedWidth;
    zoomRect.size.height = paddedHeight;
    
    [mapView setVisibleMapRect:zoomRect animated:YES];
}



#pragma mark - LocationDetailWidgetDelegate methods
- (void)addButtonPressed
{    
    Location *aPlace = [savedSearchResultsDict objectForKey:self.selectedSearchLocationKey];
    
	Location *location = [[Model sharedInstance] createNewLocationWithPlace:aPlace];
    
    NSString *uuid = location.g_id; //[location stringWithUUID];
    
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
    Location *locationSelected;
    
    if (self.selectedSearchLocationKey != nil)
    {
        locationSelected = [savedSearchResultsDict objectForKey:self.selectedSearchLocationKey];
    }
    else if (self.selectedLocationKey != nil)
    {
        LocAnnotation *placemark = [[mapView selectedAnnotations] objectAtIndex:0];
        Event *detail = [Model sharedInstance].currentEvent;
        locationSelected = [detail getLocationWithUUID:placemark.uuid];
    }
    else
    {
        NSLog(@"ERROR - No location found!");
        return;
    }
    
    if ([locationSelected.location_type isEqualToString:@"yelp"])
    {
        [[ViewController sharedInstance] navigateToYelpReviewsWithURL:locationSelected.mobileYelpUrl];
    }
    else
    {
        [[GetDirectionsActionSheetController sharedInstance] presentDirectionsActionSheetForLocation:locationSelected];
    }
    
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
- (void)handleFeedPress:(id)sender
{
    //	NSLog(@"handleFeedPress");
    [[ViewController sharedInstance] showModalFeed:self];
    
}
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

- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}
- (void)handleMorePress:(id)sender
{
    [[MoreButtonActionSheetController sharedInstance:self] showActionSheetForMorePress];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_THIRTY_SECOND_TIMER_TICK object:nil];
    [self removeDataFetcherMessageListeners];
    [selectedLocationId release];
    [self removeAnnotations:mapView includingSaved:true];
    
    [savedSearchResultsDict release];
    [friendlyNameDict release];
    
    mapView.delegate = nil;
    searchBar.delegate = nil;
    if (participantSelectedOnMap) [participantSelectedOnMap release];
    if (genericSearchFetchId != nil) 
    {
        [genericSearchFetchId release];
        genericSearchFetchId = nil;
    }
    [googlePlacesFetchId release];
    [googleGeoFetchId release];
    [pendingSearchString release];
    [pendingSearchCategory release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
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
    Model *model = [Model sharedInstance];
    if (feedShowing && model.currentEvent.currentEventState > EventStateNew) [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[model.currentEvent.unreadMessageCount intValue]];
    
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    
    switch (fetchType) {
        case DataFetchTypeToggleEventAcceptance:
            NSLog(@"AddLocation DataFetchTypeToggleEventAcceptance Success");
            break;
        case DataFetchTypeAddNewLocationToEvent:
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
            [self addOrUpdateUserLocationAnnotations];
            break;
        case DataFetchTypeSearchYelp:       // same code to execute
        case DataFetchTypeSearchSimpleGeo:  // same code to execute
            if ( [fetchId isEqualToString:genericSearchFetchId] )
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
                    
                    for (int i=0; i<[locations count]; i++)
                    {
                        Location *loc = [locations objectAtIndex:i];
                        if (i == 0)
                        {
                            loc.topRankingResult = YES;
                        }
                        else
                        {
                            loc.topRankingResult = NO;
                        }
                        [savedSearchResultsDict setObject:loc forKey:loc.g_id];
                    }
                    
                }
                else
                {                    
                    [savedSearchResultsDict removeAllObjects];
                    
                    for (int i=0; i<[locations count]; i++)
                    {
                        Location *loc = [locations objectAtIndex:i];
                        if (i == 0)
                        {
                            loc.topRankingResult = YES;
                        }
                        else
                        {
                            loc.topRankingResult = NO;
                        }
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
            
                BOOL possibleAddress = NO;
                if (pendingSearchString)
                {
                    possibleAddress = [pendingSearchString length] && isnumber([pendingSearchString characterAtIndex:0]);
                }
                
                if (possibleAddress && !continueToSearchEnabled && pendingSearchString != nil) 
                {
                    NSLog(@"possible address for search, continuing to google search");
                    [self doSecondaryAddressSearch];
                } 
                else if ([locations count] == 0) 
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This search returned no results" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }

                continueToSearchEnabled = true;
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
                [searchBar showNetworkActivity:NO];
            }
            break;
            
        case DataFetchTypeSearchSimpleGeoCurrentLocation:
            if ( [fetchId isEqualToString:genericSearchFetchId] )
            {
                
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                // if this is a continue, simply add to the result collection
                [savedSearchResultsDict removeAllObjects];
                
                for (int i=0; i<[locations count]; i++)
                {
                    Location *loc = [locations objectAtIndex:i];
                    if (i == 0)
                    {
                        loc.topRankingResult = YES;
                    }
                    else
                    {
                        loc.topRankingResult = NO;
                    }
                    [savedSearchResultsDict setObject:loc forKey:loc.g_id];
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
                
                if ([savedSearchResultsDict count] == 0) 
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This search returned no results" message:@"We could not find your current location, or it was already added." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                continueToSearchEnabled = false;
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
                [searchBar showNetworkActivity:NO];
            }
            break;
        case DataFetchTypeSearchSimpleGeoCurrentLocationNearbyPlaces:
            if ( [fetchId isEqualToString:genericSearchFetchId] )
            {
                
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                // if this is a continue, simply add to the result collection
                [savedSearchResultsDict removeAllObjects];
                
                for (int i=0; i<[locations count]; i++)
                {
                    Location *loc = [locations objectAtIndex:i];
                    if (i == 0)
                    {
                        loc.topRankingResult = YES;
                    }
                    else
                    {
                        loc.topRankingResult = NO;
                    }
                    [savedSearchResultsDict setObject:loc forKey:loc.g_id];
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
                
                if ([savedSearchResultsDict count] == 0) 
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This search returned no results" message:@"We could not find your current location, or all results have already been added." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                continueToSearchEnabled = false;
                [self addSearchResultAnnotations];
                currentState = AddLocationStateSearch;
                [searchBar showNetworkActivity:NO];
            }
            break;
            
            
        case DataFetchTypeGoogleAddressSearch:
            if ( [fetchId isEqualToString:googleGeoFetchId] )
            {
                NSMutableArray *locations = [Model sharedInstance].geoSearchResults;
                                
                for (int i=0; i<[locations count]; i++)
                {
                    Location *loc = [locations objectAtIndex:i];
                    if (i == 0)
                    {
                        loc.topRankingResult = YES;
                    }
                    else
                    {
                        loc.topRankingResult = NO;
                    }
                    [savedSearchResultsDict setObject:loc forKey:loc.g_id];
                }
                
                
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
            }
            break;
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
//    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeAddNewLocationToEvent:
            NSLog(@"DataFetchTypeAddNewLocationToEvent Error: %d", DataFetchTypeAddNewLocationToEvent);
            [locWidget updateInfoViewWithCorrectButtonState:ActionStateAdd];
            Model *model = [Model sharedInstance];
            [model flushTempLocationsForEventWithId:model.currentEvent.eventId];
            mapView.userInteractionEnabled = YES;
            isAddingLocation = NO;
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        case DataFetchTypeGetReportedLocations:
            NSLog(@"DataFetchTypeGetReportedLocations Error: %d", DataFetchTypeGetReportedLocations);
            mapView.userInteractionEnabled = YES;
            break;
        case DataFetchTypeSearchSimpleGeo:
            NSLog(@"DataFetchTypeSearchSimpleGeo Error: %d", DataFetchTypeSearchSimpleGeo);
            [searchBar showNetworkActivity:NO];
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        case DataFetchTypeSearchSimpleGeoCurrentLocation:
            NSLog(@"DataFetchTypeSearchSimpleGeoCurrentLocation Error: %d", DataFetchTypeSearchSimpleGeo);
            [searchBar showNetworkActivity:NO];
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        case DataFetchTypeSearchSimpleGeoCurrentLocationNearbyPlaces:
            NSLog(@"DataFetchTypeSearchSimpleGeoCurrentLocationNearbyPlaces Error: %d", DataFetchTypeSearchSimpleGeo);
            [searchBar showNetworkActivity:NO];
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        case DataFetchTypeSearchYelp:
            NSLog(@"DataFetchTypeSearchYelp Error: %d", DataFetchTypeSearchYelp);
            [searchBar showNetworkActivity:NO];
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        case DataFetchTypeGoogleAddressSearch:
            NSLog(@"DataFetchTypeGoogleAddressSearch Error: %d", DataFetchTypeGoogleAddressSearch);
            [searchBar showNetworkActivity:NO];
            if (!alertViewShowing && [Model sharedInstance].currentViewState == ViewStateMap) [self showAlertWithCode:errorType];
            break;
        default:
            break;
    }
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Uh oh!";
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
    NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
    if (alertViewIsNoLocation && buttonIndex == 1 && canOpenPrefs)
    {
        [[ViewController sharedInstance] goBack];
        [[UIApplication sharedApplication] openURL:url];
    }
    alertViewShowing = NO;
    alertViewIsNoLocation = NO;
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
            break;
        case 1:
            if (locationActionSheetState == LocationActionSheetStateEmailParticipant)
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

#pragma mark -
#pragma mark MFMailComposeViewController Methods

- (void)presentMailModalViewController
{
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

- (void)userActionButtonPressedForParticipant:(Participant *)part
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

- (void)setPendingCountMeIn:(BOOL)countIn
{
    [[Controller sharedInstance] setEventAcceptanceForEvent:[Model sharedInstance].currentEvent didAccept:countIn];
}

#pragma mark - AddressBookTVCDataSource

- (NSArray *)dataForAddressBookLocationsTVC
{
    NSMutableArray *matchedContacts = [[[NSMutableArray alloc] init] autorelease];
    for (ABContact *abc in [ABContactsHelper contacts]) {
        NSArray *addressLabels = [abc addressLabels];
        NSArray *addressArray = [abc addressArray];
        for (int i=0; i<[[abc addressArray] count]; i++) {
            NSString *addressLabel = [addressLabels objectAtIndex:i];
            NSDictionary *addressDict = [addressArray objectAtIndex:i];
            Contact *c = [[Contact alloc] init];
            c.contactName = [abc getFormattedContactNameForAddressLabelType:addressLabel];
            c.streetAddress = [addressDict objectForKey:@"Street"];
            c.city = [addressDict objectForKey:@"City"];
            c.state = [addressDict objectForKey:@"State"];
            c.zip = [addressDict objectForKey:@"ZIP"];
            if (c.isValidAddress) [matchedContacts addObject:c];
            [c release];
        }
    }
    NSSortDescriptor *contactSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
	[matchedContacts sortUsingDescriptors:[NSArray arrayWithObjects:contactSortDescriptor, nil]];
    return matchedContacts;
}

#pragma mark - AddressBookLocationsTVCDelegate

- (void)addressBookLocationsTVCDidSelectAddress:(NSString *)anAddress withFriendlyName:(NSString *)friendlyName
{
    NSLog(@"search for: %@ with friendly name: %@", anAddress, friendlyName);
    [friendlyNameDict setValue:friendlyName forKey:anAddress];
    continueToSearchEnabled = NO;
    [self doShowSearchAgainButton:NO];
    [[ViewController sharedInstance] goBack];
    [self beginLocationSearchWithSearchString:anAddress andRemovePreviousResults:YES];
}

- (void)addressBookLocationsTVCDidSelectCurrentLocation
{
    BOOL locationServicesEnabled = [[LocationService sharedInstance] locationServicesEnabledInSystemPrefs];
        
    if (!locationServicesEnabled)
    {
        NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
        
        alertViewIsNoLocation = YES;
        UIAlertView *noLocFoundAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:(canOpenPrefs ? @"You have location services disabled. Would you like to open your location preferences?":@"You have location services disabled. Please enable them in your system settings.") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] autorelease];
        [noLocFoundAlert show];
        return;
    }
    
    
    continueToSearchEnabled = NO;
    [self doShowSearchAgainButton:NO];
    [[ViewController sharedInstance] goBack];
    
    MKUserLocation *myCLLoc = [mapView userLocation];
    if (myCLLoc.location.coordinate.latitude != 0)
    {
        [self beginCurrentLocationSearchWithCoordinate:myCLLoc.coordinate];
    }
    else
    {
        UIAlertView *noLocFoundAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Your location has not been detected yet. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [noLocFoundAlert show];
    }
}

- (void)searchCategoryTableDidSelectCurrentLocation
{
    BOOL locationServicesEnabled = [[LocationService sharedInstance] locationServicesEnabledInSystemPrefs];
    
    if (!locationServicesEnabled)
    {
        NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
        
        alertViewIsNoLocation = YES;
        
        UIAlertView *noLocFoundAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:(canOpenPrefs ? @"You have location services disabled. Would you like to open your location preferences?":@"You have location services disabled. Please enable them in your system settings.") delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] autorelease];
        [noLocFoundAlert show];
        return;
    }
    
    continueToSearchEnabled = NO;
    [self doShowSearchAgainButton:NO];
    
    MKUserLocation *myCLLoc = [mapView userLocation];
    if (myCLLoc.location.coordinate.latitude != 0)
    {
        [self beginCurrentLocationSearchWithCoordinate:myCLLoc.coordinate];
    }
    else
    {
        UIAlertView *noLocFoundAlert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Your location has not been detected yet. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [noLocFoundAlert show];
    }
}

#pragma mark - ActionSheetControllerDelegate

- (void)showModalDuplicateEventRequest
{
    [[ViewController sharedInstance] showModalDuplicateEvent:self withEvent:[Model sharedInstance].currentEvent];
}

- (void)removeEventRequest
{
    [[ViewController sharedInstance] goBackToDashboardFromAddLocations];
}

- (void)toggleEventDecidedStatus
{
    NSLog(@"AddLocation toggleEventDecidedStatus");
    [[Controller sharedInstance] toggleDecidedForCurrentEvent];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
    
    self.view.backgroundColor = [UIColor whiteColor];
    savedSearchResultsDict = [[NSMutableDictionary alloc] init];
    friendlyNameDict = [[NSMutableDictionary alloc] init];
    continueToSearchEnabled = false;
    annotationOpenCount = 0;
    searchBarShowing = false;
    [self setupMapView];
    [self setupInfoView];
    [self setupSearchBar];
    [self setupSearchCatView];
    
    
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getLocations] count];
    
    if (searchResults == 0 && ![[LocationService sharedInstance]locationServicesEnabledInSystemPrefs])
    {
        // location services are off in system preferences and there are no locations to zoom into
        [self doGoToSearchAndDetailState:SearchAndDetailStateNoLocation];
        currentState = AddLocationStateView;
    }
    else if (initState == AddLocationInitStateFromNewEvent)
    {
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
        currentState = AddLocationStateView;
    }
    else if (initState == AddLocationInitStateFromExistingEvent) // add location button
    {
        [self doGoToSearchAndDetailState:SearchAndDetailStateSearch];
        currentState = AddLocationStateSearch;
    }
    else if (initState == AddLocationInitStateFromExistingEventSelectedLocation) 
    {
        currentState = AddLocationStateView;
    }
    [self addSavedLocationAnnotations];
    
    [self.view setClipsToBounds:YES];
}

- (void)checkReportedLocations
{ 
    Event *detail = [Model sharedInstance].currentEvent;
    if (detail) {
        BOOL eventIsWithinTimeRange = detail.minutesToGoUntilEventStarts < (FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2) && detail.minutesToGoUntilEventStarts >  (-FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2);
        BOOL eventIsBeingCreated = detail.isTemporary;
        BOOL isRunningInForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
        // grab any users reported locations if in the window
        if (eventIsWithinTimeRange && !eventIsBeingCreated && isRunningInForeground) [[Controller sharedInstance] fetchReportedLocations];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_THIRTY_SECOND_TIMER_TICK object:nil];
    }
}

- (void)reportTimerTick
{ 
    Event *detail = [Model sharedInstance].currentEvent;
    if (detail) {
        if (!decidedShowing && detail.currentEventState >= EventStateDecided) {
            Event *detail = [Model sharedInstance].currentEvent;
            SearchAndDetailState state = (self.selectedLocationKey) ? SearchAndDetailStateDetail : SearchAndDetailStateNone; 
            NSLog(@"------------ SELECTED LOCATION ID = %@", self.selectedLocationKey);
            [self doGoToSearchAndDetailState:state];
            for (id <MKAnnotation> annotation in mapView.annotations) {
                MKAnnotationView *view = [mapView viewForAnnotation:annotation];
                if ([view.annotation isKindOfClass:[LocAnnotation class]]) {
                    LocAnnotation *placeMark = view.annotation;
                    if (placeMark.isSavedLocation) {
                        if (!placeMark.isEnabled) [placeMark setSelectedState:LocAnnoSelectedStateDefault];
                        Location *loc = [detail getLocationWithUUID:placeMark.uuid];
                        if ([detail.topLocationId isEqualToString:loc.locationId]) {
                            [placeMark setStateType:LocAnnoStateTypeDecided];
                        }
                        view.image = [placeMark imageForCurrentState];
                        view.enabled = YES;
                        if ([self.selectedLocationKey isEqualToString:placeMark.uuid]) {
                            [placeMark setSelectedState:LocAnnoSelectedStateSelected];
                            [locWidget updateInfoViewWithLocationAnnotation:placeMark];
                        }
                    }
                }
            }
            [self removeAnnotations:mapView includingSaved:false];
            [self doShowSearchAgainButton:NO];
            [self hideKeyboardResigner];
            [self disableSearchCategoryTable];
        }
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateMap;
    [[ViewController sharedInstance] showDropShadow:0];
    
    Model *model = [Model sharedInstance];
    if (feedShowing && model.currentEvent.currentEventState > EventStateNew) [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[model.currentEvent.unreadMessageCount intValue]];
    
    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesMovedCallback = ^(NSSet * touches, UIEvent * event) {
        if (!searchAgainButtonShowing && continueToSearchEnabled)
        {
            [self doShowSearchAgainButton:YES];
        }
    };
    if (mapView) [mapView addGestureRecognizer:tapInterceptor];
    
    [self setUpDataFetcherMessageListeners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportTimerTick) name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkReportedLocations) name:SYNCH_THIRTY_SECOND_TIMER_TICK object:nil];

    [self checkReportedLocations];
    
    [[NavigationSetter sharedInstance] setNavState:NavStateLocationAddSearchOn withTarget:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!feedShowing) [self doShowSearchAgainButton:NO];
    
    [self removeDataFetcherMessageListeners];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SYNCH_THIRTY_SECOND_TIMER_TICK object:nil];
    
    tapInterceptor.touchesMovedCallback = nil;
    [mapView removeGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
