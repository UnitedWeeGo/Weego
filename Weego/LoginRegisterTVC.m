//
//  LoginRegisterTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginRegisterTVC.h"
#import "BBTableViewCell.h"
#import "CellEventCallToAction.h"


typedef enum {
    RegisterCellTypeEmail = 0,
    RegisterCellTypePassword,
    RegisterCellTypeMobileNumber,
    RegisterCellTypeFirstName,
    RegisterCellTypeLastName,
    RegisterCellTypeCount
} RegisterCellType;

@interface LoginRegisterTVC (Private)

- (BBTableViewCell *)getCellForFormWithIndex:(int)index;
- (BBTableViewCell *)getCellForCallToAction:(NSString *)label;
- (void)toggleNotMember;
- (void)continueToDashboard;

- (BOOL)checkValidEmailAddress;
- (BOOL)checkValidPassword;
- (void)processValidLogin;

@end

@implementation LoginRegisterTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        cellFormDataHolder = [[NSMutableArray alloc] initWithCapacity:RegisterCellTypeCount];
        for (int i = 0; i < RegisterCellTypeCount; i++) [cellFormDataHolder insertObject:@"" atIndex:i];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [cellFormDataHolder release];
    [super dealloc];
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

    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.tableView addSubview:bevelStripe];
    [bevelStripe release];
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
    
    [Model sharedInstance].currentAppState = AppStateEntry;
    [Model sharedInstance].currentViewState = ViewStateRegister;
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    [[NavigationSetter sharedInstance] setNavState:NavStateRegister withTarget:self];
    [[ViewController sharedInstance] showEventBackground];
    
	tableHeaderView = [[HeaderViewLoginRegister alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    tableHeaderView.delegate = self;
	self.tableView.tableHeaderView = tableHeaderView;
	[tableHeaderView release];
    
    tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 64)];
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(9, 10, 302, 45);
    [loginButton setBackgroundImage:[UIImage imageNamed:@"button_login_green_default.png"] forState:UIControlStateNormal];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"button_login_green_pressed.png"] forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"button_login_disabled.png"] forState:UIControlStateDisabled];
    [loginButton addTarget:self action:@selector(handleLoginPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    loginButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    UIColor *fbButtonTitleColor = HEXCOLOR(0xFFFFFFFF);
    [loginButton setTitleColor:fbButtonTitleColor forState:UIControlStateNormal];
    UIColor *shadowColor = HEXCOLOR(0x33333333);
    loginButton.titleLabel.shadowColor = shadowColor;
    loginButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [tableFooterView addSubview:loginButton];
    self.tableView.tableFooterView = tableFooterView;
    [tableFooterView release];

    loginButton.enabled = NO;
}

#pragma mark - Event Handlers

- (void)handleLoginPressed:(id)sender
{
    if (![self checkValidEmailAddress]) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
        return;
    }
    if (![self checkValidPassword]) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
        return;
    }
    [self processValidLogin];
}

#pragma mark - Form Validation

- (BOOL)checkValidEmailAddress 
{
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:[cellFormDataHolder objectAtIndex:RegisterCellTypeEmail]];
    
//	if (myStringMatchesRegEx) {
//		[self checkValidPassword];
//	} else {
//		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
//		[alert show];
//	}
}

