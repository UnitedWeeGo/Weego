//
//  AddFriends.m
//  BigBaby
//
//  Created by Dave Prukop on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddFriends.h"
#import "ABContactsHelper.h"
#import "ABContact.h"
#import "Contact.h"
#import "Participant.h"
#import "CellContact.h"

@interface AddFriends (Private)

- (void)checkValidEmailAddress;
- (void)processValidParticipant;
- (void)searchAddressBook;
- (NSArray *)contactsWithEmailMatchingNameOrEmail:(NSString *)name;
- (void)updateFilteredContacts:(NSMutableArray *)contacts;
- (CellContact *)getCellForContactsWithContact:(Contact *)aContact;
- (void)showSending;
- (void)hideSending;

@end


@implementation AddFriends

//@synthesize matchedContacts;
@synthesize contactsTableView, filteredContacts, searchThreadIsCancelled;

- (void)dealloc
{
    NSLog(@"AddFriends dealloc");
//    [matchedContacts release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.filteredContacts release];
    [allContacts release];
    [allContactsWithEmail release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);	
    [[NavigationSetter sharedInstance] setNavState:NavStateAddParticipant withTarget:self];
    
    UIView *headerViewMask = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, 60)];
    headerViewMask.clipsToBounds = YES;
    [self.view addSubview:headerViewMask];
    [headerViewMask release];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -60.0f, 320, 60)];
    _refreshHeaderView.delegate = self;
    [headerViewMask addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
//	_refreshHeaderView.hidden = YES;
    
    self.contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, 152)];
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.backgroundColor = [UIColor clearColor];
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.contactsTableView];
    [self.contactsTableView release];
//    self.contactsTableView.hidden = YES;
    
    contactEntry = [[SubViewContactEntry alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    contactEntry.delegate = self;
    [self.view addSubview:contactEntry];
    [contactEntry release];
    
    allContacts = [[ABContactsHelper contacts] retain];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"emailArrayCount > 0"];
    allContactsWithEmail = [[allContacts filteredArrayUsingPredicate:pred] retain];
    [self inputFieldDidChange:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateAddParticipant;
    [[ViewController sharedInstance] showDropShadow:0];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)checkValidEmailAddress {
	if (contactEntry.allValid) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [contactEntry setUserInteractionEnabled:NO];
        [self showSending];
		[self processValidParticipant];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)processValidParticipant {
	// pass the data to the controller
    NSMutableArray *participants = [[[NSMutableArray alloc] initWithCapacity:[contactEntry.enteredContacts count]] autorelease];
    for (int i=0; i<[contactEntry.enteredContacts count]; i++) {
        Contact *c = [contactEntry.enteredContacts objectAtIndex:i];
        Participant *participant = [[Model sharedInstance] createNewParticipantWithEmail:c.emailAddress];
        [participants addObject:participant];
    }
    if ([Model sharedInstance].currentAppState == AppStateCreateEvent) {
        [[ViewController sharedInstance] goBack];
    } else {
        [self setUpDataFetcherMessageListeners];
        Controller *controller = [Controller sharedInstance];
        [controller addParticipants:participants];
    }
}

- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

- (void)handleRightActionPress:(id)sender
{
    [contactEntry finalizeContact];
    [self checkValidEmailAddress];
}

#pragma mark - SubViewContactEntryDelegate

- (void)inputFieldDidReturn:(id)sender
{
    
}

- (void)handleDirectFieldTouch:(id)sender
{
    
}

- (void)inputFieldDidEndEditing:(id)sender
{
    
}

- (void)inputFieldDidChange:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideSending];
    [NSThread detachNewThreadSelector:@selector(searchAddressBook) toTarget:self withObject:nil];
//    NSLog(@"%@", contactEntry.fieldText);
//    if ([contactEntry.fieldText isEqualToString:@""]) {
////        contactsTableView.hidden = YES;
//        [filteredContacts removeAllObjects];
//        [contactsTableView reloadData];
//    } else {
//        [NSThread detachNewThreadSelector:@selector(searchAddressBook) toTarget:self withObject:nil];
//    }
}

