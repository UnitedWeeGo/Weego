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
	LocationActionSheetStateWinnerWithPhone = 0,
    LocationActionSheetStateWinnerWithoutPhone,
	LocationActionSheetStateEmailParticipant
} LocationActionSheetState;

@class DataFetcher;

@interface AddLocation : UIViewController <MKMapViewDelegate, UISearchBarDelegate, LocationDetailWidgetDelegate, DataFetcherMessageHandler, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    MKMapView *mapView;
    LocationDetailWidget *locWidget;
    UISearchBar *searchBar;
    Boolean searchBarShowing;
    NSMutableArray *savedSearchResults;
    int selectedSearchLocationIndex;
    int selectedLocationIndex;
    AddLocationInitState initState;
    AddLocationState currentState;
    UIButton *keyboardResigner;
    Boolean userLocationFound;
    int annotationOpenCount;
    NSString *selectedLocationId;
    BOOL isAddingLocation;
    
    NSString *googlePlacesFetchId;
    NSString *googleGeoFetchId;
    NSString *simpleGeoFetchId;
    
    NSString *pendingSearchString;
    Participant *participantSelectedOnMap;
    LocationActionSheetState locationActionSheetState;
    Location *winningLocationSelected;
}

- (id)initWithState:(AddLocationInitState)state;
- (id)initWithLocationOpen:(NSString *)locId;

@end