//
//  RegisterTVC.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RegisterTVC.h"
#import "CellFormEntry.h"
#import "Controller.h"

typedef enum {
    RegisterCellTypeFirstName = 0,
    RegisterCellTypeLastName,
    RegisterCellTypeMobileNumber,
    RegisterCellTypeEmail,
    RegisterCellTypePassword,
    RegisterCellTypeCount
} RegisterCellType;

@interface RegisterTVC(Private)

- (void)checkValidEmailAddress;
- (void)checkValidPassword;
- (void)processValidRegistrant;
//- (CellFormEntry *)getCellFormEntryCellForType:(RegisterCellType)type;
- (void) createFooterView;
- (void)handleFbConnectPressed;

@end

@implementation RegisterTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        cellFormDataHolder = [[NSMutableArray alloc] initWithCapacity:RegisterCellTypeCount];
        for (int i = 0; i < RegisterCellTypeCount; i++) [cellFormDataHolder insertObject:@"" atIndex:i];
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
//    [Model sharedInstance].currentViewState = ViewStateRegister;
//    [[NavigationSetter sharedInstance] setNavState:NavStateRegister withTarget:self];
    
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
    
    [Model sharedInstance].currentViewState = ViewStateRegister;
    [[NavigationSetter sharedInstance] setNavState:NavStateRegister withTarget:self];
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    
    [self setUpDataFetcherMessageListeners];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeDataFetcherMessageListeners];
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

#pragma mark - Public Methods

- (void)prepopulateFormWithFacebookInfo:(NSDictionary *)facebook
{
    NSString *firstName = [facebook objectForKey:@"first_name"];
    NSString *lastName = [facebook objectForKey:@"last_name"];
    NSString *email = [facebook objectForKey:@"email"];
    NSString *userName = [facebook objectForKey:@"username"];
    [cellFormDataHolder replaceObjectAtIndex:RegisterCellTypeFirstName withObject:firstName];
    [cellFormDataHolder replaceObjectAtIndex:RegisterCellTypeLastName withObject:lastName];
    [cellFormDataHolder replaceObjectAtIndex:RegisterCellTypeEmail withObject:email];
    
    
    if (avatarImage == nil) avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(10, 355, 50, 50)] autorelease];
    [self.view addSubview:avatarImage];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", userName]];
    [avatarImage asyncLoadWithNSURL:url useCached:YES andBaseImage:BaseImageTypeAvatar useBorder:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return RegisterCellTypeCount; // only 1 section in this view 
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
    
    if (indexPath.row == RegisterCellTypeFirstName) {
        [targetCell setTitle:@"First Name"];
        [targetCell setEntryType:CellFormEntryTypeName];
        [targetCell setReturnKeyType:UIReturnKeyNext];
        targetCell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeFirstName];
        targetCell.index = RegisterCellTypeFirstName;
    } else if (indexPath.row == RegisterCellTypeLastName) {
        [targetCell setTitle:@"Last Name"];
        [targetCell setEntryType:CellFormEntryTypeName];
        [targetCell setReturnKeyType:UIReturnKeyNext];
        targetCell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeLastName];
        targetCell.index = RegisterCellTypeLastName;
    } else if (indexPath.row == RegisterCellTypeMobileNumber) {
        [targetCell setTitle:@"Mobile"];
        [targetCell setEntryType:CellFormEntryTypePhone];
        [targetCell setReturnKeyType:UIReturnKeyNext];
        targetCell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeMobileNumber];
        targetCell.index = RegisterCellTypeMobileNumber;
    } else if (indexPath.row == RegisterCellTypeEmail) {
        [targetCell setTitle:@"Email"];
        [targetCell setEntryType:CellFormEntryTypeEmail];
        [targetCell setReturnKeyType:UIReturnKeyNext];
        targetCell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypeEmail];
        targetCell.index = RegisterCellTypeEmail;
    } else if (indexPath.row == RegisterCellTypePassword) {
        [targetCell setTitle:@"Password"];
        [targetCell setEntryType:CellFormEntryTypePassword];
        [targetCell setReturnKeyType:UIReturnKeyDone];
        targetCell.fieldText = [cellFormDataHolder objectAtIndex:RegisterCellTypePassword];
        targetCell.index = RegisterCellTypePassword;
    }
    
    [targetCell isFirst:indexPath.row == RegisterCellTypeFirstName isLast:indexPath.row == RegisterCellTypePassword];
    
    return targetCell;
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
    if (targetCell.index < RegisterCellTypePassword)
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
    NSLog(@"%i : %@", targetCell.index, targetCell.fieldText);
    [cellFormDataHolder replaceObjectAtIndex:targetCell.index withObject:targetCell.fieldText];
    NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 	
    BOOL myStringMatchesRegEx = [emailTest evaluateWithObject:[cellFormDataHolder objectAtIndex:RegisterCellTypeEmail]];
    
	if (myStringMatchesRegEx) {
		[self checkValidPassword];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)checkValidPassword
{
	NSString *passwordString = [[cellFormDataHolder objectAtIndex:RegisterCellTypePassword] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if ([passwordString length] > 0) {
		[self processValidRegistrant];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please check you have entered a valid password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)processValidRegistrant
{
	[[Controller sharedInstance] registerWithEmailAddress:[cellFormDataHolder objectAtIndex:RegisterCellTypeEmail]
                                              andPassword:[cellFormDataHolder objectAtIndex:RegisterCellTypePassword]
                                             andFirstName:[cellFormDataHolder objectAtIndex:RegisterCellTypeFirstName]
                                              andLastName:[cellFormDataHolder objectAtIndex:RegisterCellTypeLastName]];
}

- (void)continueToDashboard
{
	[[ViewController sharedInstance] navigateToDashboard];
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
    UIImage *footerImage = [UIImage imageNamed:@"register_footer_temp.png"];
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerImage.size.height + 7)] autorelease];
    
    UIImageView *footerImageView = [[[UIImageView alloc] initWithImage:footerImage] autorelease];
    footerImageView.frame = CGRectMake(8, 7, footerImage.size.width, footerImage.size.height);
    
    [footerView addSubview:footerImageView];
    
    UIButton *fbConnectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbConnectButton.frame = CGRectMake(9, 33, 300, 44);
    fbConnectButton.backgroundColor = HEXCOLOR(0x00FF0000);
    fbConnectButton.showsTouchWhenHighlighted = NO;
    [fbConnectButton addTarget:self action:@selector(handleFbConnectPressed) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:fbConnectButton];
    
    self.tableView.tableFooterView = footerView;
}

#pragma mark -
#pragma mark Button Actions

- (void)handleFbConnectPressed
{
    [[ViewController sharedInstance] authenticateWithFacebook];
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
        case DataFetchTypeLoginWithUserName:
            [self continueToDashboard];
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
        case DataFetchTypeLoginWithUserName:
            NSLog(@"Unhandled Error: %d", fetchType);
            break;
            
        default:
            break;
    }
}

@end
