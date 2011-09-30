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
#import "MoreButtonActionSheetController.h"
#import "CellFriendsLocations.h"

//typedef enum {
//	ActionSheetStateMorePressEventVotingPending = 0,
//    ActionSheetStateMorePressEventVotingAccepted,
//    ActionSheetStateMorePressEventVotingDeclined,
//    ActionSheetStateMorePressEventDecidedPending,
//    ActionSheetStateMorePressEventDecidedAccepted,
//    ActionSheetStateMorePressEventDecidedDeclined,
//    ActionSheetStateMorePressEventTrial,
//    ActionSheetStateMorePressEventEnded,
//    ActionSheetStateMorePressEventCancelled,
//	ActionSheetStateEmailParticipant
//} ActionSheetState;

@class Event;
@class DataFetcher;

@interface EventDetailTVC : UITableViewController <EGORefreshTableHeaderDelegate, SubViewLocationDelegate, HeaderViewDetailsEventDelegate, DataFetcherMessageHandler, UIActionSheetDelegate, MFMailComposeViewControllerDelegate ,UIAlertViewDelegate, MoreButtonActionSheetControllerDelegate> {
    Event *detail;
    HeaderViewDetailsEvent *tableHeaderView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL initialLoadFinished;
    BOOL _reloading;
    BOOL otherLocationsShowing;
    BOOL otherParticipantsShowing;
    int rowsForLocations;
    NSArray *oldSortedLocations;
    NSArray *currentSortedLocations;
    NSString *pendingCountMeInFetchRequestId;
//    ActionSheetState currentActionSheetState;
    Participant *pendingMailParticipant;
//    UIActionSheet *dateActionSheet;
//	UIDatePicker *datePicker;
//    NSDate *suggestedDate;
//    BOOL alertViewShowing;
    NSArray *originalIVotedFor;
    BOOL hasBeenCancelled;
    UIView *bevelStripe;
    CellFriendsLocations *friendsLocationsCell;
    
    BOOL inDecidedState;
}

@end
