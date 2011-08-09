//
//  MessageEntryWidget.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageEntryWidget.h"
#import "FeedMessage.h"

@interface MessageEntryWidget (Private)
- (void)setupUI;
- (void)setupEntryFieldBackground;
- (void)setupEntryFieldTextView;
- (void)setupDefaultTextLabel;
- (void)setupBeginEditingButton;
- (void)setupSendButton;
- (void)setupEmptySendButton;
- (void)setupCharCountTextLabel;
- (void)handleSendPress:(id)sender;
- (void)setSendAndCountVisible;
- (void)setSendAndCountHidden;
@end

@implementation MessageEntryWidget
@synthesize delegate;

const int closedInputHeight = 45;
const int openInputHeight = 120;
const int maxMessageChars = 140;

const CGRect MessageEntryBackgroundFrameClosedRect = { { 5.0f, 7.0f }, { 310.0f, 31.0f } };
const CGRect MessageEntryBackgroundFrameOpenRect = { { 5.0f, 7.0f }, { 310.0f, 62.0f } };

const CGRect MessageEntryTextViewClosedFrame = { { 5.0f, 9.0f }, { 310.0f, 24.0f } };
const CGRect MessageEntryTextViewOpenFrame = { { 5.0f, 9.0f }, { 310.0f, 57.0f } };

const CGRect DefaultTextLabelFrame = { { 12.0f, 13.0f }, { 310.0f, 24.0f } };
const CGRect MaxCharsTextLabelFrame = { { 230.0f, 85.0f }, { 0.0f, 0.0f } };

- (id)initWithFrame:(CGRect)frame
{
    MessageEntryWidgetFrameClosedRect = CGRectMake(0, 0, 320.0f, closedInputHeight);
    MessageEntryWidgetFrameOpenRect = CGRectMake(0, 0, 320.0f, openInputHeight);
    
    self = [super initWithFrame:MessageEntryWidgetFrameClosedRect];
    if (self) {
        currentState = MessageEntryStateClosed;
        [self setupUI];
    }
    return self;
}
#pragma mark - UI Setup
- (void)setupUI
{
    self.backgroundColor = HEXCOLOR(0xE4E4E4FF);
    [self setupEntryFieldBackground];
    [self setupEntryFieldTextView];
    [self setupDefaultTextLabel];
    [self setupBeginEditingButton];
    [self setupSendButton];
    [self setupEmptySendButton];
    [self setupCharCountTextLabel];
}
- (void)setupSendButton
{
    UIImage *bg1;
    UIImage *bg2;
        
    bg1 = [UIImage imageNamed:@"button_green_default.png"];
    bg2 = [UIImage imageNamed:@"button_green_pressed.png"];
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.adjustsImageWhenHighlighted = NO;
    [sendButton addTarget:self action:@selector(handleSendPress:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundImage:bg1 forState:UIControlStateNormal];
    [sendButton setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:bg2 forState:UIControlStateDisabled];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    UIColor *col = HEXCOLOR(0xFFFFFFFF);    
    [sendButton setTitleColor:col forState:UIControlStateNormal];
    
    sendButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    UIColor *shadowColor = HEXCOLOR(0x33333333);
    sendButton.titleLabel.shadowColor = shadowColor;
    sendButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    sendButton.contentEdgeInsets = UIEdgeInsetsMake(4, 2, 0, 0);
    sendButton.frame = CGRectMake(265, 76, bg1.size.width, bg1.size.height);
    sendButton.hidden = YES;
    [self addSubview:sendButton];
}
- (void)setupEmptySendButton
{
    UIImage *bg1;
    bg1 = [UIImage imageNamed:@"button_green_pressed.png"];
    emptySendButton.enabled = NO;
    emptySendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptySendButton setBackgroundImage:bg1 forState:UIControlStateNormal];
    [emptySendButton setBackgroundImage:bg1 forState:UIControlStateDisabled];
    emptySendButton.frame = CGRectMake(265, 76, bg1.size.width, bg1.size.height);
    emptySendButton.hidden = YES;
    [self addSubview:emptySendButton];
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.frame = CGRectMake(15, 5, 20.0f, 20.0f); //50x31
    [emptySendButton addSubview:view];
    _activityView = view;
    [view release];
}
- (void)setupEntryFieldBackground
{
    UIImage *entryFieldBackground = [[UIImage imageNamed:@"inputfield_search_default.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    entryFieldBackgroundView = [[[UIImageView alloc] initWithImage:entryFieldBackground] autorelease];
    entryFieldBackgroundView.frame = MessageEntryBackgroundFrameClosedRect;
    entryFieldBackgroundView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:entryFieldBackgroundView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, MessageEntryWidgetFrameClosedRect.size.height-1, self.bounds.size.width, 1)];
    lineView.backgroundColor = HEXCOLOR(0xCCCCCCFF);
    [self addSubview:lineView];
    [lineView release];
}
- (void)setupEntryFieldTextView
{
    entryField = [[[CustomUITextView alloc] initWithFrame:MessageEntryTextViewClosedFrame] autorelease];
    entryField.backgroundColor = [UIColor clearColor];
    entryField.delegate = self; // to be used later when we auto-resize stuff
    entryField.textColor = HEXCOLOR(0x333333FF);
	entryField.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    entryField.scrollsToTop = NO;
    entryField.returnKeyType = UIReturnKeySend;
    [self addSubview:entryField];
}
- (void)setupDefaultTextLabel
{
    defaultTextLabel = [[[UILabel alloc] initWithFrame:DefaultTextLabelFrame] autorelease];
    defaultTextLabel.backgroundColor = [UIColor clearColor];
    defaultTextLabel.textColor = HEXCOLOR(0x33333355);
	defaultTextLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    defaultTextLabel.text = @"Send a message";
    [self addSubview:defaultTextLabel];
}
- (void)setupCharCountTextLabel
{
    charCountTextLabel = [[[UILabel alloc] initWithFrame:MaxCharsTextLabelFrame] autorelease];
    charCountTextLabel.backgroundColor = [UIColor clearColor];
    charCountTextLabel.textColor = HEXCOLOR(0x33333355);
	charCountTextLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
    charCountTextLabel.text = [NSString stringWithFormat:@"%d", maxMessageChars];
    charCountTextLabel.textAlignment = UITextAlignmentRight;
    charCountTextLabel.hidden = YES;
    [charCountTextLabel sizeToFit];
    [self addSubview:charCountTextLabel];
}
- (void)setupBeginEditingButton
{
    beginEditingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beginEditingButton.frame = MessageEntryWidgetFrameClosedRect;
    beginEditingButton.backgroundColor = HEXCOLOR(0xFF000000);
    [beginEditingButton addTarget:self action:@selector(beginEditingHandler) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:beginEditingButton];
}
- (void)beginEditingHandler
{
    [entryField becomeFirstResponder];
    [self transitionToState:MessageEntryStateEditing];
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [self handleSendPress:self];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength > maxMessageChars) return FALSE;
    
    charCountTextLabel.text = [NSString stringWithFormat:@"%d", maxMessageChars-newLength];
    return TRUE;
}

