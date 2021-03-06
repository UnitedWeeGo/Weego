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
#import "Event.h"
#import "Contact.h"
#import "Participant.h"
#import "CellContact.h"
#import "Event.h"

@interface AddFriends (Private)

- (void)checkValidEmailAddress;
- (void)validateAndSend;
- (void)processValidParticipant;
- (void)searchAddressBook;
- (NSArray *)contactsWithEmailMatchingNameOrEmail:(NSString *)name;
- (void)updateFilteredContacts:(NSMutableArray *)contacts;
- (CellContact *)getCellForContactsWithContact:(Contact *)aContact;
- (CellContact *)getCellForContactsWithParticipant:(Participant *)aParticipant;
- (Contact *)isAlreadyAdded:(NSString *)email;
- (BOOL)shouldBeDisabled:(NSString *)email;
- (void)showSending;
- (void)hideSending;
- (void)addContact:(Contact *)aContact;
- (void)removeContact:(Contact *)aContact;

@end


@implementation AddFriends

@synthesize contactsTableView, filteredContacts, searchThreadIsCancelled;

- (void)dealloc
{
    NSLog(@"AddFriends dealloc");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    contactsTableView.dataSource = nil;
    contactsTableView.delegate = nil;
    [contactsTableView release];
    contactsSearchBar.delegate = nil;
    [allContactsWithEmail release];
    [recentParticipants release];
    [facebookFriends release];
    [filteredContacts release];
    [addedContacts release];
    [currentSearchTerm release];
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
    
    tableTop = 41;
    
    self.contactsTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, tableTop, self.view.frame.size.width, self.view.frame.size.height - 44 - tableTop)] autorelease];
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.backgroundColor = [UIColor clearColor];
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.contactsTableView];

    contactsSearchBar = [[SubViewSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320.0, 41.0)];
    contactsSearchBar.delegate = self;
    contactsSearchBar.keyboardType = UIKeyboardTypeEmailAddress;
    contactsSearchBar.placeholderText = @"Type your friend's name or email";
    [self.view addSubview:contactsSearchBar];
    [contactsSearchBar release];
    
    detail = [Model sharedInstance].currentEvent;
    addedContacts = [[NSMutableArray alloc] init]; //[[NSMutableArray arrayWithArray:[detail getParticipants]] retain]; //
    
    recentParticipants = [[NSMutableArray arrayWithArray:[[Model sharedInstance] getRecentParticipants]] retain]; //[[[Model sharedInstance] getRecentParticipants] retain];
    NSSortDescriptor *participantsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    [recentParticipants sortUsingDescriptors:[NSArray arrayWithObjects:participantsSortDescriptor, nil]];
    hasRecents = ([recentParticipants count] > 0);
    
    facebookFriends = [[NSMutableArray arrayWithArray:[[Model sharedInstance] getFacebookFriends]] retain];
    NSSortDescriptor *facebookSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    [facebookFriends sortUsingDescriptors:[NSArray arrayWithObjects:facebookSortDescriptor, nil]];
    hasFacebookFriends = ([facebookFriends count] > 0);
    
    NSArray *allContacts = [ABContactsHelper contacts];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"emailArrayCount > 0"];
    allContactsWithEmail = [allContacts filteredArrayUsingPredicate:pred];
    [allContactsWithEmail retain];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Model sharedInstance].currentViewState = ViewStateAddParticipant;
    [[ViewController sharedInstance] showDropShadow:0];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _refreshHeaderView.delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (void)checkValidEmailAddress {
//	if (contactEntry.allValid) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//        self.navigationItem.leftBarButtonItem.enabled = NO;
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [contactEntry setUserInteractionEnabled:NO];
//        [self showSending];
//		[self processValidParticipant];
//	} else {
//		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
//		[alert show];
//	}
//}

- (void)checkValidEmailAddress {
	
}

- (void)validateAndSend
{
    BOOL allValid = YES;
    for (Contact *c in addedContacts) {
        if (!c.isValid) {
            allValid = NO;
            continue;
        }
    }
    if (allValid) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [searchEntryBar setUserInteractionEnabled:NO];
        [contactsSearchBar setUserInteractionEnabled:NO];
        [contactsTableView setUserInteractionEnabled:NO];
        [self showSending];
        [self processValidParticipant];
    } else {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

- (void)processValidParticipant {
	// pass the data to the controller
    NSMutableArray *participants = [[[NSMutableArray alloc] initWithCapacity:[addedContacts count]] autorelease];
    for (int i=0; i<[addedContacts count]; i++) {
        Contact *c = [addedContacts objectAtIndex:i];
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
    Model *model = [Model sharedInstance];
    if (!model.isInTrial && model.currentAppState == AppStateEventDetails) [model flushTempParticipantsForEventWithId:detail.eventId];
    [[ViewController sharedInstance] goBack];
}

- (void)handleRightActionPress:(id)sender
{
    if (![[contactsSearchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        Contact *c = [[[Contact alloc] init] autorelease];
        c.emailAddress = contactsSearchBar.text;
        if (c.isValid) {
            [self addContact:c];
        } else {
            [contactsSearchBar showError:YES];
            return;
        }
    }
    [self validateAndSend];
}

#pragma mark - SubViewContactsSearchBarDelegate

- (void)searchBar:(SubViewSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self hideSending];
    [contactsSearchBar showError:NO];
    [currentSearchTerm release];
    currentSearchTerm = [[NSString stringWithString:searchText] retain];
    [NSThread detachNewThreadSelector:@selector(searchAddressBook) toTarget:self withObject:nil];
}

- (void)searchBarTextDidBeginEditing:(SubViewSearchBar *)searchBar
{
    keyboardShowing = YES;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         self.contactsTableView.frame = CGRectMake(0, tableTop, self.view.frame.size.width, self.view.frame.size.height - tableTop - 214);
                     }
                     completion:NULL];
}

- (void)searchBarTextDidEndEditing:(SubViewSearchBar *)searchBar
{
    keyboardShowing = NO;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         self.contactsTableView.frame = CGRectMake(0, tableTop, self.view.frame.size.width, self.view.frame.size.height - tableTop);
                     }
                     completion:NULL];
}

