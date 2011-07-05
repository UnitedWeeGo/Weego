//
//  ViewController.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrefsTVC.h"
#import "LoginTVC.h"
#import "DashboardTVC.h"
#import "EventDetailTVC.h"
#import "CreateEventTVC.h"
#import "UINavigationBar+CustomBackground.h"
#import "Feed.h"
#import "KeychainManager.h"
#import "RegisterTVC.h"
#import "EntryPoint.h"
#import "AddFriends.h"
#import "EditEventTVC.h"
#import "Info.h"
#import "Help.h"

@interface ViewController(Private)
- (void)clearLoginKeyChainData;
- (NSString *)getCurrentViewStack;
- (void)removeAllViewsFromStack;
@end

@implementation ViewController

static ViewController *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (ViewController *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[ViewController alloc] init];       
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton ViewController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}

-(id) init {
    if (self == [super init]) {
        appDelegate = (WeegoAppDelegate *)[[UIApplication sharedApplication] delegate];
        nController = appDelegate.navigationController;
        navigationIndexingCollection = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"ViewController dealloc");
    [navigationIndexingCollection release];
    appDelegate = nil;
    nController = nil;
    [super dealloc];
}

- (UINavigationController *)currentNavController
{
    return nController;
}

- (void)enterOnEntryScreen
{
    [self addAndReportViewWithName:@"/entry"];
    [Model sharedInstance].currentAppState = AppStateEntry;
    [Model sharedInstance].currentViewState = ViewStateEntry;
    [self showHomeBackground];
    EntryPoint *entryView = [[EntryPoint alloc] init];
    NSArray *newviews = [[NSArray alloc] initWithObjects:entryView, nil];
    nController = appDelegate.navigationController;
    [nController setViewControllers:newviews animated:NO];
    [entryView release];
    [newviews release];
}
/*
- (void)showLogin:(UIViewController *)inView
{
    [Model sharedInstance].currentViewState = ViewStateLogin;
    LoginTVC *loginUserController = [[LoginTVC alloc] init];
    nController = appDelegate.navigationController;
    [nController pushViewController:loginUserController animated:YES];
	[loginUserController release];
}

- (void)showRegistration:(UIViewController *)inView
{
    [Model sharedInstance].currentViewState = ViewStateRegister;
//    RegisterTVC *registerUserController = [[RegisterTVC alloc] init];
    LoginRegisterTVC *registerUserController = [[LoginRegisterTVC alloc] init];
    nController = appDelegate.navigationController;
    [nController pushViewController:registerUserController animated:YES];
	[registerUserController release];
}
 */

- (void)enterOnDashboard
{
    [self addAndReportViewWithName:@"/dashboard"];
    [Model sharedInstance].currentAppState = AppStateDashboard;
    [Model sharedInstance].currentViewState = ViewStateDashboard;
    [[Model sharedInstance] setCurrentEventById:nil];
    [self showHomeBackground];
    DashboardTVC *dashboardView = [[DashboardTVC alloc] init];
    nController = appDelegate.navigationController;
    [nController pushViewController:dashboardView animated:NO];
    [dashboardView release];
}
/*
- (void)enterOnRegister:(NSDictionary *)facebook
{
    [Model sharedInstance].currentAppState = AppStateLogin;
    [Model sharedInstance].currentViewState = ViewStateRegister;
    [self showHomeBackground];
    EntryPoint *entryView = [[EntryPoint alloc] init];
    RegisterTVC *registerUserController = [[RegisterTVC alloc] init];
    [registerUserController prepopulateFormWithFacebookInfo:facebook];
    NSArray *newviews = [[NSArray alloc] initWithObjects:entryView, registerUserController, nil];
    nController = appDelegate.navigationController;
    [nController setViewControllers:newviews animated:NO];
    [entryView release];
    [registerUserController release];
    [newviews release];
}
*/
- (void)showPrefsView: (UIViewController *)inView
{
    [self addAndReportViewWithName:@"/settings"];
    [Model sharedInstance].currentViewState = ViewStatePrefs;
//	Prefs *prefsViewController = [[Prefs alloc] init];
    PrefsTVC *prefsViewController = [[PrefsTVC alloc] init];
	nController = appDelegate.navigationController;
    [nController pushViewController:prefsViewController animated:YES];
	[prefsViewController release];
}

