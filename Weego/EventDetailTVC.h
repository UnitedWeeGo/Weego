//
//  EventDetailTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderViewDetailsEvent.h"
#import "EGORefreshTableHeaderView.h"
#import "SubViewLocation.h"

typedef enum {
	ActionSheetStateMorePressEventPending = 0,
    ActionSheetStateMorePressEventAccepted,
    ActionSheetStateMorePressEventDecided,
	ActionSheetStateEmailParticipant
} ActionSheetState;

@class Event;
@class DataFetcher;

@interface EventDetailTVC : UITableViewController <EGORefreshTableHeaderDelegate, SubViewLocationDelegate, HeaderViewDetailsEventDelegate, DataFetcherMessageHandler, UIActionSheetDelegate, MFMailComposeViewControllerDelegate ,UIAlertViewDelegate> {
    Event *detail;
    HeaderViewDetailsEvent *tableHeaderView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL otherLocationsShowing;
    BOOL otherParticipantsShowing;
    int rowsForLocations;
    NSArray *oldSortedLocations;
    NSArray *currentSortedLocations;
    NSString *pendingCountMeInFetchRequestId;
    ActionSheetState currentActionSheetState;
    Participant *pendingMailParticipant;
}

@end
