//
//  DealsView.m
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealsView.h"
#import "NSDate+Helper.h"

@interface DealsView (Private)

- (void)showLoading;
- (void)hideLoading;
- (void)showContent:(NSString *)html;
- (void)showError;
- (void)showAlertWithCode:(int)code;
- (void)pickDateTime;

@end

@implementation DealsView

@synthesize SGID;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    
    Event *event = [Model sharedInstance].currentEvent;
    
    BOOL shouldShowTimeSelector  = event.currentEventState == EventStateVoting || event.currentEventState == EventStateVotingWarning;
    
    [[NavigationSetter sharedInstance] setNavState:(shouldShowTimeSelector ? NavStateDealsWithTimeAvailability : NavStateDeals) withTarget:self];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self];
    
    [[ViewController sharedInstance] showDropShadow:0];
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.view addSubview:bevelStripe];
    [bevelStripe release];
        
    shader = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
    shader.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    [self.view addSubview:shader];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(150, 185, 20, 20);
    [self.view addSubview:spinner];
    
    [self showLoading];
    
    [self setUpDataFetcherMessageListeners];
    [[Controller sharedInstance] getDealsHTMLDataWithSGID:self.SGID];
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

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    switch (fetchType) {
        case DataFetchTypeDeal:
            [self hideLoading];
            break;
            
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeDeal: 
            [self showError];
            [self showAlertWithCode:errorType];
            break;
            
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showLoading
{
    [spinner startAnimating];
}

- (void)hideLoading
{
    [spinner stopAnimating];
    NSString *htmlContent = [Model sharedInstance].dealResults;
    [self showContent:htmlContent];
}

- (void)showError
{
    [spinner stopAnimating];
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

//- (void)showLoading
//{
//    [_refreshHeaderView egoRefreshScrollViewOpenAndShowLoading:nil];
//    [_refreshHeaderView refreshLastUpdatedDate];
//    [UIView animateWithDuration:0.30f 
//                          delay:0 
//                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
//                     animations:^(void){
//                         //                         contactEntry.frame = CGRectMake(0, 60, 320, contactEntry.frame.size.height);
//                         _refreshHeaderView.frame = CGRectMake(0, 0, 320, 60);
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
//    [[ViewController sharedInstance] showDropShadow:5];
//}
//
//- (void)hideLoading
//{
//    [UIView animateWithDuration:0.30f 
//                          delay:0 
//                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
//                     animations:^(void){
//                         //                         contactEntry.frame = CGRectMake(0, 0, 320, contactEntry.frame.size.height);
//                         _refreshHeaderView.frame = CGRectMake(0, -60.0f, 320, 60);
//                         
//                     }
//                     completion:^(BOOL finished){
//                         [[ViewController sharedInstance] showDropShadow:0];
//                         NSString *htmlContent = [Model sharedInstance].dealResults;
//                         [self showContent:htmlContent];
//                     }];
//}

- (void)showContent:(NSString *)html
{
    CGRect webFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    webView.delegate = self;
    webView.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    NSString *url = [NSString stringWithFormat:@"http://beta.weegoapp.com/public/"];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:url]];
    [self.view addSubview:webView];
    
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         shader.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         shader.hidden = YES;
                     }];
}

#pragma mark - Navigation handlers
- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}
- (void)handleSelectTimePress:(id)sender
{
    Model *model = [Model sharedInstance];
    BOOL iOwnEvent = [model.currentEvent.creatorId isEqualToString:model.userEmail];
    actionSheetState = iOwnEvent ? TimeActionSheetStateEventOwner : TimeActionSheetStateEventParticipant;
    [self pickDateTime];
}

#pragma mark -
#pragma mark Date Picker Methods

- (void)pickDateTime
{
	SEL changeSelector = @selector(changeDateTimeInLabel:);
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 24)];
	label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18];
	[label setBackgroundColor:[UIColor clearColor]];
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
	[label setTextColor:col];
	[label setText:actionSheetState == TimeActionSheetStateEventOwner ? @"Change event time?" : @"Suggest event time?"];
	[label sizeToFit];
    
    UIColor *shadowColor = HEXCOLOR(0x00000000);
    label.shadowColor = shadowColor;
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:label];
    [barItems addObject:toolBarTitle];
    [label release];
    
	UIBarButtonItem *flexSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace2];
    [flexSpace2 release];
	
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
    
	datePicker.date = [Model sharedInstance].currentEvent.eventDate;
    
    
	[datePicker addTarget:self
	               action:changeSelector
	     forControlEvents:UIControlEventValueChanged];
	[dateActionSheet addSubview:datePicker];
	[datePicker release];
	
	[dateActionSheet showInView:self.view];
	[dateActionSheet setBounds:CGRectMake(0,0,320, 464)];
    [dateActionSheet release];
}

- (void)datePickerDoneClick:(id)sender
{
    [dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    Model *model = [Model sharedInstance];
    if ([model.currentEvent.eventDate compare:datePicker.date] == NSOrderedSame) return; //exit if suggested date is same as current date
    
    if (actionSheetState == TimeActionSheetStateEventOwner)
    {
        model.currentEvent.eventDate = datePicker.date;
        [[Controller sharedInstance] updateEvent:model.currentEvent];
    }
    else
    {
        NSString *suggestedTimeString = [NSDate stringFromDate:datePicker.date withFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [[Controller sharedInstance] suggestTimeForEvent:model.currentEvent withSuggestedTime:suggestedTimeString];
    }
}

- (void)changeDateTimeInLabel:(id)sender
{
    
}

- (void)datePickerCancelClick:(id)sender
{
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}


#pragma mark UIWebViewDelegate methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)dealloc
{
    [self removeDataFetcherMessageListeners];
    [self.SGID release];
    [super dealloc];
}

@end