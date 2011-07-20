//
//  AdressBookTVC.m
//  Weego
//
//  Created by Dave Prukop on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddressBookTVC.h"
#import "CellContact.h"
#import "Participant.h"

@interface AddressBookTVC (Private)

- (CellContact *)getCellForContactsWithContact:(Contact *)aContact;
- (BOOL)isAlreadyAdded:(NSString *)email;
- (BOOL)shouldBeChecked:(NSString *)email;
- (BOOL)shouldBeDisabled:(NSString *)email;

@end

@implementation AddressBookTVC

@synthesize dataSource, delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NavigationSetter sharedInstance] setNavState:NavStateAddressBook withTarget:self];
    
    indexes = [[NSMutableArray alloc] init];
    indexedContacts = [[NSMutableArray alloc] initWithObjects:[NSMutableArray array], nil];
    
    for(char c = 'A'; c <= 'Z'; c++) {
        [indexes addObject:[NSString stringWithFormat:@"%c",c]];
        [indexedContacts addObject:[NSMutableArray array]];
    }
    
    [indexes addObject:@"#"];
    [indexedContacts addObject:[NSMutableArray array]];
    
    contacts = [[dataSource dataForAddressBookTVC] retain];
    
    for (Contact *c in contacts) {
		NSInteger index = indexes.count - 1; // insert into #
		if (c.contactName.length) {
			NSInteger expectedIndex = [indexes indexOfObject:[[c.contactName substringToIndex:1] uppercaseString]];
			if (expectedIndex != NSNotFound) {
				index = expectedIndex;
			}
		}
		[[indexedContacts objectAtIndex:index] addObject:c];
	}

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [contacts release];
    [super dealloc];
}

- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [indexes count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return indexes;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[indexedContacts objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([[indexedContacts objectAtIndex:section] count]) {
		return 23;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [indexes objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *contact = [[indexedContacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CellContact *cell = [self getCellForContactsWithContact:contact];
    return cell;
}

- (CellContact *)getCellForContactsWithContact:(Contact *)aContact
{
    CellContact *cell = (CellContact *) [self.tableView dequeueReusableCellWithIdentifier:@"ContactsTableCellId"];
    if (cell == nil) {
        cell = [[[CellContact alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactsTableCellId"] autorelease];
    }
    cell.contact = aContact;
    [cell showChecked:[self shouldBeChecked:aContact.emailAddress]];
    [cell showDisabled:[self shouldBeDisabled:aContact.emailAddress]];
    return cell;
}

- (BOOL)isAlreadyAdded:(NSString *)email
{
    for (Contact *c in [dataSource enteredContactsForAddressBookTVC]) {
        if ([c.emailAddress isEqualToString:email]) return YES;
    }
    for (Participant *p in [dataSource addedParticipantsForAddressBookTVC]) {
        if ([p.email isEqualToString:email]) return YES;
    }
    return NO;
}

- (BOOL)shouldBeChecked:(NSString *)email
{
    for (Contact *c in [dataSource enteredContactsForAddressBookTVC]) {
        if ([c.emailAddress isEqualToString:email]) return YES;
    }
    return NO;
}

- (BOOL)shouldBeDisabled:(NSString *)email
{
    for (Participant *p in [dataSource addedParticipantsForAddressBookTVC]) {
        if ([p.email isEqualToString:email]) return YES;
    }
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *c = [[indexedContacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (![self isAlreadyAdded:c.emailAddress]) {
        [delegate addressBookTVCDidAddContact:c];
    } else {
        [delegate addressBookTVCDidRemoveContact:c];
    }
    [self.tableView reloadData];
}

@end
