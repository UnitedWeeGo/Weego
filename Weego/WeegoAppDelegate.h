//
//  WeegoAppDelegate.h
//  Weego
//
//  Created by Nicholas Velloff on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadView.h"
#import "SynchMinuteTimer.h"
#import "TempDealPopup.h"
#import "FBConnect.h"
#import "LocationReporter.h"
#import "LoginFacebookPopup.h"

@class DataFetcher;

@interface WeegoAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate, DataFetcherMessageHandler, UIAlertViewDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    
    UIView *homeBackgroundView;
    UIView *eventBackgroundView;
    UIView *feedBackgroundView;
    UIView *dropShadowScroll;
    UIView *dropShadowScrollUp;
    UIView *whiteView;
    TempDealPopup *dealView;
    LoginFacebookPopup *facebookPopup;
    
    LoadView *loadView;
    SynchMinuteTimer *minuteTimer;
    
    Facebook *facebook;
    BOOL startOnRegister;
    BOOL loggingInFacebook;
    
    UIBackgroundTaskIdentifier bgTask;
    
    BOOL viewsHaveBeenInitialized;
    
    NSString *lastDisplayedVersionAlert;
    NSDate *lastDisplayedVersionAlertDate;
    NSDate *nextDataFetchAttempt;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) UINavigationController *navigationController;
@property (nonatomic, retain) NSString *deviceToken; // stored here locally so it survives the model wipe
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, assign) BOOL startOnRegister;
@property (nonatomic, assign) BOOL loggingInFacebook;

- (void)showEventBackground;
- (void)hideEventBackground;
- (void)showFeedBackground;
- (void)hideFeedBackground;
- (void)showDropShadow:(int)amount;
- (void)showToolbarShadow;
- (void)hideToolbarShadow;
- (void)showDeal;
- (void)hideDeal;
- (void)showFacebookPopup;
- (void)hideFacebookPopupWithAnimation:(BOOL)animated;
- (void)hideLoadView;
- (void)authenticateWithFacebook;
- (void)hideLoadView;
- (void)checkForUpdateWithServerReportedVerion;

@end
