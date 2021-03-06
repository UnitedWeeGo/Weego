//
//  ActionSheetController.m
//  Weego
//
//  Created by Dave Prukop on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoreButtonActionSheetController.h"
#import "Event.h"

@interface MoreButtonActionSheetController (Private)

- (void)pickDateTime;
- (void)datePickerDoneClick:(id)sender;
- (void)presentRemoveEventAlert;

@end

@implementation MoreButtonActionSheetController

@synthesize delegate;

static MoreButtonActionSheetController *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (MoreButtonActionSheetController *)sharedInstance:(id <MoreButtonActionSheetControllerDelegate>)aDelegate {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[MoreButtonActionSheetController alloc] init];       
    }
    sharedInstance.delegate = aDelegate;
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton MoreButtonActionSheetController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - UIActionSheet
- (void)showActionSheetForMorePress
{
    Model *model = [Model sharedInstance];
    Event *detail = model.currentEvent;
    NSString *title = @"";;
    UIActionSheet *userOptions;
    
    shouldAddEventDecidedToggle = detail.iOwnEvent && detail.currentEventState < EventStateEnded && model.currentViewState == ViewStateDetails;
    
    userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    if (shouldAddEventDecidedToggle) [userOptions addButtonWithTitle: detail.forcedDecided || detail.currentEventState >= EventStateDecided ? @"Open Voting" : @"Close Voting"];
    
    if (detail.currentEventState == EventStateNew)
    {
        currentActionSheetState = ActionSheetStateMorePressEventTrial;
        title = @"Remove this event from your dashboard";
        [userOptions addButtonWithTitle:@"Remove Event"];
        [userOptions addButtonWithTitle:@"Cancel"];
        userOptions.destructiveButtonIndex = 0 + (shouldAddEventDecidedToggle ? 1 : 0);
        userOptions.cancelButtonIndex = 1 + (shouldAddEventDecidedToggle ? 1 : 0);
    }
    else if (detail.currentEventState < EventStateDecided) 
    {
        switch (detail.acceptanceStatus) {
            case AcceptanceTypePending:
                currentActionSheetState = ActionSheetStateMorePressEventVotingPending;
                title = @"Let the group know if you are coming or not, or if there is a better time for you. If you decline the event you will not receive any updates from the group.";
                
                [userOptions addButtonWithTitle:@"Count Me In!"];
                [userOptions addButtonWithTitle:@"I'm Not Coming"];
                [userOptions addButtonWithTitle:@"Suggest a New Time"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                userOptions.destructiveButtonIndex = 3 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 4 + (shouldAddEventDecidedToggle ? 1 : 0);
                
                break;
            case AcceptanceTypeAccepted:
                currentActionSheetState = ActionSheetStateMorePressEventVotingAccepted;
                title = @"Let the group know that you are not going to make it, or if there is a better time for you. If you decline the event you will not receive any updates from the group.";
                
                [userOptions addButtonWithTitle:@"I'm Not Coming"];
                [userOptions addButtonWithTitle:@"Suggest a New Time"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                
                userOptions.destructiveButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 3 + (shouldAddEventDecidedToggle ? 1 : 0);
                break;
            case AcceptanceTypeDeclined:
                currentActionSheetState = ActionSheetStateMorePressEventVotingDeclined;
                title = @"Let the group know you decided to come, or if there is a better time for you.";                
                
                [userOptions addButtonWithTitle:@"Count Me In!"];
                [userOptions addButtonWithTitle:@"Suggest a New Time"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                
                userOptions.destructiveButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 3 + (shouldAddEventDecidedToggle ? 1 : 0);
                break;
            default:
                break;
        }
    }
    else if (detail.currentEventState == EventStateDecided || detail.currentEventState == EventStateStarted)
    {
        switch (detail.acceptanceStatus) {
            case AcceptanceTypePending:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedPending;
                title = @"Let the group know if you are coming or not. If you decline the event you will not receive any updates from the group.";
                
                [userOptions addButtonWithTitle:@"Count Me In!"];
                [userOptions addButtonWithTitle:@"I'm Not Coming"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                
                userOptions.destructiveButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 3 + (shouldAddEventDecidedToggle ? 1 : 0);
                break;
            case AcceptanceTypeAccepted:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedAccepted;
                title = @"Let the group know that you are not going to make it. If you decline the event you will not receive any updates from the group.";
                
                [userOptions addButtonWithTitle:@"I'm Not Coming"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                
                userOptions.destructiveButtonIndex = 1 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
                
                break;
            case AcceptanceTypeDeclined:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedDeclined;
                title = @"Let the group know you decided to come!";
                
                [userOptions addButtonWithTitle:@"Count Me In!"];
                [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
                [userOptions addButtonWithTitle:@"Cancel"];
                
                userOptions.destructiveButtonIndex = 1 + (shouldAddEventDecidedToggle ? 1 : 0);
                userOptions.cancelButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
                break;
            default:
                break;
        }
    }
    else if (detail.currentEventState == EventStateEnded)
    {
        currentActionSheetState = ActionSheetStateMorePressEventEnded;
        title = @"Remove this event from your dashboard, or create a new event with the same group and locations.";        
        
        [userOptions addButtonWithTitle:@"Duplicate Event"];
        [userOptions addButtonWithTitle:detail.iOwnEvent && detail.currentEventState < EventStateEnded ? @"Cancel Event" : @"Remove Event"];
        [userOptions addButtonWithTitle:@"Cancel"];
        
        userOptions.destructiveButtonIndex = 1 + (shouldAddEventDecidedToggle ? 1 : 0);
        userOptions.cancelButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
    }
    else if (detail.currentEventState == EventStateCancelled)
    {
        currentActionSheetState = ActionSheetStateMorePressEventCancelled;
        title = @"Remove this event from your dashboard, or create a new event with the same group and locations.";
        
        [userOptions addButtonWithTitle:@"Duplicate Event"];
        [userOptions addButtonWithTitle:@"Remove Event"];
        [userOptions addButtonWithTitle:@"Cancel"];
        
        userOptions.destructiveButtonIndex = 1 + (shouldAddEventDecidedToggle ? 1 : 0);
        userOptions.cancelButtonIndex = 2 + (shouldAddEventDecidedToggle ? 1 : 0);
    }
    
    //[userOptions setTitle:title];
    
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

- (void)showUserActionSheetForUser:(Participant *)part
{
    shouldAddEventDecidedToggle = NO;
    currentActionSheetState = ActionSheetStateEmailParticipant;
    NSString *title = [NSString stringWithFormat:@"How would you like to contact %@?", part.fullName];
    UIActionSheet *userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Email", nil];
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

- (void)showUserActionSheetForReview
{
    currentActionSheetState = ActionSheetStateReview;
    UIActionSheet *userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View on yelp.com", nil];
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (currentActionSheetState == ActionSheetStateReview)
    {
        switch (buttonIndex) {
            case 0:
                [delegate goToYelpReviewPage];
                break;
            case 1:
                //
                break;
                
            default:
                break;
        }
        return;
    }
    
    switch ( buttonIndex - (shouldAddEventDecidedToggle ? 1 : 0) ) {
        case -1:
            [delegate toggleEventDecidedStatus];
            break;
        case 0:
            //ActionSheetStateMorePressEventVotingPending, ActionSheetStateMorePressEventVotingDeclined, ActionSheetStateMorePressEventDecidedPending, ActionSheetStateMorePressEventDecidedDeclined - count me in
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending || currentActionSheetState == ActionSheetStateMorePressEventDecidedDeclined)
            {
                [delegate setPendingCountMeIn:YES];
                delegate = nil;
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventDecidedAccepted - count me out
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventDecidedAccepted)
            {
                [delegate setPendingCountMeIn:NO];
                delegate = nil;
            }
            else if (currentActionSheetState == ActionSheetStateMorePressEventEnded || currentActionSheetState == ActionSheetStateMorePressEventCancelled) // Duplicate Event
            {
                [delegate showModalDuplicateEventRequest];
                delegate = nil;
            }
            else if (currentActionSheetState == ActionSheetStateEmailParticipant) // email modal
            {
                [delegate presentMailModalViewControllerRequested];
                delegate = nil;
            }
            else if (currentActionSheetState == ActionSheetStateMorePressEventTrial) // email modal
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 1:
            // ActionSheetStateMorePressEventVotingPending, ActionSheetStateMorePressEventDecidedPending - im not coming
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending)
            {
                [delegate setPendingCountMeIn:NO];
                delegate = nil;
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventVotingDeclined - suggest new time
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined)
            {
                [self pickDateTime];
            }
            // -- cancel do nothing
            else if (currentActionSheetState == ActionSheetStateEmailParticipant)
            {
                //
            }
            // ActionSheetStateMorePressEventDecidedAccepted, ActionSheetStateMorePressEventDecidedDeclined - Remove Event
            else if (currentActionSheetState == ActionSheetStateMorePressEventDecidedAccepted || currentActionSheetState == ActionSheetStateMorePressEventDecidedDeclined || currentActionSheetState >= ActionSheetStateMorePressEventEnded)
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 2:
            // ActionSheetStateMorePressEventVotingPending - suggest new time
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending)
            {
                [self pickDateTime];
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventVotingDeclined, ActionSheetStateMorePressEventDecidedPending - Remove Event
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending)
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 3:
            //ActionSheetStateMorePressEventVotingPending Remove Event
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending)
            {
                [self presentRemoveEventAlert];
            }
            break;   
        default:
            break;
    }
}

- (void)presentRemoveEventAlert
{
    NSLog(@"Present remove/Cancel Event alert");
    
    Event *detail = [Model sharedInstance].currentEvent;
    NSString *title = detail.iOwnEvent && detail.currentEventState < EventStateEnded && currentActionSheetState != ActionSheetStateMorePressEventTrial? @"Cancel Event?" : @"Remove Event?";
    NSString *standardMessage = [NSString stringWithFormat:@"Removing this event will remove it from your dashboard", detail.currentEventState <= EventStateDecided ? @"." : @" and \"Count you out\"."];
    NSString *ownerMessage = @"Are you sure you want to cancel this event?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:(detail.iOwnEvent && detail.currentEventState < EventStateEnded && currentActionSheetState != ActionSheetStateMorePressEventTrial ? ownerMessage:standardMessage) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    
    
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Event *detail = [Model sharedInstance].currentEvent;
    if (buttonIndex == 1)
    {
        if (currentActionSheetState != ActionSheetStateMorePressEventTrial)
        {
            if (detail.iOwnEvent && detail.currentEventState < EventStateEnded)
            {
                //NSLog(@"count out:YES Cancel Event:YES");
                [[Controller sharedInstance] setRemovedForEvent:detail doCountOut:YES doCancel:YES];
            }
            else
            {
                //NSLog(@"count out:%d Cancel Event:NO", detail.currentEventState <= EventStateDecided);
                [[Controller sharedInstance] setRemovedForEvent:detail doCountOut:(detail.currentEventState <= EventStateDecided) doCancel:NO];
                detail.hasBeenRemoved = YES;
                [delegate removeEventRequest];
                delegate = nil;
            }
        }
        else if (currentActionSheetState == ActionSheetStateMorePressEventTrial)
        {
            detail.hasBeenRemoved = YES;
            [delegate removeEventRequest];
            delegate = nil;
        }
    }
}

#pragma mark -
#pragma mark Date Picker Methods

- (void)pickDateTime
{
    Event *detail = [Model sharedInstance].currentEvent;
    
    if (suggestedDate != nil) [suggestedDate release];
    suggestedDate = [detail.eventDate copy];
    
	SEL changeSelector = @selector(setNewDateTime:);
	int pickerMode = UIDatePickerModeDateAndTime;
    
	dateActionSheet = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerDateToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(datePickerCancelClick:)];
    [barItems addObject:cancelBtn];
    [cancelBtn release];
    
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
    [flexSpace release];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClick:)];
	[barItems addObject:doneBtn];
    [doneBtn release];
    
	
	[pickerDateToolbar setItems:barItems animated:YES];
    [barItems release];
	
	[dateActionSheet addSubview:pickerDateToolbar];
    [pickerDateToolbar release];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 325, 250)];
	datePicker.datePickerMode = pickerMode;
	datePicker.hidden = NO;
    
    int minuteInterval = 5;
    NSDate *now = [NSDate date];
	datePicker.minuteInterval = minuteInterval;
    NSTimeInterval nextAllowedMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / (60 * minuteInterval)) * (60 * minuteInterval); // Current time rounded up to the nearest minuteInterval
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextAllowedMinuteInterval];
    datePicker.minimumDate = minimumDate;
    
	datePicker.date = detail.eventDate;
    
	[datePicker addTarget:self
	               action:changeSelector
	     forControlEvents:UIControlEventValueChanged];
	[dateActionSheet addSubview:datePicker];
	[datePicker release];
	
    [dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
	[dateActionSheet setBounds:CGRectMake(0,0,320, 464)];
    [dateActionSheet release];
}

- (void)datePickerDoneClick:(id)sender
{
    Event *detail = [Model sharedInstance].currentEvent;
    if ([detail.eventDate compare:suggestedDate] == NSOrderedSame) return; //exit if suggested date is same as current date
    
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSString *suggestedTimeString = [NSDate stringFromDate:suggestedDate withFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //NSLog(@"suggestedTimeString: %@", suggestedTimeString);
    [[Controller sharedInstance] suggestTimeForEvent:detail withSuggestedTime:suggestedTimeString];
    delegate = nil;
}

- (void)datePickerCancelClick:(id)sender
{
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    delegate = nil;
}

- (void)setNewDateTime:(id)sender
{
    if (suggestedDate != nil) [suggestedDate release];
    suggestedDate = [datePicker.date retain];
    
}

@end
