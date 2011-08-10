//
//  WeegoAppDelegate.m
//  Weego
//
//  Created by Nicholas Velloff on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WeegoAppDelegate.h"
#import "DashboardTVC.h"
#import <SimpleGeo/ASIHTTPRequest.h>
#import "BBDownloadCache.h"
#import "DataParser.h"
#import "KeychainManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface WeegoAppDelegate(Private)
- (void)initCache;
- (void)initStartView;
- (void)initViews;
- (void)startTimer;
- (void)reportTimerTick;
- (void)initAnalytics;
- (void)registerDeviceForRemoteNotifications:(UIApplication *)application;
- (void)initDefaultPrefs;
- (void)initSimpleGeoCategories;
- (void)showLoginError;
@end

@implementation WeegoAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize deviceToken;
@synthesize facebook;
@synthesize startOnRegister;
@synthesize loggingInFacebook;

- (void)initCache
{
    //NSLog(@"initCache");
    // init the caching mechanism
    [ASIHTTPRequest setDefaultCache:[BBDownloadCache sharedCache]];
    //[[BBDownloadCache sharedCache] clearCachedResponsesForStoragePolicy:ASICachePermanentlyCacheStoragePolicy | ASICacheForSessionDurationCacheStoragePolicy];
    // When you turn shouldRespectCacheControlHeaders off, the cache will store responses even if the server 
    // has explictly asked for them not be be cached (eg with a cache-control or pragma: no-cache header)
    [[BBDownloadCache sharedCache] setShouldRespectCacheControlHeaders:YES];
}

- (void)checkForUpdateWithServerReportedVerion
{
    if (lastDisplayedVersionAlertDate != nil)
    {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate: lastDisplayedVersionAlertDate];
        int sevenDaysInSeconds = 86400 * APP_STORE_VERSION_CHECK_FREQUENCY_DAYS;
        if (interval > sevenDaysInSeconds) 
        {
            [lastDisplayedVersionAlert release];
            lastDisplayedVersionAlert = [[NSString stringWithString:@"none"] retain];
        }
    }
    
    
    NSString *currentlyInstalledVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *serverVersion = [userPreferences objectForKey:APP_STORE_VERSION];
    if (![currentlyInstalledVersion isEqualToString:serverVersion] && ![lastDisplayedVersionAlert isEqualToString:serverVersion])
    {
        lastDisplayedVersionAlert = [serverVersion retain];
        lastDisplayedVersionAlertDate = [[NSDate date] retain];
        NSString *alertMessage = [NSString stringWithFormat:@"Version %@ is now available. Please update to get the most out of weego!", serverVersion];
        UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Update available" message:alertMessage delegate:self cancelButtonTitle:@"Now now" otherButtonTitles:@"Update!", nil];
        [updateAlert show];
        [updateAlert release];
    }
}

- (void)initDefaultPrefs
{
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    if (nil == [userPreferences objectForKey:USER_PREF_ALLOW_TRACKING])
    {
        [userPreferences setBool:YES forKey:USER_PREF_ALLOW_TRACKING];
    }
    if (nil == [userPreferences objectForKey:USER_PREF_ALLOW_CHECKIN])
    {
        [userPreferences setBool:YES forKey:USER_PREF_ALLOW_CHECKIN];
    }
    [userPreferences synchronize];
}

- (void)initStartView
{
    //    NSLog(@"initStartView");
    
    NSDictionary *kItems = [[[KeychainManager sharedInstance] retreiveKeychainItems] copy];
    NSString * firstName = [kItems objectForKey:(id)KeychainIdFirstname];
    NSString * lastName = [kItems objectForKey:(id)KeychainIdLastName];
    NSString * ruid = [kItems objectForKey:(id)KeychainIdRUID];
    NSString * emailAddress = [kItems objectForKey:(id)KeychainIdEmail];
    NSString * avatarURL = [kItems objectForKey:(id)KeychainIdAvatarURL];
    
    if ( [ruid length] > 0 )
    {
        Model *model = [Model sharedInstance];
        [model createLoginParticipantWithUserName:emailAddress andRegisteredId:nil];
        [model assignInfoToLoginParticipant:ruid andFirstName:firstName andLastName:lastName andParticipantId:emailAddress andAvatarURL:avatarURL];
        [[ViewController sharedInstance] enterOnDashboard];
    } else if (startOnRegister) {
        //        NSLog(@"startOnRegister");
    } else {
        //         NSLog(@"enterOnEntryScreen");
        [[ViewController sharedInstance] enterOnEntryScreen];
        [self hideLoadView];
    }
    self.startOnRegister = NO;
    self.loggingInFacebook = NO;
    [kItems release];
}

