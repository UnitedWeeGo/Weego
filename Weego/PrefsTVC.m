//
//  PrefsTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefsTVC.h"
#import "BBTableViewCell.h"
#import "CellPrefsLoginParticipant.h"
#import "CellPrefsControls.h"
#import "CellPrefsLinks.h"

typedef enum {
    PrefsSectionLoginParticipant = 0,
    PrefsSectionControls,
    PrefsSectionLinks,
    NumPrefsSections
} PrefsSections;

@interface PrefsTVC (Private)

- (BBTableViewCell *)getCellForLoginParticipant:(Participant *)aParticipant;
- (BBTableViewCell *)getCellForControlsWithLabel:(NSString *)aLabel andIndex:(int)index andPrefsKey:(NSString *)key;
- (BBTableViewCell *)getCellForLinksWithLabel:(NSString *)aLabel andIndex:(int)index;
- (BBTableViewCell *)getCellForLinksWithLabel:(NSString *)aLabel andInfo:(NSString *)info andIndex:(int)index;

- (void)setUpFooterView;
- (void)handleFacebookPressed:(id)sender;
- (void)handleHomePress:(id)sender;
- (void)handleInfoPress:(id)sender;
- (void)handleHelpPress:(id)sender;
- (void)initiateLogout:(id)sender;

- (void)presentMailModalViewController;

@end

@implementation PrefsTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    [[NavigationSetter sharedInstance] setNavState:NavStatePrefs withTarget:self];
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFF26);
    [self.tableView addSubview:bevelStripe];
    [bevelStripe release];
    [self setUpFooterView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [[ViewController sharedInstance] showDropShadow:0];
    [[ViewController sharedInstance] showHomeBackground];
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
    return NumPrefsSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case PrefsSectionLoginParticipant:
            return 1;
            break;
        case PrefsSectionControls:
            return 2;
            break;
        case PrefsSectionLinks:
            return 3;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PrefsSectionLoginParticipant) return 68;
    return 44.0;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 14;
    return 1.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 11.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBTableViewCell *cell = nil;
    if (indexPath.section == PrefsSectionLoginParticipant) {
        cell = [self getCellForLoginParticipant:[Model sharedInstance].loginParticipant];
        [cell isFirst:YES isLast:YES];
    } else if (indexPath.section == PrefsSectionControls) {
//        if (indexPath.row == 0) {
//            cell = [self getCellForControlsWithLabel:@"Mute Alerts" andIndex:0];
//            [cell isFirst:YES isLast:NO];
//        } else if (indexPath.row == 1) {
        if (indexPath.row == 0) {
            cell = [self getCellForControlsWithLabel:@"Display my location" andIndex:1 andPrefsKey:USER_PREF_ALLOW_TRACKING];
            [cell isFirst:YES isLast:NO];
        } else if (indexPath.row == 1) {
            cell = [self getCellForControlsWithLabel:@"Auto-checkin" andIndex:1 andPrefsKey:USER_PREF_ALLOW_CHECKIN];
            [cell isFirst:NO isLast:YES];
        }
    } else if (indexPath.section == PrefsSectionLinks) {
        if (indexPath.row == 0) {
            cell = [self getCellForLinksWithLabel:@"Feedback" andIndex:0];
            [cell isFirst:YES isLast:NO];
        } else if (indexPath.row == 1) {
            cell = [self getCellForLinksWithLabel:@"Help" andIndex:1];
            [cell isFirst:NO isLast:NO];
        } else if (indexPath.row == 2) {
            cell = [self getCellForLinksWithLabel:@"About" andInfo:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] andIndex:2];
            [cell isFirst:NO isLast:YES];
        }
    }
    
    
    return cell;
}

