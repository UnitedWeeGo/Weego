//
//  ActionSheetController.h
//  Weego
//
//  Created by Dave Prukop on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Participant.h"

typedef enum {
	ActionSheetStateMorePressEventVotingPending = 0,
    ActionSheetStateMorePressEventVotingAccepted,
    ActionSheetStateMorePressEventVotingDeclined,
    ActionSheetStateMorePressEventDecidedPending,
    ActionSheetStateMorePressEventDecidedAccepted,
    ActionSheetStateMorePressEventDecidedDeclined,
    ActionSheetStateMorePressEventTrial,
    ActionSheetStateMorePressEventEnded,
    ActionSheetStateMorePressEventCancelled,
	ActionSheetStateEmailParticipant
} ActionSheetState;

@protocol MoreButtonActionSheetControllerDelegate <NSObject>

- (void)showModalDuplicateEventRequest;
- (void)removeEventRequest;
- (void)toggleEventDecidedStatus;

@optional
- (void)setPendingCountMeIn:(BOOL)countIn;
- (void)presentMailModalViewControllerRequested;

@end

@interface MoreButtonActionSheetController : NSObject <UIActionSheetDelegate> {
    //NSString *pendingCountMeInFetchRequestId;
    ActionSheetState currentActionSheetState;
    UIActionSheet *dateActionSheet;
    UIDatePicker *datePicker;
    NSDate *suggestedDate;
    BOOL alertViewShowing;
    BOOL shouldAddEventDecidedToggle;
}

@property (nonatomic, assign) id <MoreButtonActionSheetControllerDelegate> delegate;

+ (MoreButtonActionSheetController *)sharedInstance:(id <MoreButtonActionSheetControllerDelegate>)aDelegate;
+ (void)destroy;

- (void)showActionSheetForMorePress;
- (void)showUserActionSheetForUser:(Participant *)part;

@end