- (void)initViews
{
    //    NSLog(@"initViews");
    self.window = [[[UIWindow alloc] initWithFrame:
                    [[UIScreen mainScreen] bounds]] autorelease];
    
    UIViewController * rootViewController = [[UIViewController alloc] init];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [rootViewController release];
    navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    navigationController.navigationBar.tintColor = HEXCOLOR(0x000000FF);
    
    
    homeBackgroundView = [[UIView alloc] initWithFrame: window.frame];
    homeBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_home_01.png"]];
    [window insertSubview:homeBackgroundView atIndex:0];
    [homeBackgroundView release];
    
    eventBackgroundView = [[UIView alloc] initWithFrame: window.frame];
    eventBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_event_01.png"]];
    [window insertSubview:eventBackgroundView atIndex:1];
    [eventBackgroundView release];
    eventBackgroundView.alpha = 0;
    
    feedBackgroundView = [[UIView alloc] initWithFrame: window.frame];
    feedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_feed_01.png"]];
    [window insertSubview:feedBackgroundView atIndex:2];
    [feedBackgroundView release];
    feedBackgroundView.alpha = 0;
    
    // Add the navigation controller's view to the window and display.
    [window insertSubview:navigationController.view atIndex:3];
    [window makeKeyAndVisible];
    
    dropShadowScroll = [[UIView alloc] initWithFrame: CGRectMake(0, 64, 320, 5)];
    UIImageView *dsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropshadow_home_scroll.png"]];
    [dropShadowScroll addSubview:dsImage];
    [dsImage release];
    [window insertSubview:dropShadowScroll atIndex:4];
    [dropShadowScroll release];
    dropShadowScroll.alpha = 0;
    
    dropShadowScrollUp = [[UIView alloc] initWithFrame: CGRectMake(0, 431, 320, 5)];
    UIImageView *dsImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropshadow_home_scroll_up.png"]];
    [dropShadowScrollUp addSubview:dsImage2];
    [dsImage2 release];
    [window insertSubview:dropShadowScrollUp atIndex:5];
    [dropShadowScrollUp release];
    dropShadowScrollUp.alpha = 0;
    
    whiteView = [[UIView alloc] initWithFrame: window.frame];
    whiteView.backgroundColor = HEXCOLOR(0xFFFFFF66);
    whiteView.alpha = 0;
    [window insertSubview:whiteView atIndex:6];
    [whiteView release];
}

- (void)initSimpleGeoCategories
{
    [[Controller sharedInstance] getSimpleGeoCategories];
}

- (void)initAnalytics
{
    [[GANTracker sharedTracker] startTrackerWithAccountID:GOOGLE_ANALYTICS_PROPERTY_ID
                                           dispatchPeriod:GOOGLE_ANALYTICS_DISPATCH_PERIOD
                                                 delegate:nil];
}

- (void)showEventBackground
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         eventBackgroundView.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hideEventBackground
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         eventBackgroundView.alpha = 0;
                     }
                     completion:NULL];
}

- (void)showFeedBackground
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         feedBackgroundView.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hideFeedBackground
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         feedBackgroundView.alpha = 0;
                     }
                     completion:NULL];
}

- (void)showToolbarShadow
{
    dropShadowScrollUp.alpha = .25;
}

- (void)hideToolbarShadow
{
    dropShadowScrollUp.alpha = 0;
}

- (void)showDropShadow:(int)amount
{
    //    if (amount < 0) amount = 0;
    int absAmount = abs(amount);
    float a = absAmount / 5.0;
    if (a > 1) a = 1;
    dropShadowScroll.alpha = a/2;
}

- (void)hideLoadView
{
    [UIImageView animateWithDuration:0.50f 
                               delay:0.50f
                             options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction) 
                          animations:^(void){
                              loadView.alpha = 0;
                          }
                          completion:^(BOOL finished){
                              [loadView removeFromSuperview];
                              loadView = nil;
                          }];
}

