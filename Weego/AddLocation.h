//
//  AddLocation.h
//  BigBaby
//
//  Created by Nicholas Velloff on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDetailWidget.h"
#include <stdlib.h>
#import <MessageUI/MessageUI.h>
#import "Location.h"
#import "SearchCategoryTable.h"
#import "WildcardGestureRecognizer.h"
#import "SubViewSearchBar.h"
#import "AddressBookLocationsTVC.h"
#import "MoreButtonActionSheetController.h"

typedef enum {
	AddLocationInitStateFromExistingEvent = 0,
    AddLocationInitStateFromExistingEventSelectedLocation,
    AddLocationInitStateFromNewEvent
} AddLocationInitState;

typedef enum {
	AddLocationStateSearch = 0,
	AddLocationStateView
} AddLocationState;

typedef enum {
	LocationActionSheetStateEmailParticipant = 0
} LocationActionSheetState;

@class DataFetcher;

@interface AddLocation : UIViewController <MKMapViewDelegate, LocationDetailWidgetDelegate, DataFetcherMessageHandler, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, SearchCategoryTableDelegate, SubViewSearchBarDelegate, AddressBookLocationsTVCDelegate, AddressBookLocationsTVCDataSource, UIAlertViewDelegate, MoreButtonActionSheetControllerDelegate> {
    MKMapView *mapView;
    LocationDetailWidget *locWidget;
    //UISearchBar *searchBar;
    SubViewSearchBar *searchBar;
    Boolean searchBarShowing;
    
    
//    NSMutableArray *savedSearchResults;
    NSMutableDictionary *savedSearchResultsDict;
    
    WildcardGestureRecognizer * tapInterceptor;
//    int selectedSearchLocationIndex;
//    int selectedLocationIndex;
    
    AddLocationInitState initState;
    AddLocationState currentState;
    UIButton *keyboardResigner;
    Boolean userLocationFound;
    Boolean alreadyZoomedToShowOthersLocations;
    Boolean alreadyZoomedToShowUserLocation;
    int annotationOpenCount;
    NSString *selectedLocationId;
    BOOL isAddingLocation;
    
    NSString *googlePlacesFetchId;
    NSString *googleGeoFetchId;
    NSString *genericSearchFetchId;
    
    NSString *pendingSearchString;
    Participant *participantSelectedOnMap;
    LocationActionSheetState locationActionSheetState;
    
    BOOL continueToSearchEnabled;
    SearchCategoryTable *categoryTable;
    SearchCategory *pendingSearchCategory;
    BOOL searchAgainButtonShowing;
    
    NSMutableDictionary *friendlyNameDict;
    
    BOOL feedShowing;
    
//    NSArray *allContactsWithAddress;
    
    BOOL alertViewShowing;
    BOOL alertViewIsNoLocation;
    
    BOOL decidedShowing;
}

@property (nonatomic, copy) NSString *selectedSearchLocationKey;
@property (nonatomic, copy) NSString *selectedLocationKey;

- (id)initWithState:(AddLocationInitState)state;
- (id)initWithLocationOpen:(NSString *)locId;

@end