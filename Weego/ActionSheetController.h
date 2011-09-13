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

@protocol ActionSheetControllerDelegate <NSObject>

- (void)showModalDuplicateEventRequest;
- (void)removeEventRequest;

@optional
- (void)setPendingCountMeInFetchRequestId:(NSString *)requestId;
- (void)presentMailModalViewControllerRequested;

@end

@interface ActionSheetController : NSObject <UIActionSheetDelegate> {
    //NSString *pendingCountMeInFetchRequestId;
    ActionSheetState currentActionSheetState;
    UIActionSheet *dateActionSheet;
    UIDatePicker *datePicker;
    NSDate *suggestedDate;
    BOOL alertViewShowing;
}

@property (nonatomic, assign) id <ActionSheetControllerDelegate> delegate;

+ (ActionSheetController *)sharedInstance:(id <ActionSheetControllerDelegate>)aDelegate;
+ (void)destroy;

- (void)showActionSheetForMorePress;
- (void)showUserActionSheetForUser:(Participant *)part;

@end