- (void)logoutUser: (UIViewController *)inView
{
    [self removeAllViewsFromStack];
    [self addAndReportViewWithName:@"/entry"];
    [Model sharedInstance].currentAppState = AppStateEntry;
    [Model sharedInstance].currentViewState = ViewStateEntry;
    [[Model sharedInstance] clearData];
    [self clearLoginKeyChainData];
    EntryPoint *entryView = [[EntryPoint alloc] init];
    NSArray *newviews = [[NSArray alloc] initWithObjects:entryView, nil];
    nController = appDelegate.navigationController;
    [nController setViewControllers:newviews animated:YES];
    [entryView release];
    [newviews release];
}

- (void)clearLoginKeyChainData
{
    [[KeychainManager sharedInstance] resetKeychain];
}

- (void)navigateToDashboard
{
    [self addAndReportViewWithName:@"/dashboard"];
    BOOL animated = [Model sharedInstance].currentAppState != AppStateEntry;
    [Model sharedInstance].currentAppState = AppStateDashboard;
    [Model sharedInstance].currentViewState = ViewStateDashboard;
    [[Model sharedInstance] setCurrentEventById:nil];
    [self showHomeBackground];
    DashboardTVC *dashboardController = [[DashboardTVC alloc] init];
    nController = appDelegate.navigationController;
	[nController pushViewController:dashboardController animated:animated];
	[dashboardController release];
}

- (void)showModalFeed:(UIViewController *)inView
{
    [self addAndReportViewWithName:@"/feed"];
    [Model sharedInstance].currentViewState = ViewStateFeed;
    Feed *feedViewController = [[Feed alloc] init];
	UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:feedViewController];
    navCon.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navCon.navigationBar.tintColor = HEXCOLOR(0x858585FF);
    navCon.view.frame = CGRectMake(0, 244, 320, 416);
    [inView presentModalViewController:navCon animated:YES];
	[feedViewController release];
	[navCon release];
}
     
- (void)showFeedNavBar
{
    nController.navigationBar.hidden = NO;
}