- (void)showDeal
{
    dealView = [[TempDealPopup alloc] initWithFrame:window.frame];
    [window insertSubview:dealView atIndex:8];
    dealView.alpha = 0;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         dealView.alpha = 1;
                         whiteView.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hideDeal
{
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         dealView.alpha = 0;
                         whiteView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [dealView release];
                     }];
}

- (void)showFacebookPopup
{
    facebookPopup = [[LoginFacebookPopup alloc] initWithFrame:window.frame];
    [window insertSubview:facebookPopup atIndex:9];
    facebookPopup.alpha = 0;
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState) 
                     animations:^(void){
                         facebookPopup.alpha = 1;
                     }
                     completion:NULL];
}

- (void)hideFacebookPopupWithAnimation:(BOOL)animated
{
    if (facebookPopup && facebookPopup.superview == window) {
        if (animated) {
            [UIView animateWithDuration:0.30f 
                                  delay:0 
                                options:(UIViewAnimationOptionBeginFromCurrentState) 
                             animations:^(void){
                                 facebookPopup.alpha = 0;
                             }
                             completion:^(BOOL finished){
                                 [facebookPopup removeFromSuperview];
                                 [facebookPopup release];
                             }];
        } else {
            [facebookPopup removeFromSuperview];
            [facebookPopup release];
        }
    }
}