- (void)searchBarBookmarkButtonClicked:(SubViewSearchBar *)searchBar
{
    [[ViewController sharedInstance] navigateToAddressBook:self];
}

- (void)searchBarClearButtonClicked:(id)searchBar
{
    hasFoundResults = NO;
    [filteredContacts removeAllObjects];
    [contactsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(SubViewSearchBar *)searchBar
{
    hasFoundResults = NO;
    [filteredContacts removeAllObjects];
    [contactsTableView reloadData];
}

- (void)searchBarReturnButtonClicked:(SubViewSearchBar *)searchBar
{
    Contact *c = [[Contact alloc] init];
    c.contactName = @"";
    c.emailAddress = searchBar.text;
    if (c.isValid) [self addContact:c];
    else [contactsSearchBar showError:YES];
    [c release];
}

#pragma mark - Search Address Book Thread

- (void)searchAddressBook
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    [NSThread setThreadPriority:0.0];
    
    NSMutableArray *matchedContacts = [[NSMutableArray alloc] init];
    
    NSArray *contactsMatchingName = [self contactsWithEmailMatchingNameOrEmail:currentSearchTerm];
    for (ABContact *abc in contactsMatchingName) {
        NSRange range = [abc.contactName rangeOfString:currentSearchTerm options:NSCaseInsensitiveSearch];
        BOOL matchesName = (range.length > 0);
        for (int i=0; i<[[abc emailArray] count]; i++) {
            NSString *email = [[abc emailArray] objectAtIndex:i];
            NSString *emailLabel = [[abc emailLabels] objectAtIndex:i];
            NSRange range = [email rangeOfString:currentSearchTerm options:NSCaseInsensitiveSearch];
            BOOL matchesEmail = (range.length > 0);
            if (matchesName || matchesEmail) {
                Contact *c = [[Contact alloc] init];
                c.contactName = abc.contactName;
                c.emailAddress = email;
                c.emailLabel = emailLabel;
                if (c.isValid) [matchedContacts addObject:c];
                [c release];
            }
        }
    }
    [self performSelector:@selector(updateFilteredContacts:) onThread:[NSThread mainThread] withObject:matchedContacts waitUntilDone:NO];
    [matchedContacts release];
    
    [pool drain];
}

- (NSArray *)contactsWithEmailMatchingNameOrEmail:(NSString *)name
{
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"emailaddresses contains[cd] %@ OR contactName contains[cd] %@", name, name];
    NSArray *output = [allContactsWithEmail filteredArrayUsingPredicate:pred];
    return output;
}