#pragma mark - Event handlers
- (void)handleSendPress:(id)sender
{
    if ([entryField.text length] == 0) return;
    [self transitionToState:MessageEntryStateSending];
    FeedMessage *feedMessage = [[[FeedMessage alloc] init] autorelease];
    feedMessage.message = entryField.text;
    feedMessage.imageURL = @"";
    [[Controller sharedInstance] sendFeedMessage:feedMessage];
    NSLog(@"Send message: %@", entryField.text);
}

#pragma mark - UI Transitions
- (void)transitionToState:(MessageEntryState)state
{
    [delegate messageEntryWidgetStateChangedToState:state];
    
    CGRect widgetFrame;
    CGRect entryBackgroundFrame;
    CGRect entryFieldFrame;
    float defaultTextLabelAlpha;
    int newLineViewY;
    
    switch (state) {
        case MessageEntryStateClosed:
            [entryField resignFirstResponder];
            widgetFrame = MessageEntryWidgetFrameClosedRect;
            entryBackgroundFrame = MessageEntryBackgroundFrameClosedRect;
            entryFieldFrame = MessageEntryTextViewClosedFrame;
            beginEditingButton.hidden = NO;
            [entryField setContentOffset:CGPointMake(0, 2) animated:YES];
            [self setSendAndCountHidden];
            emptySendButton.hidden = YES;
            defaultTextLabelAlpha = [entryField.text length] > 0 ? 0.0f : 1.0f;
            newLineViewY = MessageEntryWidgetFrameClosedRect.size.height - 1;
            [_activityView stopAnimating];
            break;
        case MessageEntryStateEditing:
            widgetFrame = MessageEntryWidgetFrameOpenRect;
            entryBackgroundFrame = MessageEntryBackgroundFrameOpenRect;
            entryFieldFrame = MessageEntryTextViewOpenFrame;
            beginEditingButton.hidden = YES;
            [self performSelector:@selector(setSendAndCountVisible) withObject:self afterDelay:.3];
            emptySendButton.hidden = YES;
            defaultTextLabelAlpha = 0;
            newLineViewY = MessageEntryWidgetFrameOpenRect.size.height - 1;
            [_activityView stopAnimating];
            break;
        case MessageEntryStateSending:
            widgetFrame = MessageEntryWidgetFrameOpenRect;
            entryBackgroundFrame = MessageEntryBackgroundFrameOpenRect;
            entryFieldFrame = MessageEntryTextViewOpenFrame;
            beginEditingButton.hidden = YES;
            sendButton.hidden = YES;
            emptySendButton.hidden = NO;
            defaultTextLabelAlpha = 0;
            newLineViewY = MessageEntryWidgetFrameOpenRect.size.height - 1;
            [_activityView startAnimating];
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.30f 
                          delay:0.0f 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         self.frame = widgetFrame;
                         entryFieldBackgroundView.frame = entryBackgroundFrame;
                         entryField.frame = entryFieldFrame;
                         defaultTextLabel.alpha = defaultTextLabelAlpha;
                         lineView.frame = CGRectMake(0, newLineViewY, self.bounds.size.width, 1);
                     }
                     completion:NULL];
}

- (void)setSendAndCountVisible
{
    charCountTextLabel.hidden = NO;
    sendButton.hidden = NO;
}

- (void)setSendAndCountHidden
{
    charCountTextLabel.hidden = YES;
    sendButton.hidden = YES;
}

- (void)resetAfterSendSuccess
{
    entryField.text = @"";
    charCountTextLabel.text = [NSString stringWithFormat:@"%d", maxMessageChars];
    [self transitionToState:MessageEntryStateClosed];
}

- (void)resetAfterSendFailure
{
    [self transitionToState:MessageEntryStateEditing];
}

- (void)dealloc
{
    //
    [super dealloc];
}

@end

//inputfield_search_default.png