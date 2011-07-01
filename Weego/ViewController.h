//
//  ViewController.h
//  BigBaby
//
//  Created by Nicholas Velloff on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeegoAppDelegate.h"
#import "AddLocation.h"

@interface ViewController : NSObject {
    WeegoAppDelegate *appDelegate;
    UINavigationController *nController;
    NSMutableArray *navigationIndexingCollection;
}

@property (nonatomic, readonly) UINavigationController *currentNavController;

+ (ViewController *)sharedInstance;
+ (void)destroy;

- (void)enterOnEntryScreen;
- (void)enterOnDashboard;
//- (void)enterOnRegister:(NSDictionary *)facebook;
- (void)showPrefsView: (UIViewController *)inView;
- (void)logoutUser: (UIViewController *)inView;
- (void)navigateToDashboard;
//- (void)showLogin:(UIViewController *)inView;
//- (void)showRegistration:(UIViewController *)inView;
- (void)showMailModalViewControllerInView:(UIViewController *)inView withTitle:(NSString *)title andSubject:(NSString *)subject andMessageBody:(NSString *)body andToRecipients:(NSArray *)receipients;
- (void)navigateToEventDetailWithId:(NSString *)eventId; // andPushOnStack:(BOOL)toPush;
- (void)showModalFeed:(UIViewController *)inView;
- (void)showModalCreateEvent:(UIViewController *)inView;
- (void)navigateToAddLocationsWithEntryState:(AddLocationInitState)state;
- (void)navigateToAddLocationsWithLocationOpen:(NSString *)locId;
- (void)navigateToAddParticipants;
//- (void)showModalEditEvent:(UIViewController *)inView;
- (void)navigateToEditEvent;
- (void)goBack;
- (void)dismissModal:(UIViewController *)modalView;
- (void)showHomeBackground;
- (void)showEventBackground;
- (void)showFeedBackground;
- (void)showDropShadow:(int)amount;
- (void)showDeal;
- (void)hideDeal;
- (void)showFacebookPopup;
- (void)hideFacebookPopupWithAnimation:(BOOL)animated;
- (void)authenticateWithFacebook;
- (void)hideLoadView;
- (void)navigateToInfo;
- (void)navigateToHelp;

- (void)addAndReportViewWithName:(NSString *)name;
- (void)removeCurrentAndReportPreviousView;

@end