- (void)updateFilteredContacts:(NSMutableArray *)contacts
{
    self.filteredContacts = contacts;
    hasFoundResults = [self.filteredContacts count] > 0;
    [self.contactsTableView reloadData];
}

#pragma mark - Private Methods

- (void)addContact:(Contact *)aContact
{
    if (![self isAlreadyAdded:aContact.emailAddress]) {
        [addedContacts addObject:aContact];
    }
    for (Participant *p in recentParticipants) {
        if ([aContact.emailAddress isEqualToString:p.email]) {
            [recentParticipants removeObject:p];
            break;
        }
    }
    hasRecents = ([recentParticipants count] > 0);
    hasAddedContacts = ([addedContacts count] > 0);
    hasFoundResults = NO;
    [contactsTableView reloadData];
    [contactsSearchBar resetField];
}

- (void)removeContact:(Contact *)aContact
{
    NSLog(@"removing %@", aContact.emailAddress);
    Contact *c = [self isAlreadyAdded:aContact.emailAddress];
    if (c) {
        [addedContacts removeObject:c];
    }
    for (Participant *p in [[Model sharedInstance] getRecentParticipants]) {
        if ([aContact.emailAddress isEqualToString:p.email]) {
            [recentParticipants addObject:p];
        }
    }
    for (Participant *p in [[Model sharedInstance] getFacebookFriends]) {
        if ([aContact.emailAddress isEqualToString:p.email]) {
            [facebookFriends addObject:p];
        }
    }
    NSSortDescriptor *participantsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(compare:)] autorelease];
    [recentParticipants sortUsingDescriptors:[NSArray arrayWithObjects:participantsSortDescriptor, nil]];
    [facebookFriends sortUsingDescriptors:[NSArray arrayWithObjects:participantsSortDescriptor, nil]];
    hasRecents = ([recentParticipants count] > 0);
    hasFacebookFriends = ([facebookFriends count] > 0);
    hasAddedContacts = ([addedContacts count] > 0);
    hasFoundResults = NO;