- (void)navigateToEventDetailWithId:(NSString *)eventId
{
    [self addAndReportViewWithName:@"/event_detail"];
    [Model sharedInstance].currentAppState = AppStateEventDetails;
    [Model sharedInstance].currentViewState = ViewStateDetails;
    [[Model sharedInstance] setCurrentEventById:eventId];
    [self showEventBackground];
    EventDetailTVC *detailViewController = [[EventDetailTVC alloc] init];
    nController = appDelegate.navigationController;
    [nController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)showMailModalViewControllerInView:(UIViewController<MFMailComposeViewControllerDelegate> *)inView withTitle:(NSString *)title andSubject:(NSString *)subject andMessageBody:(NSString *)body andToRecipients:(NSArray *)receipients
{
    if ([MFMailComposeViewController canSendMail]) {
        
        [self addAndReportViewWithName:@"/message_user"];
        MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
        mfViewController.mailComposeDelegate = inView;
        [mfViewController setSubject:subject];
        [mfViewController setTitle:title];
        [mfViewController setMessageBody:body isHTML:NO];
        [mfViewController setNavigationBarHidden:NO];
        [mfViewController setToolbarHidden:YES];
        [mfViewController setToRecipients:receipients];
        
        [inView presentModalViewController:mfViewController animated:YES];
        [mfViewController release];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status:" message:@"Your phone is not currently configured to send mail." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void)showModalCreateEvent:(UIViewController *)inView
{
    [self addAndReportViewWithName:@"/create_event"];
    [Model sharedInstance].currentViewState = ViewStateCreate;
//    [self showEventBackground];
    CreateEventTVC *createEventViewController = [[CreateEventTVC alloc] init];
	UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:createEventViewController];
    navCon.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navCon.navigationBar.tintColor = HEXCOLOR(0x858585FF);
    nController = navCon;
	[inView presentModalViewController:navCon animated:YES];
	[createEventViewController release];
	[navCon release];
}

- (void)navigateToAddLocationsWithEntryState:(AddLocationInitState)state
{
    [self addAndReportViewWithName:@"/map"];
    [Model sharedInstance].currentViewState = ViewStateMap;
    AddLocation *addController = [[AddLocation alloc] initWithState:state];
    [nController pushViewController:addController animated:YES];
	[addController release];
}
- (void)navigateToAddLocationsWithLocationOpen:(NSString *)locId
{
    [self addAndReportViewWithName:@"/map"];
    [Model sharedInstance].currentViewState = ViewStateMap;
    AddLocation *addController = [[AddLocation alloc] initWithLocationOpen:locId];
    [nController pushViewController:addController animated:YES];
	[addController release];
}

- (void)navigateToAddParticipants
{
    [self addAndReportViewWithName:@"/invite"];
    AddFriends *addParticipantController = [[AddFriends alloc] init];
    [Model sharedInstance].currentViewState = ViewStateAddParticipant;
	[nController pushViewController:addParticipantController animated:YES];
	[addParticipantController release];
}

- (void)navigateToEditEvent
{
    [self addAndReportViewWithName:@"/event_edit"];
    [Model sharedInstance].currentViewState = ViewStateEdit;
    EditEventTVC *editEventController = [[EditEventTVC alloc] init];
    [nController pushViewController:editEventController animated:YES];
	[editEventController release];
}

- (void)navigateToInfo
{
    [self addAndReportViewWithName:@"/info"];
    [Model sharedInstance].currentViewState = ViewStateInfo;
    [self showEventBackground];
    Info *infoController = [[Info alloc] init];
    [nController pushViewController:infoController animated:YES];
	[infoController release];
}

- (void)navigateToHelp
{
    [self addAndReportViewWithName:@"/help"];
    [Model sharedInstance].currentViewState = ViewStateHelp;
    [self showEventBackground];
    Help *helpController = [[Help alloc] init];
    [nController pushViewController:helpController animated:YES];
	[helpController release];
}

- (void)goBack
{
    [nController popViewControllerAnimated:YES];
    [self removeCurrentAndReportPreviousView];
}

- (void)dismissModal:(UIViewController *)modalView
{
    nController = appDelegate.navigationController;
    [modalView dismissModalViewControllerAnimated:YES];
    [self removeCurrentAndReportPreviousView];
}

- (void)showHomeBackground
{
    [Model sharedInstance].currentBGState = BGStateHome;
    [appDelegate hideEventBackground];
}

- (void)showEventBackground
{
    [Model sharedInstance].currentBGState = BGStateEvent;
    [appDelegate showEventBackground];
    [appDelegate hideFeedBackground];
}

- (void)showFeedBackground
{
    [Model sharedInstance].currentBGState = BGStateFeed;
    [appDelegate showFeedBackground];
}


- (void)showDropShadow:(int)amount
{
    [appDelegate showDropShadow:amount];
}

- (void)showDeal
{
    [appDelegate showDeal];
}

- (void)hideDeal
{
    [appDelegate hideDeal];
}

- (void)showFacebookPopup
{
    [appDelegate showFacebookPopup];
}

- (void)hideFacebookPopupWithAnimation:(BOOL)animated
{
    [appDelegate hideFacebookPopupWithAnimation:animated];
}

- (void)authenticateWithFacebook
{
    [appDelegate authenticateWithFacebook];
}

- (void)hideLoadView
{
    [appDelegate hideLoadView];
}

#pragma mark -
#pragma mark Google Analytics
- (NSString *)getCurrentViewStack
{
    NSString *stack = @"";
    int stackCount = [navigationIndexingCollection count];
    for (int i=0; i<stackCount; i++) {
        NSString *curView = [navigationIndexingCollection objectAtIndex:i];
        stack = [stack stringByAppendingString:curView];
    }
    return stack;
}
- (void)addAndReportViewWithName:(NSString *)name
{
    [navigationIndexingCollection addObject:name];
    NSLog(@"GANTracker send nav: %@", [self getCurrentViewStack]);
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:[self getCurrentViewStack]
                                         withError:&error]) {
        NSLog(@"GANTracker error: %@", [error description]);
    }
}
- (void)removeCurrentAndReportPreviousView
{
    [navigationIndexingCollection removeLastObject];
    NSLog(@"GANTracker send nav: %@", [self getCurrentViewStack]);
    NSError *error;
    if (![[GANTracker sharedTracker] trackPageview:[self getCurrentViewStack]
                                         withError:&error]) {
        NSLog(@"GANTracker error: %@", [error description]);
    }
}
- (void)removeAllViewsFromStack
{
    [navigationIndexingCollection removeAllObjects];
}
@end