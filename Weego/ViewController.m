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
#import "AddressBookTVC.h"
#import "AddressBookLocationsTVC.h"
#import "EditEventTVC.h"
#import "Info.h"
#import "Help.h"
#import "Terms.h"
#import "Privacy.h"
#import "DealsView.h"
#import "ActionSheetController.h"

@interface ViewController(Private)
- (void)clearLoginKeyChainData;
- (NSString *)getCurrentViewStack;
- (void)removeAllViewsFromStack;
@end

@implementation ViewController

@synthesize stack;

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
    self = [super init];
    if (self) {
        appDelegate = (WeegoAppDelegate *)[[UIApplication sharedApplication] delegate];
        nController = appDelegate.navigationController;
        navigationIndexingCollection = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"ViewController dealloc");
    [self.stack release];
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
    [self removeAllViewsFromStack];
    [self addAndReportViewWithName:@"/entry"];
    [Model sharedInstance].currentAppState = AppStateEntry;
    [Model sharedInstance].currentViewState = ViewStateEntry;
    [self showHomeBackground];
    dashboardVC = nil;
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
    if (!dashboardVC) dashboardVC = dashboardView;
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
    [appDelegate logoutFromFacebook];
    dashboardVC = nil;
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
    if (!dashboardVC) dashboardVC = dashboardController;
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
    CreateEventTVC *createEventViewController = [[CreateEventTVC alloc] init];
	UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:createEventViewController];
    navCon.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navCon.navigationBar.tintColor = HEXCOLOR(0x858585FF);
    nController = navCon;
	[inView presentModalViewController:navCon animated:YES];
	[createEventViewController release];
	[navCon release];
}

- (void)showModalDuplicateEvent:(UIViewController *)inView withEvent:(Event *)anEvent
{
    [self addAndReportViewWithName:@"/duplicate_event"];
    [Model sharedInstance].currentViewState = ViewStateCreate; // ViewStateDuplicate;
    CreateEventTVC *createEventViewController = [[CreateEventTVC alloc] init];
    createEventViewController.isInDuplicate = YES;
    createEventViewController.eventId = anEvent.eventId;
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

- (void)navigateToAddressBook:(AddFriends *)delegate
{
    [self addAndReportViewWithName:@"/addressBook"];
    AddressBookTVC *addressBookController = [[AddressBookTVC alloc] init];
    addressBookController.dataSource = delegate;
    addressBookController.delegate = delegate;
    [Model sharedInstance].currentViewState = ViewStateAddressBook;
	[nController pushViewController:addressBookController animated:YES];
	[addressBookController release];
}

- (void)navigateToAddressBookLocations:(AddLocation *)delegate
{
    [self addAndReportViewWithName:@"/addressBookLocations"];
    AddressBookLocationsTVC *addressBookController = [[AddressBookLocationsTVC alloc] init];
    addressBookController.dataSource = delegate;
    addressBookController.delegate = delegate;
    [Model sharedInstance].currentViewState = ViewStateAddressBookLocations;
	[nController pushViewController:addressBookController animated:YES];
	[addressBookController release];
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

- (void)navigateToTerms
{
    [self addAndReportViewWithName:@"/terms"];
    [Model sharedInstance].currentViewState = ViewStateTerms;
    [self showEventBackground];
    Terms *termsController = [[Terms alloc] init];
    [nController pushViewController:termsController animated:YES];
	[termsController release];
}

- (void)navigateToPrivacy
{
    [self addAndReportViewWithName:@"/privacy"];
    [Model sharedInstance].currentViewState = ViewStatePrivacy;
    [self showEventBackground];
    Privacy *privacyController = [[Privacy alloc] init];
    [nController pushViewController:privacyController animated:YES];
	[privacyController release];
}

- (void)goBack
{
    [nController popViewControllerAnimated:YES];
    [self removeCurrentAndReportPreviousView];
}

- (void)goBackToDashboardFromAddLocations
{
    nController = appDelegate.navigationController;
    [nController popToViewController:dashboardVC animated:YES];
    [self removeCurrentAndReportPreviousView];
}

- (void)dismissModal:(UIViewController *)modalView
{
    nController = appDelegate.navigationController;
    [modalView dismissModalViewControllerAnimated:YES];
    [self removeCurrentAndReportPreviousView];
}

- (void)dismissDuplicateEventModalAfterSuccess:(UIViewController *)modalView
{
    nController = appDelegate.navigationController;
    [nController popToViewController:dashboardVC animated:NO];
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

- (void)showDeal:(NSString *)SGID
{
#warning Should we add deal code to GA tracking?
    [self addAndReportViewWithName:@"/deal"];
    [Model sharedInstance].currentViewState = ViewStateDeal;
    [self showEventBackground];
    DealsView *dealController = [[DealsView alloc] init];
    dealController.SGID = SGID;
    [nController pushViewController:dealController animated:YES];
	[dealController release];
    
//    [appDelegate showDeal];
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
    self.stack = @"";
    int stackCount = [navigationIndexingCollection count];
    for (int i=0; i<stackCount; i++) {
        NSString *curView = [navigationIndexingCollection objectAtIndex:i];
        self.stack = [self.stack stringByAppendingString:curView];
    }
    return self.stack;
}
- (void)addAndReportViewWithName:(NSString *)name
{
    [navigationIndexingCollection addObject:name];
    NSError *error;
    NSString *toReportPath = [self getCurrentViewStack];
    if (toReportPath == nil) return;
    if (![[GANTracker sharedTracker] trackPageview:toReportPath
                                         withError:&error]) {
    }
}
- (void)removeCurrentAndReportPreviousView
{
    [navigationIndexingCollection removeLastObject];
    NSError *error;
    NSString *toReportPath = [self getCurrentViewStack];
    if (toReportPath == nil) return;
    if (![[GANTracker sharedTracker] trackPageview:toReportPath
                                         withError:&error]) {
    }
}
- (void)removeAllViewsFromStack
{
    [navigationIndexingCollection removeAllObjects];
}
@end