//    [contactsSearchBar resetField];
    [contactsTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && !hasFoundResults && hasAddedContacts) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellContact *cell = (CellContact *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editing = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellContact *cell = (CellContact *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editing = NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Contact *c = [addedContacts objectAtIndex:indexPath.row];
        NSLog(@"removing %@", c.contactName);
        [c retain];
        [self removeContact:c];
        [c release];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (hasFoundResults) {
            CellContact *cell = (CellContact *)[contactsTableView cellForRowAtIndexPath:indexPath];
            if (!cell.disabled) {
                Contact *c = [filteredContacts objectAtIndex:indexPath.row];
                [self addContact:c];
            }
        } else if (!hasAddedContacts) {
            CellContact *cell = (CellContact *)[contactsTableView cellForRowAtIndexPath:indexPath];
            if (!cell.disabled) {
                NSMutableArray *source = (hasRecents) ? recentParticipants : facebookFriends;
                Participant *p = [source objectAtIndex:indexPath.row];
                Contact *c = [[Contact alloc] init];
                c.contactName = p.fullName;
                c.emailAddress = p.email;
                [source removeObject:p];
                hasRecents = ([recentParticipants count] > 0);
                hasFacebookFriends = ([facebookFriends count] > 0);
                [self addContact:c];
                [c release];
            }
        }
    } else if (indexPath.section == 1) {
        CellContact *cell = (CellContact *)[contactsTableView cellForRowAtIndexPath:indexPath];
        if (!cell.disabled) {
            NSMutableArray *source = (hasRecents && hasAddedContacts) ? recentParticipants : facebookFriends;
            Participant *p = [source objectAtIndex:indexPath.row];
            Contact *c = [[Contact alloc] init];
            c.contactName = p.fullName;
            c.emailAddress = p.email;
            [source removeObject:p];
            hasRecents = ([recentParticipants count] > 0);
            hasFacebookFriends = ([facebookFriends count] > 0);
            [self addContact:c];
            [c release];
        }
    } else if (indexPath.section == 2) {
        CellContact *cell = (CellContact *)[contactsTableView cellForRowAtIndexPath:indexPath];
        if (!cell.disabled) {
            Participant *p = [facebookFriends objectAtIndex:indexPath.row];
            Contact *c = [[Contact alloc] init];
            c.contactName = p.fullName;
            c.emailAddress = p.email;
            [facebookFriends removeObject:p];
            hasFacebookFriends = ([facebookFriends count] > 0);
            [self addContact:c];
            [c release];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return (foundResults) ? 2 : 1;
    if (hasFoundResults) return 1;
    int numSections = 0;
    if (hasAddedContacts) numSections++;
    if (hasRecents) numSections++;
    if (hasFacebookFriends) numSections++;
    return numSections;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        if (hasFoundResults) return [NSString stringWithFormat:@"Results matching %@", currentSearchTerm];
//        if (hasAddedContacts) return @"Invite";
//        else return @"Recent";
//    } else if (section == 1) {
//        return @"Recent";
//    }
//    return @"";
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22.0)] autorelease];
    UIImage *bgImage = [[UIImage imageNamed:@"plainTableHeaderBg.png"] stretchableImageWithLeftCapWidth:3.0 topCapHeight:0];
    sectionHeaderView.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 4.0, 310.0, 22.0)];
    sectionLabel.text = @"";
    sectionLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18.0];
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.shadowColor = [UIColor grayColor];
    sectionLabel.shadowOffset = CGSizeMake(0, 1);
    sectionLabel.backgroundColor = [UIColor clearColor];
    [sectionHeaderView addSubview:sectionLabel];
    [sectionLabel release];
    if (section == 0) {
        if (hasFoundResults) sectionLabel.text =  [NSString stringWithFormat:@"Results matching %@", currentSearchTerm];
        else if (hasAddedContacts) sectionLabel.text =  @"Invite";
        else if (hasRecents) sectionLabel.text =  @"Recent";
        else if (hasFacebookFriends) sectionLabel.text = @"Facebook friends on weego";
    } else if (section == 1) {
        if (hasRecents && hasAddedContacts) sectionLabel.text =  @"Recent";
        else if (hasFacebookFriends) sectionLabel.text = @"Facebook friends on weego";
    } else if (section == 2) {
        sectionLabel.text = @"Facebook friends on weego";
    }
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (hasFoundResults) return [filteredContacts count];
        if (hasAddedContacts) return [addedContacts count];
        if (hasRecents) return [recentParticipants count];
        if (hasFacebookFriends) return [facebookFriends count];
        return 0;
    } else if (section == 1) {
        if (hasRecents && hasAddedContacts) return [recentParticipants count];
        if (hasFacebookFriends) return [facebookFriends count];
        return 0;
    } else if (section == 2) {
        if (hasFacebookFriends) return [facebookFriends count];
        return 0;
    } 
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (hasFoundResults) {
            Contact *contact = [filteredContacts objectAtIndex:indexPath.row];
            Participant *participant = [[Model sharedInstance] getPairedParticipantWithEmail:contact.emailAddress];
            CellContact *cell = nil;
            if (participant) cell = [self getCellForContactsWithParticipant:participant];
            else cell = [self getCellForContactsWithContact:contact];
            return cell;
        } else if (hasAddedContacts) {
            Contact *contact = [addedContacts objectAtIndex:indexPath.row];
            Participant *participant = [[Model sharedInstance] getPairedParticipantWithEmail:contact.emailAddress];
            CellContact *cell = nil;
            if (participant) cell = [self getCellForContactsWithParticipant:participant];
            else cell = [self getCellForContactsWithContact:contact];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } else {
            NSArray *source = (hasRecents) ? recentParticipants : facebookFriends;
            Participant *participant = [source objectAtIndex:indexPath.row];
            CellContact *cell = [self getCellForContactsWithParticipant:participant];
            return cell;
        }
    } else if (indexPath.section == 1) {
        NSArray *source = (hasAddedContacts && hasRecents) ? recentParticipants : facebookFriends;
        Participant *participant = [source objectAtIndex:indexPath.row];
        CellContact *cell = [self getCellForContactsWithParticipant:participant];
        return cell;
    } else if (indexPath.section == 2) {
        NSArray *source = facebookFriends;
        Participant *participant = [source objectAtIndex:indexPath.row];
        CellContact *cell = [self getCellForContactsWithParticipant:participant];
        return cell;
    }

    return nil;
}