- (BOOL)checkValidPassword
{
	NSString *passwordString = [[cellFormDataHolder objectAtIndex:RegisterCellTypePassword] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
	return ([passwordString length] > 0);
//		[self processValidLogin];
//	} else {
//		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
//		[alert show];
//	}
}

- (void)processValidLogin
{
	[self setUpDataFetcherMessageListeners];
    if (notMember) {
        [[Controller sharedInstance] registerWithEmailAddress:[cellFormDataHolder objectAtIndex:RegisterCellTypeEmail]
                                                  andPassword:[cellFormDataHolder objectAtIndex:RegisterCellTypePassword]
                                                 andFirstName:[cellFormDataHolder objectAtIndex:RegisterCellTypeFirstName]
                                                  andLastName:[cellFormDataHolder objectAtIndex:RegisterCellTypeLastName]];
    } else {
        [[Controller sharedInstance] loginWithEmailAddress:[cellFormDataHolder objectAtIndex:RegisterCellTypeEmail] andPassword:[cellFormDataHolder objectAtIndex:RegisterCellTypePassword]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (notMember) ? RegisterCellTypeCount + 1 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTableViewCell *cell = nil;
    int lastRow = (notMember) ? RegisterCellTypeCount : 2;
    if (indexPath.row == lastRow) {
        cell = [self getCellForCallToAction:(notMember) ? @"I am a member..." : @"Not a member?"];
    } else {
        cell = [self getCellForFormWithIndex:indexPath.row];
    }
    
    [cell isFirst:indexPath.row == 0 isLast:(notMember) ? indexPath.row == RegisterCellTypeCount : indexPath.row == 2];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int lastRow = (notMember) ? RegisterCellTypeCount : 2;
    if (indexPath.row == lastRow) {
        [self toggleNotMember];
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CellFormEntry *targetCell = (CellFormEntry *)cell;
        [targetCell becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellFormEntryHeight;
}

#pragma mark - Table Cells

- (BBTableViewCell *)getCellForFormWithIndex:(int)index
{
//    CellFormEntry *cell = (CellFormEntry *) [self.tableView dequeueReusableCellWithIdentifier:@"CellFormEntry"];
//    if (cell == nil) {
//        cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellFormEntry"] autorelease];
//    }
//    
    CellFormEntry *cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellFormEntry"] autorelease];
    
    if (index == RegisterCellTypeEmail) {
        [cell setTitle:@"Email"];
        [cell setEntryType:CellFormEntryTypeEmail];
        [cell setReturnKeyType:UIReturnKeyNext];
        cell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeEmail];
        cell.index = RegisterCellTypeEmail;
    } else if (index == RegisterCellTypePassword) {
        [cell setTitle:@"Password"];
        [cell setEntryType:CellFormEntryTypePassword];
        [cell setReturnKeyType:(notMember) ? UIReturnKeyNext : UIReturnKeyDone];
        cell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypePassword];
        cell.index = RegisterCellTypePassword;
    } else if (index == RegisterCellTypeMobileNumber) {
        [cell setTitle:@"Mobile"];
        [cell setEntryType:CellFormEntryTypePhone];
        [cell setReturnKeyType:UIReturnKeyNext];
        cell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeMobileNumber];
        cell.index = RegisterCellTypeMobileNumber;
    } else if (index == RegisterCellTypeFirstName) {
        [cell setTitle:@"First Name"];
        [cell setEntryType:CellFormEntryTypeName];
        [cell setReturnKeyType:UIReturnKeyNext];
        cell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeFirstName];
        cell.index = RegisterCellTypeFirstName;
    } else if (index == RegisterCellTypeLastName) {
        [cell setTitle:@"Last Name"];
        [cell setEntryType:CellFormEntryTypeName];
        [cell setReturnKeyType:(notMember) ? UIReturnKeyDone : UIReturnKeyNext];
        cell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeLastName];
        cell.index = RegisterCellTypeLastName;
    }
    cell.delegate = self;
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (BBTableViewCell *)getCellForCallToAction:(NSString *)label
{
    CellEventCallToAction *cell = (CellEventCallToAction *) [self.tableView dequeueReusableCellWithIdentifier:@"ShowHideTableCellId"];
	if (cell == nil) {
		cell = [[[CellEventCallToAction alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowHideTableCellId"] autorelease];
	}
    [cell setTitle:label];
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (void)toggleNotMember
{
    notMember = !notMember;
    CGRect trgRect;
    
    if (notMember)
    {
        trgRect = CGRectMake(0, 0, self.tableView.frame.size.width, 125);
    }
    else
    {
        trgRect = CGRectMake(0, 0, self.tableView.frame.size.width, 64);
    }
    
    tableFooterView.frame = trgRect;
    self.tableView.tableFooterView = tableFooterView;
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if (notMember)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    [loginButton setTitle:(notMember) ? @"Sign-Up" : @"Login" forState:UIControlStateNormal];
}

- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

#pragma mark - HeaderViewLoginRegisterDelegate

- (void)handleFacebookPressed
{
    [self setUpDataFetcherMessageListeners];
    [[ViewController sharedInstance] authenticateWithFacebook];
}

- (void)continueToDashboard
{
	[self removeDataFetcherMessageListeners];
	[[ViewController sharedInstance] navigateToDashboard];
}

#pragma mark - CellFormEntryDelegate
- (void)inputFieldDidReturn:(id)sender
{
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    int lastRow = (notMember) ? RegisterCellTypeCount - 1 : 1;
    if (targetCell.index < lastRow)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:targetCell.index+1 inSection:0];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath: newPath];
        [nextCell becomeFirstResponder];
        [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else
    {
        [targetCell resignFirstResponder];
    }
    
}

- (void)inputFieldDidChange:(id)sender
{
    //NSLog(@"inputFieldDidChange");
    CellFormEntry *targetCell = (CellFormEntry *)sender;
//    NSLog(@"%i : %@", targetCell.index, targetCell.fieldText);
    [cellFormDataHolder replaceObjectAtIndex:targetCell.index withObject:targetCell.fieldText];
    NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    loginButton.enabled = ([self checkValidEmailAddress] && [self checkValidPassword]);
}

- (void)handleDirectFieldTouch:(id)sender
{
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    int a = scrollView.contentOffset.y;
    if (a < 0) a = 0;
    [[ViewController sharedInstance] showDropShadow:a];
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
    if (fetchType == DataFetchTypeLoginWithFacebookAccessToken || fetchType == DataFetchTypeLoginWithUserName) {
        [self continueToDashboard];
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSLog(@"Unhandled Error: %d", fetchType);
}

@end
