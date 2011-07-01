//
//  MessageEntryWidget.h
//  BigBaby
//
//  Created by Nicholas Velloff on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUITextView.h"

typedef enum {
	MessageEntryStateClosed = 0,
	MessageEntryStateEditing,
    MessageEntryStateSending
} MessageEntryState;

@protocol MessageEntryWidgetDelegate
-(void) messageEntryWidgetStateChangedToState:(MessageEntryState)state;
@end

@interface MessageEntryWidget : UIView <UITextViewDelegate> {
    MessageEntryState currentState;
    UIImageView *entryFieldBackgroundView;
    UIView *lineView;
    CustomUITextView *entryField;
    UIButton *beginEditingButton;
    UIButton *sendButton;
    UIButton *emptySendButton;
    UILabel *defaultTextLabel;
    UILabel *charCountTextLabel;
    UIActivityIndicatorView *_activityView;
    
    CGRect MessageEntryWidgetFrameClosedRect;
    CGRect MessageEntryWidgetFrameOpenRect;
}

@property (nonatomic,assign) id <MessageEntryWidgetDelegate> delegate;

- (void)transitionToState:(MessageEntryState)state;
- (void)resetAfterSendSuccess;

@end