- (CellContact *)getCellForContactsWithContact:(Contact *)aContact
{
    CellContact *cell = (CellContact *) [contactsTableView dequeueReusableCellWithIdentifier:@"ContactsTableCellId"];
    if (cell == nil) {
        cell = [[[CellContact alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactsTableCellId"] autorelease];
    }
    cell.contact = aContact;
    [cell showDisabled:[self shouldBeDisabled:aContact.emailAddress]];
    return cell;
}

- (CellContact *)getCellForContactsWithParticipant:(Participant *)aParticipant
{
    CellContact *cell = (CellContact *) [contactsTableView dequeueReusableCellWithIdentifier:@"ContactsTableCellId"];
    if (cell == nil) {
        cell = [[[CellContact alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactsTableCellId"] autorelease];
    }
    cell.participant = aParticipant;
    [cell showDisabled:[self shouldBeDisabled:aParticipant.email]];
    return cell;
}

- (Contact *)isAlreadyAdded:(NSString *)email
{
    for (Contact *c in addedContacts) {
        if ([c.emailAddress isEqualToString:email]) return c;
    }
//    Event *currentEvent = [Model sharedInstance].currentEvent;
//    for (Participant *p in [currentEvent getParticipants]) {
//        if ([p.email isEqualToString:email]) return YES;
//    }
    return nil;
}

- (BOOL)shouldBeDisabled:(NSString *)email
{
    Event *currentEvent = [Model sharedInstance].currentEvent;
    for (Participant *p in [currentEvent getParticipants]) {
        if ([p.email isEqualToString:email]) return YES;
    }
    return NO;
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
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeUpdateParticipants:
//            NSLog(@"Unhandled Error: %d", fetchType);
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [contactsSearchBar setUserInteractionEnabled:YES];
//            [contactEntry setUserInteractionEnabled:YES];
            [_refreshHeaderView egoRefreshScrollViewOpenAndShowError:nil withCode:errorType];
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
    CGFloat keyboardHeight = (keyboardShowing) ? 214 : 0;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
//                         contactEntry.frame = CGRectMake(0, 60, 320, contactEntry.frame.size.height);
                         contactsSearchBar.frame = CGRectMake(0, 60, 320, contactsSearchBar.frame.size.height);
                         contactsTableView.frame = CGRectMake(0, tableTop+60, self.view.frame.size.width, self.view.frame.size.height - tableTop - 60 - keyboardHeight);
                         _refreshHeaderView.frame = CGRectMake(0, 0, 320, 60);
                     }
                     completion:^(BOOL finished){
                         
                     }];
    [[ViewController sharedInstance] showDropShadow:5];
}

- (void)hideSending
{
    CGFloat keyboardHeight = (keyboardShowing) ? 214 : 0;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
//                         contactEntry.frame = CGRectMake(0, 0, 320, contactEntry.frame.size.height);
                         contactsSearchBar.frame = CGRectMake(0, 0, 320, contactsSearchBar.frame.size.height);
                         contactsTableView.frame = CGRectMake(0, tableTop, self.view.frame.size.width, self.view.frame.size.height - tableTop - keyboardHeight);
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

#pragma mark - AddressBookTVCDataSource

- (NSArray *)dataForAddressBookTVC
{
    NSMutableArray *matchedContacts = [[[NSMutableArray alloc] init] autorelease];
    for (ABContact *abc in allContactsWithEmail) {
        for (int i=0; i<[[abc emailArray] count]; i++) {
            NSString *email = [NSString stringWithFormat:@"%@", [[abc emailArray] objectAtIndex:i]];
            NSString *emailLabel = [NSString stringWithFormat:@"%@", [[abc emailLabels] objectAtIndex:i]];
            Contact *c = [[Contact alloc] init];
            c.contactName = abc.contactName;
            c.emailAddress = email;
            c.emailLabel = emailLabel;
            if (c.isValid) [matchedContacts addObject:c];
            [c release];
        }
    }
    NSSortDescriptor *contactSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
	[matchedContacts sortUsingDescriptors:[NSArray arrayWithObjects:contactSortDescriptor, nil]];
    return matchedContacts;
}

- (NSArray *)enteredContactsForAddressBookTVC
{
    return addedContacts; //[contactEntry enteredContacts];
}

- (NSArray *)addedParticipantsForAddressBookTVC
{
    Event *currentEvent = [Model sharedInstance].currentEvent;
    return [currentEvent getParticipants];
}

#pragma mark - AddressBookTVCDelegate

- (void)addressBookTVCDidAddContact:(Contact *)aContact
{
    [aContact retain];
    [self addContact:aContact];
    [aContact release];
}

- (void)addressBookTVCDidRemoveContact:(Contact *)aContact
{
    [aContact retain];
    [self removeContact:aContact];
    [aContact release];
}

@end
