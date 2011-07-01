//
//  LoginTVC.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginTVC.h"
#import "CellFormEntry.h"
#import "Controller.h"
#import "UnderlineLabel.h"

typedef enum {
    LoginCellTypeEmail = 0,
    LoginCellTypePassword,
    LoginCellTypeCount
} LoginCellType;

@interface LoginTVC(Private)

- (void)checkValidEmailAddress;
- (void)checkValidPassword;
- (void)processValidLogin;
- (CellFormEntry *)getCellFormEntryCellForType:(LoginCellType)type;
- (void) createFooterView;

@end

@implementation LoginTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
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
    [Model sharedInstance].currentViewState = ViewStateLogin;
    [[NavigationSetter sharedInstance] setNavState:NavStateLogin withTarget:self];
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFF26);
    [self.tableView addSubview:bevelStripe];
    [bevelStripe release];
    
    [self createFooterView];
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
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return LoginCellTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellFormEntry";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    CellFormEntry *targetCell = (CellFormEntry *)cell;
    targetCell.delegate = self;
    targetCell.index = indexPath.row;
    
    if (indexPath.row == LoginCellTypeEmail) {
        [targetCell setTitle:@"Email"];
        [targetCell setEntryType:CellFormEntryTypeEmail];
        [targetCell setReturnKeyType:UIReturnKeyNext];
    } else if (indexPath.row == LoginCellTypePassword) {
        [targetCell setTitle:@"Password"];
        [targetCell setEntryType:CellFormEntryTypePassword];
        [targetCell setReturnKeyType:UIReturnKeyDone];
    }
    
    [targetCell isFirst:indexPath.row == LoginCellTypeEmail isLast:indexPath.row == LoginCellTypePassword];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // focus the cell input
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CellFormEntry *targetCell = (CellFormEntry *)cell;
    [targetCell becomeFirstResponder];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellFormEntryHeight;
}

#pragma mark - CellFormEntryDelegate
- (void)inputFieldDidReturn:(id)sender
{
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    if (targetCell.index < LoginCellTypePassword)
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

- (void)handleBackPress:(id)sender
{
	[[ViewController sharedInstance] goBack];
}

- (void)handleDirectFieldTouch:(id)sender
{
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)handleRightActionPress:(id)sender // the register button
{
    [self checkValidEmailAddress];
}

- (void)checkValidEmailAddress {
    CellFormEntry *targetCell = [self getCellFormEntryCellForType:LoginCellTypeEmail];
    
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    BOOL myStringMatchesRegEx = [emailTest evaluateWithObject:[targetCell fieldText]];
    
	if (myStringMatchesRegEx) {
		[self checkValidPassword];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)checkValidPassword
{
    CellFormEntry *targetCell = [self getCellFormEntryCellForType:LoginCellTypePassword];
    
	NSString *passwordString = [[targetCell fieldText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
	if ([passwordString length] > 0) {
		[self processValidLogin];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)processValidLogin
{
    [[Controller sharedInstance] loginWithEmailAddress:[[self getCellFormEntryCellForType:LoginCellTypeEmail] fieldText] andPassword:[[self getCellFormEntryCellForType:LoginCellTypePassword] fieldText]];
}

- (void)continueToDashboard
{
	[[ViewController sharedInstance] navigateToDashboard];
}

- (CellFormEntry *)getCellFormEntryCellForType:(LoginCellType)type
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:type inSection:0];
    UITableViewCell *theCell = [self.tableView cellForRowAtIndexPath: path];
    
    CellFormEntry *targetCell = (CellFormEntry *)theCell;
    return targetCell;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    int a = scrollView.contentOffset.y;
    if (a < 0) a = 0;
    [[ViewController sharedInstance] showDropShadow:a];
}

#pragma mark -
#pragma mark Footer View
- (void) createFooterView
{
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)] autorelease];
    
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    
    CGRect footerRect = CGRectMake(100, 10, 0, 0);
    
    UILabel *footerCopy = [[[UILabel alloc] initWithFrame:footerRect] autorelease];
    footerCopy.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    [footerCopy setTextColor:col];
    [footerCopy setText:@"Forgot password?"];
    [footerCopy setBackgroundColor:[UIColor clearColor]];
    [footerCopy sizeToFit];
    UIColor *shadowColor = HEXCOLOR(0x000000FF);
    footerCopy.shadowColor = shadowColor;
    footerCopy.shadowOffset = CGSizeMake(0.0, 1.0);
    
    CGRect footerRect2 = CGRectMake(198, 10, 0, 0);
    UnderlineLabel *footerCopy2 = [[[UnderlineLabel alloc] initWithFrame:footerRect2] autorelease];
    footerCopy2.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    [footerCopy2 setTextColor:col];
    [footerCopy2 setText:@"Reset"];
    [footerCopy2 setBackgroundColor:[UIColor clearColor]];
    [footerCopy2 sizeToFit];
    footerCopy2.shadowColor = shadowColor;
    footerCopy2.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [footerView addSubview:footerCopy];
    [footerView addSubview:footerCopy2];
    
    self.tableView.tableFooterView = footerView;
}


@end