- (void)searchAddressBook
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    [NSThread setThreadPriority:0.0];
    
    NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
    
    NSArray *contactsMatchingName = [self contactsWithEmailMatchingNameOrEmail:contactEntry.fieldText];
    for (ABContact *abc in contactsMatchingName) {
        NSRange range = [abc.contactName rangeOfString:contactEntry.fieldText options:NSCaseInsensitiveSearch];
        BOOL matchesName = (range.length > 0);
        for (int i=0; i<[[abc emailArray] count]; i++) {
            NSString *email = [[abc emailArray] objectAtIndex:i];
            NSString *emailLabel = [[abc emailLabels] objectAtIndex:i];
            NSRange range = [email rangeOfString:contactEntry.fieldText options:NSCaseInsensitiveSearch];
            BOOL matchesEmail = (range.length > 0);
            if (matchesName || matchesEmail) {
                Contact *c = [[Contact alloc] init];
                c.contactName = abc.contactName;
                c.emailAddress = email;
                c.emailLabel = emailLabel;
                [matchedContacts addObject:c];
                [c release];
            }
        }
    }
//    [self updateFilteredContacts:matchedContacts];
    [self performSelector:@selector(updateFilteredContacts:) onThread:[NSThread mainThread] withObject:matchedContacts waitUntilDone:NO];
    [matchedContacts release];
    
    [pool drain];
}

- (NSArray *)contactsWithEmailMatchingNameOrEmail:(NSString *)name
{
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"emailaddresses contains[cd] %@ OR contactName contains[cd] %@", name, name];
    return [allContactsWithEmail filteredArrayUsingPredicate:pred];
}

- (void)updateFilteredContacts:(NSMutableArray *)contacts
{
    self.filteredContacts = contacts;
    [self.contactsTableView reloadData];
//    [filteredContacts release];
//    filteredContacts = contacts;
//    [filteredContacts retain];
//    [contactsTableView reloadData];

//    if ([filteredContacts count] > 0) {
//        contactsTableView.hidden = NO;
//        [contactsTableView reloadData];
//    } else {
//        contactsTableView.hidden = YES;
//    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *c = [filteredContacts objectAtIndex:indexPath.row];
    NSLog(@"%@", c.contactName);
    [contactEntry addContact:c];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [filteredContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Contact *contact = [filteredContacts objectAtIndex:indexPath.row];
	CellContact *cell = [self getCellForContactsWithContact:contact];
    return cell;
}

- (CellContact *)getCellForContactsWithContact:(Contact *)aContact
{
    CellContact *cell = (CellContact *) [contactsTableView dequeueReusableCellWithIdentifier:@"ContactsTableCellId"];
    if (cell == nil) {
        cell = [[[CellContact alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactsTableCellId"] autorelease];
    }
    cell.contact = aContact;
    return cell;
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
    NSLog(@"FetchType = %d", fetchType);
    switch (fetchType) {
        case DataFetchTypeUpdateParticipants:
            [self removeDataFetcherMessageListeners];
            [[ViewController sharedInstance] goBack];
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
        case DataFetchTypeUpdateParticipants:
//            NSLog(@"Unhandled Error: %d", fetchType);
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [contactEntry setUserInteractionEnabled:YES];
            [_refreshHeaderView egoRefreshScrollViewOpenAndShowError:nil];
            [self performSelector:@selector(hideSending) withObject:nil afterDelay:5.0];
            break;
            
        default:
            break;
    }
}

- (void)showSending
{
    [_refreshHeaderView egoRefreshScrollViewOpenAndShowSaving:nil];
    [_refreshHeaderView refreshLastUpdatedDate];
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         contactEntry.frame = CGRectMake(0, 60, 320, contactEntry.frame.size.height);
                         _refreshHeaderView.frame = CGRectMake(0, 0, 320, 60);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [[ViewController sharedInstance] showDropShadow:5];
}

- (void)hideSending
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         contactEntry.frame = CGRectMake(0, 0, 320, contactEntry.frame.size.height);
                         _refreshHeaderView.frame = CGRectMake(0, -60.0f, 320, 60);
                     }
                     completion:^(BOOL finished){
                         [[ViewController sharedInstance] showDropShadow:0];
                     }];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	_saving = YES;
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _saving; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (void)egoRefreshTableHeaderClosed
{
//    _refreshHeaderView.hidden = YES;
}

@end
