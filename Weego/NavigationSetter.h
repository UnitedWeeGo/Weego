//
//  NavigationSetter.h
//  BigBaby
//
//  Created by Nicholas Velloff on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeegoAppDelegate.h"

typedef enum {
	NavStateLocationAddSearchOn = 0,
    NavStateLocationAddSearchOff,
    NavStateLocationAddSearchOnTab,
    NavStateLocationAddSearchOffTab,
	NavStateLocationView,
    NavStateLocationDecided,
    NavStateLocationNameEdit,
    NavStateEventDetails,
    NavStateEventDetailsPending,
    NavStateEventDetailsEnded,
    NavStateEventCreateEvent,
    NavStateEventDuplicateEvent,
    NavStateEventEdit,
    NavStatePrefs,
    NavStateDashboard,
    NavStateDashboardNoEvents,
    NavStateAddParticipant,
    NavStateAddressBook,
    NavStateLogin,
    NavStateRegister,
    NavStateFeed,
    NavStateEntry,
    NavStateInfo,
    NavStateHelp,
    NavStateTerms,
    NavStatePrivacy,
    NavStateDeals,
    NavStateDealsWithTimeAvailability,
    NavStateReviews
} NavState;

typedef enum {
	ToolbarStateOff = 0,
    ToolbarStateDetails,
    ToolbarStateFeed,
    ToolbarStateSearchAgain
} ToolbarState;

@interface NavigationSetter : NSObject {
    WeegoAppDelegate *appDelegate;
    UINavigationController *nController;
    UIButton *searchBtn; // pointer held to replace image in case of decided+ state
    UIButton *countMeInBtn;
    NavState currentState;
//    UIToolbar* toolbar;
}

+ (NavigationSetter *)sharedInstance;
+ (void)destroy;

- (void)setNavState:(NavState)state withTarget:(id)target;
- (void)setToolbarState:(ToolbarState)state withTarget:(id)target;
- (void)setToolbarState:(ToolbarState)state withTarget:(id)target withFeedCount:(int)feedCount;
@end