- (void)authenticateWithFacebook
{
    self.startOnRegister = YES;
    self.loggingInFacebook = NO;
    [facebook release];
    facebook = [[Facebook alloc] initWithAppId:@"221300981231092"];
    [facebook authorize:[NSArray arrayWithObjects:@"email,offline_access,publish_checkins", nil] delegate:self];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {  
    
    NSLog(@"didFinishLaunchingWithOptions");
    
    // fire up tracking
    [self initAnalytics];
    [self initDefaultPrefs];
    
    // we need to handle the app opened into the background from a terminated state
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        // app started back up in the background because of a significant location change
        [[ViewController sharedInstance] addAndReportViewWithName:@"/applicationlaunched_background_slc"];
        
        NSLog(@"AppStateBackground :: SLC, checking keychain");
        
        // Do the work associated with the task.
        NSDictionary *kItems = [[[KeychainManager sharedInstance] retreiveKeychainItems] copy];
        NSString * firstName = [kItems objectForKey:(id)KeychainIdFirstname];
        NSString * lastName = [kItems objectForKey:(id)KeychainIdLastName];
        NSString * ruid = [kItems objectForKey:(id)KeychainIdRUID];
        NSString * emailAddress = [kItems objectForKey:(id)KeychainIdEmail];
        NSString * avatarURL = [kItems objectForKey:(id)KeychainIdAvatarURL];
        [kItems release];
        
        [self startTimer];
        
        Model *model = [Model sharedInstance];
        
        if ( [ruid length] > 0 )
        {
            model.currentAppState = AppStateBackground;
            [model createLoginParticipantWithUserName:emailAddress andRegisteredId:nil];
            [model assignInfoToLoginParticipant:ruid andFirstName:firstName andLastName:lastName andParticipantId:emailAddress andAvatarURL:avatarURL];
            
            bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }];
            // Start the long-running task and return immediately.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //[[Controller sharedInstance] fetchEventsSynchronous];
                [[Controller sharedInstance] fetchEvents];
                
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            });
        }
        
        return YES;
    }
    
    NSLog(@"didFinishLaunchingWithOptions - standard launch");
    [[ViewController sharedInstance] addAndReportViewWithName:@"/applicationlaunched_standard"];
    [self startTimer];
    [self initCache];
    [self initViews];
    [self initStartView];
    [self registerDeviceForRemoteNotifications:application];
    [self initSimpleGeoCategories];
    
    loadView = [[LoadView alloc] initWithFrame:self.window.frame];
    [self.window addSubview:loadView];
    
    viewsHaveBeenInitialized = YES;
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    // if !viewsHaveBeenInitialized, app was woken from a terminated state by location change, must init views
    if (!viewsHaveBeenInitialized)
    {
        [self initCache];
        [self initViews];
        [self initStartView];
        [self registerDeviceForRemoteNotifications:application];
        
        loadView = [[LoadView alloc] initWithFrame:self.window.frame];
        [self.window addSubview:loadView];
        
        viewsHaveBeenInitialized = YES;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application { 
    application.applicationIconBadgeNumber = 0;
    NSLog(@"applicationDidBecomeActive");
    Model *model = [Model sharedInstance];
    if (!model.isInTrial) {
        if ([Model sharedInstance].currentAppState == AppStateDashboard || [Model sharedInstance].currentAppState == AppStateCreateEvent) {
            NSLog(@"applicationDidBecomeActive in AppStateDashboard: fetchEvents");
            [[Controller sharedInstance] fetchEvents];
        } else if ([Model sharedInstance].currentAppState == AppStateEventDetails) {
            NSLog(@"applicationDidBecomeActive in AppStateEventDetails: fetchEventWithId: %@", model.currentEvent.eventId);
            [[Controller sharedInstance] fetchEvents];
            [[Controller sharedInstance] fetchEventWithId:model.currentEvent.eventId andTimestamp:model.currentEvent.lastUpdatedTimestamp];
        }
        [[Controller sharedInstance] getRecentParticipants];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: %@", [userInfo description]);
    
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        
        Model *model = [Model sharedInstance];
        NSString *notificationType = [userInfo valueForKey:@"messageType"];
        
        if ([notificationType isEqualToString:@"feed"])
        {
            NSLog(@"notificationTypeFeed notification received");
            [[SoundManager sharedInstance] playSoundWithId:SoundManagerSoundIdFeedMessageReceived withVibration:YES];
            
        }
        else if ([notificationType isEqualToString:@"invite"])
        {
            NSLog(@"notificationTypeInvite notification received");
            [[SoundManager sharedInstance] playSoundWithId:SoundManagerSoundIdInvite withVibration:YES];
        }
        else if ([notificationType isEqualToString:@"upcoming"])
        {
            NSLog(@"notificationTypeUpcoming notification received");
        }
        else if ([notificationType isEqualToString:@"refresh"])
        {
            NSLog(@"notificationTypeRefresh notification received");
        }
        if ([Model sharedInstance].currentAppState == AppStateDashboard || [Model sharedInstance].currentAppState == AppStateCreateEvent) {
            NSLog(@"notification in AppStateDashboard: fetchEvents");
            [[Controller sharedInstance] fetchEvents];
        } else if ([Model sharedInstance].currentAppState == AppStateEventDetails) {
            NSLog(@"notification in AppStateEventDetails: fetchEventWithId: %@", model.currentEvent.eventId);
            [[Controller sharedInstance] fetchEvents];
            [[Controller sharedInstance] fetchEventWithId:model.currentEvent.eventId andTimestamp:model.currentEvent.lastUpdatedTimestamp];
        }
    }
}

#pragma mark -
#pragma mark Remote notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)aDeviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    NSLog(@"Did register for remote notifications: %@", [aDeviceToken description]);
    
    NSString * tokenAsString = [[[aDeviceToken description] 
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [Model sharedInstance].deviceToken = tokenAsString;
    
    if (self.deviceToken) [self.deviceToken release];
    self.deviceToken = tokenAsString;
    
    NSDictionary *kItems = [[[KeychainManager sharedInstance] retreiveKeychainItems] copy];
    NSString * ruid = [kItems objectForKey:(id)KeychainIdRUID];
    // Apparently device tokens can change. We'll update the device every time we receive a token IF user is registered
    if ( [ruid length] > 0 )
    {
        [[Controller sharedInstance] updateUserDeviceRecord];
    }
    [kItems release];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Fail to register for remote notifications: %@", error);
}

- (void)registerDeviceForRemoteNotifications:(UIApplication *)application
{
#if !TARGET_IPHONE_SIMULATOR
    [application registerForRemoteNotificationTypes: 
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
}

- (void)startTimer
{
    SynchMinuteTimer *tMinuteTimer = [[SynchMinuteTimer alloc] init];
    minuteTimer = [tMinuteTimer retain];
    [tMinuteTimer release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportTimerTick) name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    [minuteTimer startTimer];
    
    [LocationReporter sharedInstance]; // init singleton
}

- (void)reportTimerTick
{
    //    NSLog(@"Timer Tick!");
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMER_EVENT_MINUTE object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    NSLog(@"applicationWillTerminate");
}

#pragma mark -
#pragma mark FBSessionDelegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"application:handleOpenURL: startOnRegister = %@", (startOnRegister) ? @"YES" : @"NO");
    loadView = [[LoadView alloc] initWithFrame:self.window.frame];
    [self.window addSubview:loadView];
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin
{
    NSLog(@"FB fbDidLogin!! %@", facebook.accessToken);
    self.startOnRegister = NO;
    self.loggingInFacebook = YES;
    [self setUpDataFetcherMessageListeners];
    [[Controller sharedInstance] loginWithFacebookAccessToken:facebook.accessToken];
}

- (void)continueToDashboard
{
    [self removeDataFetcherMessageListeners];
	[[ViewController sharedInstance] navigateToDashboard];
    self.loggingInFacebook = NO;
    [self hideLoadView];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"FB fbDidNotLogin!!");
    self.startOnRegister = NO;
    [[ViewController sharedInstance] enterOnEntryScreen];
    [self hideLoadView];
}

- (void)fbDidLogout
{
    NSLog(@"FB fbDidLogout!!");
    self.startOnRegister = NO;
    [[ViewController sharedInstance] enterOnEntryScreen];
    [self hideLoadView];
}

#pragma mark -
#pragma mark FBRequestDelegate

- (void)requestLoading:(FBRequest *)request
{
    NSLog(@"FB requestLoading!! %@", request);
    for (NSString *key in request.params) {
        NSLog(@"key = %@; value = %@", key, [request.params objectForKey:key]);
    }
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"FB didReceiveResponse!! %@", response);
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"FB Pass!! %@", request);
    for (NSString *key in request.params) {
        NSLog(@"key = %@; value = %@", key, [request.params objectForKey:key]);
    }
    NSLog(@"FB Result!! %@", result);
    //    [[ViewController sharedInstance] enterOnRegister:result];
    [self hideLoadView];
    self.startOnRegister = NO;
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"FB Fail!! %@", request);
    for (NSString *key in request.params) {
        NSLog(@"key = %@; value = %@", key, [request.params objectForKey:key]);
    }
    NSLog(@"FB Error %@", error);
    [[ViewController sharedInstance] enterOnEntryScreen];
    [self hideLoadView];
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
    Model *model = [Model sharedInstance];
    switch (fetchType) {
        case DataFetchTypeLoginWithFacebookAccessToken:
            if (model.isInTrial) model.loginAfterTrial = YES;
            model.isInTrial = NO;
            if (model.currentViewState == ViewStatePrefs) {
                [[Controller sharedInstance] getRecentParticipants];
                [model flushTempItems];
                [[ViewController sharedInstance] goBack];
            } else if (model.currentViewState == ViewStateDetails) {
                [[Controller sharedInstance] getRecentParticipants];
                [model flushTempItems];
                [self hideLoadView];
            } else if (model.currentViewState == ViewStateCreate) {
                [[Controller sharedInstance] getRecentParticipants];
                [self hideLoadView];
            } else if (model.currentViewState != ViewStateDashboard) {
                [[Controller sharedInstance] getRecentParticipants];
                [self continueToDashboard];
            }
            
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
        case DataFetchTypeLoginWithFacebookAccessToken:
//            NSLog(@"Unhandled Error: %d", DataFetchTypeLoginWithFacebookAccessToken);
            [self showLoginError];
            break;
        default:
            break;
    }
}

- (void)showLoginError
{
    NSString *alertMessage = @"Something went wrong during login. Please try again.";
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loginAlert show];
    [loginAlert release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
        NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=%@&mt=8", [userPreferences objectForKey:APP_STORE_ID]];
        if (nil != iTunesLink) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    NSLog(@"BigBabyAppDelegate dealloc");
    [lastDisplayedVersionAlertDate release];
    [lastDisplayedVersionAlert release];
    [minuteTimer stopTimer];
    [minuteTimer release];
    [self.deviceToken release];
    [self.facebook release];
	[navigationController release];
	[window release];
	[super dealloc];
}


@end