- (BBTableViewCell *)getCellForLoginParticipant:(Participant *)aParticipant
{
    CellPrefsLoginParticipant *cell = (CellPrefsLoginParticipant *) [self.tableView dequeueReusableCellWithIdentifier:@"CellPrefsLoginParticipantCellId"];
	if (cell == nil) {
		cell = [[[CellPrefsLoginParticipant alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPrefsLoginParticipantCellId"] autorelease];
	}
    cell.participant = aParticipant;
    cell.cellHostView = CellHostViewHome;
    return cell;
}

- (BBTableViewCell *)getCellForControlsWithLabel:(NSString *)aLabel andIndex:(int)index andPrefsKey:(NSString *)key
{
    CellPrefsControls *cell = (CellPrefsControls *) [self.tableView dequeueReusableCellWithIdentifier:@"CellPrefsControlsCellId"];
	if (cell == nil) {
		cell = [[[CellPrefsControls alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPrefsControlsCellId"] autorelease];
	}
    [cell setTitle:aLabel];
    [cell setPrefsKey:key];
    cell.cellHostView = CellHostViewHome;
    return cell;
}

- (BBTableViewCell *)getCellForLinksWithLabel:(NSString *)aLabel andIndex:(int)index
{
    CellPrefsLinks *cell = (CellPrefsLinks *) [self.tableView dequeueReusableCellWithIdentifier:@"CellPrefsLinksCellId"];
	if (cell == nil) {
		cell = [[[CellPrefsLinks alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPrefsLinksCellId"] autorelease];
	}
    [cell setTitle:aLabel];
    cell.cellHostView = CellHostViewHome;
    return cell;
}

- (BBTableViewCell *)getCellForLinksWithLabel:(NSString *)aLabel andInfo:(NSString *)info andIndex:(int)index
{
    CellPrefsLinks *cell = (CellPrefsLinks *) [self.tableView dequeueReusableCellWithIdentifier:@"CellPrefsLinksCellId"];
	if (cell == nil) {
		cell = [[[CellPrefsLinks alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellPrefsLinksCellId"] autorelease];
	}
    [cell setTitle:aLabel];
    [cell setInfo:info];
    cell.cellHostView = CellHostViewHome;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == PrefsSectionLinks) {
        if (indexPath.row == 0) {
            [self presentMailModalViewController];
        } else if (indexPath.row == 1) {
            [self handleHelpPress:nil];
        } else if (indexPath.row == 2) {
            [self handleInfoPress:nil];
        }
    }

}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int a = scrollView.contentOffset.y;
    if (a < 0) a = 0;
    [[ViewController sharedInstance] showDropShadow:a];
}

#pragma mark - Private Methods

- (void)handleFacebookPressed:(id)sender
{
    [[ViewController sharedInstance] authenticateWithFacebook];
}

- (void)handleHomePress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

- (void)handleInfoPress:(id)sender
{
    [[ViewController sharedInstance] navigateToInfo];
}

- (void)handleHelpPress:(id)sender
{
    [[ViewController sharedInstance] navigateToHelp];
}

- (void)initiateLogout:(id)sender
{
    [[ViewController sharedInstance] logoutUser:self];
}

- (void)setUpFooterView
{
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 75)];
    
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_lrg_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_lrg_pressed.png"];
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    UIColor *shadowColor = HEXCOLOR(0x000000FF);
    
    CGRect buttonTargetSize = CGRectMake(8, 8, bg1.size.width, bg1.size.height);
    
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.adjustsImageWhenHighlighted = NO;
    logoutButton.frame = buttonTargetSize;
    [logoutButton addTarget:self action:@selector(initiateLogout:) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setBackgroundImage:bg1 forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [logoutButton setBackgroundImage:bg2 forState:UIControlStateDisabled];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setTitleColor:col forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
    logoutButton.titleLabel.lineBreakMode = UILineBreakModeClip;
    logoutButton.titleLabel.shadowColor = shadowColor;
    logoutButton.titleLabel.shadowOffset = CGSizeMake(1.0, 2.0);
    logoutButton.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    [footerView addSubview:logoutButton];
    
    // ------
    
    loginFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    loginFacebook.adjustsImageWhenHighlighted = NO;
    loginFacebook.frame = CGRectMake(8, 8, bg1.size.width, bg1.size.height);
    [loginFacebook setBackgroundImage:bg1 forState:UIControlStateNormal];
    [loginFacebook setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [loginFacebook addTarget:self action:@selector(handleFacebookPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loginFacebook setImage:[UIImage imageNamed:@"icon_facebook.png"] forState:UIControlStateNormal];
    [loginFacebook setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    loginFacebook.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    loginFacebook.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    loginFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [loginFacebook setTitleColor:col forState:UIControlStateNormal];
    loginFacebook.titleLabel.shadowColor = shadowColor;
    loginFacebook.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [footerView addSubview:loginFacebook];
    
    if ([Model sharedInstance].isInTrial) {
        logoutButton.hidden = YES;
        loginFacebook.hidden = NO;
    } else {
        logoutButton.hidden = NO;
        loginFacebook.hidden = YES;
    }
    
    self.tableView.tableFooterView = footerView;
    [footerView release];
}

#pragma mark -
#pragma mark MFMailComposeViewController Methods

- (void)presentMailModalViewController
{
    Model *model = [Model sharedInstance];
    Participant *me = model.loginParticipant;
    NSString *title = @"weego";
    NSString *subject = [NSString stringWithFormat:@"weego message from %@ : v %@", me.fullName, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    NSString *body = @"";
    NSArray *recipients = [NSArray arrayWithObject:@"feedback@unitedweego.com"];
    
    [[ViewController sharedInstance] showMailModalViewControllerInView:self withTitle:title andSubject:subject andMessageBody:body andToRecipients:recipients];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {    
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
