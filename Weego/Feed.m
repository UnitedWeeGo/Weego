//
//  Feed.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"
#import "Model.h"
#import "Event.h"
#import "FeedMessage.h"
#import "CellFeedMessage.h"
#import "SubViewFeedMessage.h"

@interface Feed (Private)

- (void)setUpUI;
- (CellFeedMessage *)getCellForFeedMessageWithFeedMessage:(FeedMessage *)aFeedMessage;
- (void)handleCancelChatPress:(id)sender;

@end

@implementation Feed

const int keyBoardHeight = 216;
const int baseViewHeight = 416;
const int closedWidgetInputHeight = 45;
const int openWidgetInputHeight = 120;

- (void)dealloc
{
    NSLog(@"Feed dealloc");
    [self removeDataFetcherMessageListeners];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UI Setup
- (void)setUpUI
{
    TableViewMessagesFullRect = CGRectMake(0.0f, closedWidgetInputHeight, 320.0f, baseViewHeight-closedWidgetInputHeight);
    TableViewMessagesCollapsedRect = CGRectMake(0.0f, openWidgetInputHeight, 320.0f, baseViewHeight-openWidgetInputHeight-keyBoardHeight);
    
    UIButton *cancelChatBG = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelChatBG.frame = TableViewMessagesFullRect;
    cancelChatBG.backgroundColor = HEXCOLOR(0xFF000000);
    [cancelChatBG addTarget:self action:@selector(handleCancelChatPress:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:cancelChatBG];
    
    messageEntryWidget = [[[MessageEntryWidget alloc] initWithFrame:CGRectZero] autorelease];// frame handled within widget
    messageEntryWidget.delegate = self;
    [[self view] addSubview:messageEntryWidget];
    
    tableViewMessages = [[[UITableView alloc] initWithFrame:TableViewMessagesFullRect style:UITableViewStylePlain] autorelease];
    tableViewMessages.backgroundColor = HEXCOLOR(0xF3F3F3FF);
//    tableViewMessages.separatorColor = HEXCOLOR(0xCCCCCCFF);
//    tableViewMessages.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableViewMessages.dataSource = self;
    tableViewMessages.delegate = self;
    tableViewMessages.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[self view] addSubview:tableViewMessages];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleCancelChatPress:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *feedMessages = [currentEvent getFeedMessages];
    FeedMessage *feedMessage = [feedMessages objectAtIndex:indexPath.row];
    return [SubViewFeedMessage calulateMyHeightWithFeedMessage:feedMessage];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *feedMessages = [currentEvent getFeedMessages];
	return [feedMessages count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    CellFeedMessage *cell = nil;
    NSArray *feedMessages = [currentEvent getFeedMessages];
    cell = [self getCellForFeedMessageWithFeedMessage: [feedMessages objectAtIndex:indexPath.row]];
    return cell;
}

- (CellFeedMessage *)getCellForFeedMessageWithFeedMessage:(FeedMessage *)aFeedMessage
{
    CellFeedMessage *cell = (CellFeedMessage *) [tableViewMessages dequeueReusableCellWithIdentifier:@"FeedMessageTableCellId"];
    if (cell == nil) {
        cell = [[[CellFeedMessage alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeedMessageTableCellId"] autorelease];
    }
    cell.feedMessage = aFeedMessage;
    return cell;
}

#pragma mark - Navigation handlers
- (void)handleRightActionPress:(id)sender
{
    currentEvent.unreadMessageCount = 0;
    [self removeDataFetcherMessageListeners];
    [self dismissModalViewControllerAnimated:YES];
    [[ViewController sharedInstance] showEventBackground];
}
- (void)handleCancelChatPress:(id)sender
{
    [messageEntryWidget transitionToState:MessageEntryStateClosed];
}

#pragma mark -
#pragma mark MessageEntryWidgetDelegate methods
-(void) messageEntryWidgetStateChangedToState:(MessageEntryState)state
{
    CGRect tableViewMessagesFrame;
    
    switch (state) {
        case MessageEntryStateClosed:
            tableViewMessagesFrame = TableViewMessagesFullRect;
            break;
        case MessageEntryStateEditing:
            tableViewMessagesFrame = TableViewMessagesCollapsedRect;
            break;
        case MessageEntryStateSending:
            tableViewMessagesFrame = TableViewMessagesCollapsedRect;
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.30f 
                          delay:0.0f 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         tableViewMessages.frame = tableViewMessagesFrame;
                     }
                     completion:NULL];
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
        case DataFetchTypeAddMessage:
            [tableViewMessages reloadData];
            [messageEntryWidget resetAfterSendSuccess];
            [[SoundManager sharedInstance] playSoundWithId:SoundManagerSoundIdFeedMessageSent withVibration:NO];
            break;
        case DataFetchTypeGetEvent:
            [tableViewMessages reloadData];
            break;
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    switch (fetchType) {
        case DataFetchTypeAddMessage:
            NSLog(@"Unhandled Error: %d", fetchType);
            break;
        case DataFetchTypeGetEvent:
            NSLog(@"Unhandled Error: %d", fetchType);
            break;
        default:
            break;
    }
}

#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    [[NavigationSetter sharedInstance] setNavState:NavStateFeed withTarget:self];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
    
    self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    [[ViewController sharedInstance] showDropShadow:0];
//    [[ViewController sharedInstance] showFeedBackground];
    
    currentEvent = [Model sharedInstance].currentEvent;
    
    [self setUpDataFetcherMessageListeners];
    
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [[Controller sharedInstance] markFeedMessagesRead];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[Controller sharedInstance] markFeedMessagesRead];
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

@end
