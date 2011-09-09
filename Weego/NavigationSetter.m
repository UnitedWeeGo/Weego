//
//  NavigationSetter.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NavigationSetter.h"
#import "UINavigationBar+CustomBackground.h"
#import "ImageUtil.h"

@interface NavigationSetter (Private)

- (void)addCenterSegmentedControlWithSearch:(id)target searchOn:(Boolean)searchOn;
- (void)addCenterSegmentedControlWithDecidedIcon:(id)target;
- (void)removeRightAndLeftButtons:(id)target;
- (void)addPrefsButton:(id)target;
- (void)addMoreButton:(id)target;
- (void)resetNavViews:(id)target;
- (void)setNav:(id)target withTitle:(NSString *)title withColor:(int)color andShadowColor:(int)shadowColorHex;
- (void)addPlusButton:(id)target withGreenBackground:(BOOL)greenBg;
- (void)addHeaderLogo:(id)target withAnimation:(BOOL)animated;
- (void)addBackHomeButton:(id)target useWhiteIcon:(BOOL)useWhite;
- (void)addHomeButton:(id)target useWhiteIcon:(BOOL)useWhite;
- (void)animateInView:(UIView *)view;
- (void)addBottomFeedButtonWithTarget:(id)target andFeedCount:(int)feedCount;
- (void)addBottomSearchAgainButtonWithTarget:(id)target;
- (void)addGreenActionButtonWithLabel:(NSString *)label andTarget:(id)target toLeft:(BOOL)left overrideClear:(BOOL)clear overrideLight:(BOOL)light withTextColor:(int)textColor;
- (void)addBackButton:(id)target onLightBackground:(BOOL)onLightBackground;
- (void)addHeaderFeedTitleWithTarget:(id)target;
- (void)addHeaderCountMeInTitleWithTarget:(id)target;
- (void)addSelectTimeButton:(id)target;

@end

@implementation NavigationSetter


static NavigationSetter *sharedInstance;

+ (NavigationSetter *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[NavigationSetter alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton NavigationSetter.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = (WeegoAppDelegate *)[[UIApplication sharedApplication] delegate];
        nController = [ViewController sharedInstance].currentNavController;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"NavigationSetter dealloc");
    appDelegate = nil;
    nController = nil;
    [super dealloc];
}

- (void)setToolbarState:(ToolbarState)state withTarget:(id)target withFeedCount:(int)feedCount
{
    UIViewController *vc = target;
    switch (state) {
         case ToolbarStateOff:
            [vc.navigationController setToolbarHidden:YES animated:YES];
            break;
        case ToolbarStateDetails:
            [self addBottomFeedButtonWithTarget:target andFeedCount:feedCount];
            break;
        case ToolbarStateFeed:
            // later to add the gallery/feed toggle
            break;
        default:
            break;
    }
}

- (void)setToolbarState:(ToolbarState)state withTarget:(id)target
{
    UIViewController *vc = target;
    switch (state) {
        case ToolbarStateOff:
            [vc.navigationController setToolbarHidden:YES animated:YES];
            break;
        case ToolbarStateSearchAgain:
            [self addBottomSearchAgainButtonWithTarget:target]; 
            break;
        default:
            break;
    }
}

- (void)setNavState:(NavState)state withTarget:(id)target
{
    [self resetNavViews:target];
    switch (state) {
        case NavStateLocationAddSearchOn:
            [self addCenterSegmentedControlWithSearch:target searchOn:true];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationAddSearchOff:
            [self addCenterSegmentedControlWithSearch:target searchOn:false];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationAddSearchOnTab:
            [self addCenterSegmentedControlWithSearch:target searchOn:true];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationAddSearchOffTab:
            [self addCenterSegmentedControlWithSearch:target searchOn:false];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationDecided:
            [self addCenterSegmentedControlWithDecidedIcon:target];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationView:
            [self addCenterSegmentedControlWithSearch:target searchOn:false];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLocationNameEdit:
            [self setNav:target withTitle:@"Edit Location Name" withColor:0x777777FF andShadowColor:0x00000000];
            [self addGreenActionButtonWithLabel:@"Cancel" andTarget:target toLeft:YES overrideClear:NO overrideLight:YES withTextColor:0x525252FF]; //0xFFFFFFFF
            [self addGreenActionButtonWithLabel:@"Done" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            break;
        case NavStateEventDetails:
            [self setNav:target withTitle:@"Event Details" withColor:0x777777FF andShadowColor:0x00000000];
            [self addHomeButton:target useWhiteIcon:NO];
            [self addMoreButton:target];
            break;
        case NavStateEventDetailsPending:
            [self addHeaderCountMeInTitleWithTarget:target];
            [self addHomeButton:target useWhiteIcon:NO];
            [self addMoreButton:target];
            break;
        case NavStateEventDetailsEnded:
            [self setNav:target withTitle:@"Event Details" withColor:0x777777FF andShadowColor:0x00000000];
            [self addHomeButton:target useWhiteIcon:NO];
            [self addMoreButton:target];
            break;
        case NavStateEventCreateEvent:
            [self setNav:target withTitle:@"Create Event" withColor:0x777777FF andShadowColor:0x00000000];
            [self addGreenActionButtonWithLabel:@"Cancel" andTarget:target toLeft:YES overrideClear:NO overrideLight:YES withTextColor:0x525252FF]; //0xFFFFFFFF
            [self addGreenActionButtonWithLabel:@"Done" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            break;
        case NavStateEventDuplicateEvent:
            [self setNav:target withTitle:@"Duplicate Event" withColor:0x777777FF andShadowColor:0x00000000];
            [self addGreenActionButtonWithLabel:@"Cancel" andTarget:target toLeft:YES overrideClear:NO overrideLight:YES withTextColor:0x525252FF]; //0xFFFFFFFF
            [self addGreenActionButtonWithLabel:@"Done" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            break;
        case NavStateEventEdit:
            [self setNav:target withTitle:@"Edit What & When" withColor:0x777777FF andShadowColor:0x00000000];
//            [self addGreenActionButtonWithLabel:@"Cancel" andTarget:target toLeft:YES overrideClear:NO overrideLight:YES withTextColor:0x525252FF]; //0xFFFFFFFF
            [self addGreenActionButtonWithLabel:@"Done" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStatePrefs:
            [self setNav:target withTitle:@"Settings" withColor:0xFFFFFFFF andShadowColor:0x333333FF];
            [self addBackHomeButton:target useWhiteIcon:YES];
            break;
        case NavStateDashboard:
            [self addHeaderLogo:target withAnimation:(currentState != state)];
            [self addPrefsButton:target];
            [self addPlusButton:target withGreenBackground:NO];
            break;
        case NavStateDashboardNoEvents:
            [self addHeaderLogo:target withAnimation:NO];
            [self addPrefsButton:target];
            [self addPlusButton:target withGreenBackground:YES];
            break;
        case NavStateAddParticipant:
            [self setNav:target withTitle:@"Add Friends" withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];            
            [self addGreenActionButtonWithLabel:@"Done" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            break;
        case NavStateAddressBook:
            [self setNav:target withTitle:@"Address Book" withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateLogin:
            [self addHeaderLogo:target withAnimation:YES];
            [self addBackButton:target onLightBackground:false];            
            [self addGreenActionButtonWithLabel:@"Login" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            break;
        case NavStateRegister:
            [self addHeaderLogo:target withAnimation:YES];
            [self addBackButton:target onLightBackground:true];
            [self setNav:target withTitle:@"Login/Sign-Up" withColor:0x777777FF andShadowColor:0x00000000];
//            [self addGreenActionButtonWithLabel:@"Sign Up" andTarget:target toLeft:NO overrideClear:NO overrideLight:NO withTextColor:0xFFFFFFFF];
            
            break;
        case NavStateFeed:
            [self addGreenActionButtonWithLabel:@"Close" andTarget:target toLeft:NO overrideClear:YES overrideLight:NO withTextColor:0xFFFFFFFF];
            [self addHeaderFeedTitleWithTarget:target];
            break;
        case NavStateEntry:
            // nothing, empty
        case NavStateInfo:
            [self setNav:target withTitle:@"About"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateHelp:
            [self setNav:target withTitle:@"Help"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateTerms:
            [self setNav:target withTitle:@"Terms"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStatePrivacy:
            [self setNav:target withTitle:@"Privacy Policy"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateDeals:
            [self setNav:target withTitle:@"Deal"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            break;
        case NavStateDealsWithTimeAvailability:
            [self setNav:target withTitle:@"Deal"  withColor:0x777777FF andShadowColor:0x00000000];
            [self addBackButton:target onLightBackground:true];
            [self addSelectTimeButton:target];
            break;
        default:
            break;
    }
    currentState = state;
}

- (void)resetNavViews:(id)target
{
    UIViewController *vc = target;
    vc.navigationItem.leftBarButtonItem = nil;
    vc.navigationItem.rightBarButtonItem = nil;
    vc.navigationItem.title = nil;
    vc.navigationItem.titleView = nil;
}

- (void)addHeaderCountMeInTitleWithTarget:(id)target
{
    UIViewController *vc = target;
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    
    UIImage *bg1 = [UIImage imageNamed:@"button_green_lrg_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_green_lrg_pressed.png"];
    UIImage *bg3 = [UIImage imageNamed:@"button_green_lrg_disabled.png"];
    
    UIView *countMeInBtnView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, bg1.size.width, bg1.size.height)] autorelease];
    
    countMeInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    countMeInBtn.frame = CGRectMake(0, -1, bg1.size.width, bg1.size.height);
    countMeInBtn.enabled = YES;
    
    [countMeInBtn setBackgroundImage:bg1 forState:UIControlStateNormal];
    [countMeInBtn setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [countMeInBtn setBackgroundImage:bg3 forState:UIControlStateDisabled];
    
    [countMeInBtn setTitle:@"Count Me In..." forState:UIControlStateNormal];
    countMeInBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [countMeInBtn setTitleColor:col forState:UIControlStateNormal];
    [countMeInBtn addTarget:vc action:@selector(handleCountMeInPress:) forControlEvents:UIControlEventTouchUpInside];
    [countMeInBtn addTarget:self action:@selector(handleCountMeInPress:) forControlEvents:UIControlEventTouchUpInside];
    countMeInBtn.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    countMeInBtn.titleLabel.lineBreakMode = UILineBreakModeClip;
    UIColor *shadowColor = HEXCOLOR(0x00000000);
    countMeInBtn.titleLabel.shadowColor = shadowColor;
    countMeInBtn.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [countMeInBtnView addSubview:countMeInBtn];
    
    vc.navigationItem.titleView = countMeInBtnView;
}

- (void)handleCountMeInPress:(id)sender
{
    countMeInBtn.enabled = NO;
}

- (void)addHeaderFeedTitleWithTarget:(id)target
{
    UIViewController *vc = target;
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    
    UIImage *feedImageDefault = [UIImage imageNamed:@"topbar_feed_default.png"];
    
    UIView *feedBtnView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, feedImageDefault.size.width, feedImageDefault.size.height)] autorelease];
    
    UIButton *feedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    feedBtn.frame = CGRectMake(0, 0, feedImageDefault.size.width, feedImageDefault.size.height);
    feedBtn.enabled = YES;
    [feedBtn setTitle:@"Messages" forState:UIControlStateNormal];
    [feedBtn setTitleColor:col forState:UIControlStateNormal];
    feedBtn.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
    feedBtn.titleLabel.lineBreakMode = UILineBreakModeClip;
    feedBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 13, 0, 0);
    UIColor *shadowColor = HEXCOLOR(0x00000000);
    feedBtn.titleLabel.shadowColor = shadowColor;
    feedBtn.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    UIImage *feedIcon = [UIImage imageNamed:@"icon_feed.png"];
    UIImageView *feedIconView = [[[UIImageView alloc] initWithImage:feedIcon] autorelease];
    feedIconView.frame = CGRectMake(108, 13, feedIcon.size.width, feedIcon.size.height);
    
    [feedBtnView addSubview:feedBtn];
    [feedBtnView addSubview:feedIconView];
    
    vc.navigationItem.titleView = feedBtnView;
}

//    NSArray *familyNames = [UIFont familyNames];
//    NSArray *fontNamesForFamilyName = [UIFont fontNamesForFamilyName:@"some font in the names array"];

- (void)addBottomSearchAgainButtonWithTarget:(id)target
{
    UIViewController *vc = target;
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    
    UIImage *searchAgainDefault = [UIImage imageNamed:@"button_redosearch_default.png"];
    UIImage *searchAgainPressed = [UIImage imageNamed:@"button_redosearch_pressed.png"];
    UIView *searchAgainBtnView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, searchAgainDefault.size.width, searchAgainDefault.size.height+1)] autorelease];
    
    UIButton *searchAgainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchAgainBtn.adjustsImageWhenHighlighted = NO;
    searchAgainBtn.frame = CGRectMake(0, 0, searchAgainDefault.size.width, searchAgainDefault.size.height+1);
    searchAgainBtn.enabled = YES;
    [searchAgainBtn setBackgroundImage:searchAgainDefault forState:UIControlStateNormal];
    [searchAgainBtn setBackgroundImage:searchAgainPressed forState:UIControlStateHighlighted];
    
    [searchAgainBtn setTitle:@"Redo Search In This Area" forState:UIControlStateNormal];
    [searchAgainBtn setTitleColor:col forState:UIControlStateNormal];
    searchAgainBtn.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    searchAgainBtn.titleLabel.lineBreakMode = UILineBreakModeClip;
    searchAgainBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 13, 0, 10);
    UIColor *shadowColor = HEXCOLOR(0x00000000);
    searchAgainBtn.titleLabel.shadowColor = shadowColor;
    searchAgainBtn.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [searchAgainBtn addTarget:vc action:@selector(handleSearchAgainPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *searchAgainIcon = [UIImage imageNamed:@"icon_redo_01.png"];
    UIImageView *searchAgainIconView = [[[UIImageView alloc] initWithImage:searchAgainIcon] autorelease];
    searchAgainIconView.frame = CGRectMake(62, 10, searchAgainIcon.size.width, searchAgainIcon.size.height);
    
    [searchAgainBtnView addSubview:searchAgainBtn];
    [searchAgainBtnView addSubview:searchAgainIconView];
    
    UIBarButtonItem *searchAgainBtnBB = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:vc action:@selector(handleSearchAgainPress:)] autorelease];
    
    searchAgainBtnBB.customView = searchAgainBtnView;
    
    //Buttons you created before will be inserted to an array. The toolbar will read the array for buttons
    NSArray *items = [NSArray arrayWithObjects: searchAgainBtnBB, nil];
    
    //If you hate the default view of UIToolbar, you can change its 'skin' by using image
    UIImage *bottombar_background = [UIImage imageNamed:@"bottombar_background_clear.png"];
    [vc.navigationController.toolbar insertSubview:[[[UIImageView alloc] initWithImage:bottombar_background] autorelease] atIndex:0];
    
    [vc.navigationController setToolbarHidden:NO animated:NO];
    vc.toolbarItems = items;
    
}

- (void)addBottomFeedButtonWithTarget:(id)target andFeedCount:(int)feedCount
{
    UIViewController *vc = target;
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    
    UIImage *feedImageDefault = [UIImage imageNamed:feedCount>0 ? @"topbar_feed_green.png" : @"topbar_feed_default.png"];
//    UIImage *feedImagePressed = [UIImage imageNamed:feedCount>0 ? @"topbar_feed_green.png" : @"topbar_feed_default.png"];
    
    UIView *feedBtnView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, feedImageDefault.size.width, feedImageDefault.size.height)] autorelease];
    
    UIButton *feedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    feedBtn.adjustsImageWhenHighlighted = NO;
    feedBtn.frame = CGRectMake(0, 0, feedImageDefault.size.width, feedImageDefault.size.height);
    feedBtn.enabled = YES;
    [feedBtn setBackgroundImage:feedImageDefault forState:UIControlStateNormal];
//    [feedBtn setBackgroundImage:feedImagePressed forState:UIControlStateHighlighted];
    [feedBtn setTitle:@"Messages" forState:UIControlStateNormal];
    [feedBtn setTitleColor:col forState:UIControlStateNormal];
    feedBtn.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
    feedBtn.titleLabel.lineBreakMode = UILineBreakModeClip;
    feedBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 23, 0, 0);
    UIColor *shadowColor = HEXCOLOR(0x00000000);
    feedBtn.titleLabel.shadowColor = shadowColor;
    feedBtn.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [feedBtn addTarget:vc action:@selector(handleFeedPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *feedIcon = [UIImage imageNamed:@"icon_feed.png"];
    UIImageView *feedIconView = [[[UIImageView alloc] initWithImage:feedIcon] autorelease];
    feedIconView.frame = CGRectMake(113, 13, feedIcon.size.width, feedIcon.size.height);
    
   
    
    [feedBtnView addSubview:feedBtn];
    [feedBtnView addSubview:feedIconView];
    
    if (feedCount>0) {
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
        [label setBackgroundColor:[UIColor clearColor]];
        UIColor *col2 = HEXCOLOR(0x000000FF);
        [label setTextColor:col2];
        NSString *countCopy = [NSString stringWithFormat:@"%d", feedCount];
        [label setText:countCopy];
        [label sizeToFit];
        
        CGRect frame = label.bounds;
        frame.origin.x = 113;
        frame.origin.y = 15;
        frame.size.width = 20;
        label.frame = frame;
        [feedBtnView addSubview:label];
    }
    
    UIBarButtonItem *feedBtnBB = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:vc action:@selector(handleFeedPress:)] autorelease];
    
    feedBtnBB.customView = feedBtnView;
    
    //Buttons you created before will be inserted to an array. The toolbar will read the array for buttons
    NSArray *items = [NSArray arrayWithObjects: feedBtnBB, nil];
    
    //If you hate the default view of UIToolbar, you can change its 'skin' by using image
    UIImage *bottombar_background = [UIImage imageNamed:@"bottombar_background.png"];
    [vc.navigationController.toolbar insertSubview:[[[UIImageView alloc] initWithImage:bottombar_background] autorelease] atIndex:0];
    
    [vc.navigationController setToolbarHidden:NO animated:NO];
    vc.toolbarItems = items;
}

- (void)setNav:(id)target withTitle:(NSString *)title withColor:(int)color andShadowColor:(int)shadowColorHex
{
    UIViewController *vc = target;
    UILabel *label = [[[UILabel alloc] init] autorelease];
	label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18];
	[label setBackgroundColor:[UIColor clearColor]];
    UIColor *col = HEXCOLOR(color);
	[label setTextColor:col];
	[label setText:title];
	[label sizeToFit];
    
    UIColor *shadowColor = HEXCOLOR(shadowColorHex);
    label.shadowColor = shadowColor;
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    
    CGRect frame = label.bounds;
    frame.origin.y = 2;
    label.frame = frame;
    
    UIView *titleView = [[[UIView alloc] initWithFrame:label.bounds] autorelease];
    titleView.alpha = 0;
    [titleView addSubview:label];
    
    vc.navigationItem.titleView = titleView;
    
    [self animateInView:titleView];
}

- (void)addHeaderLogo:(id)target withAnimation:(BOOL)animated
{
    UIViewController *vc = target;
    UIImage *logo = [UIImage imageNamed:@"topbar_logotype.png"];
    UIImageView *logoView = [[[UIImageView alloc] initWithImage:logo] autorelease];
    vc.navigationItem.titleView = logoView;
    if (animated) {
        logoView.alpha = 0;
        [self animateInView:logoView];
    }
}

- (void)addPlusButton:(id)target withGreenBackground:(BOOL)greenBg
{
    UIViewController *vc = target;
    
    UIImage *bg1;
    UIImage *bg2;
    
    if (greenBg) {
        bg1 = [UIImage imageNamed:@"button_green_sm_default.png"];
        bg2 = [UIImage imageNamed:@"button_green_sm_pressed.png"];
    } else {
        bg1 = [UIImage imageNamed:@"button_clear_sm_default.png"];
        bg2 = [UIImage imageNamed:@"button_clear_sm_pressed.png"];
    }
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handlePlusPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:[UIImage imageNamed:@"icon_plus_01.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.rightBarButtonItem = btn;
}

- (void)addHomeButton:(id)target useWhiteIcon:(BOOL)useWhite
{
    UIViewController *vc = target;
    // change to button_back_clear_pressed.png, icon_home_white.png
    UIImage *bg1 = [UIImage imageNamed:@"button_back_light_sm_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_back_light_sm_pressed.png"];
    
    UIImage *icon = [UIImage imageNamed:(useWhite)?(@"icon_home_white.png"):(@"icon_home_01.png")];
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handleHomePress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.leftBarButtonItem = btn;
}

- (void)addBackHomeButton:(id)target useWhiteIcon:(BOOL)useWhite
{
    
    UIViewController *vc = target;
    // change to button_back_clear_pressed.png, icon_home_white.png
    UIImage *bg1 = [UIImage imageNamed:@"button_back_clear_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_back_clear_pressed.png"];
    
    UIImage *icon = [UIImage imageNamed:(useWhite)?(@"icon_home_white.png"):(@"icon_home_01.png")];
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.imageEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handleHomePress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.leftBarButtonItem = btn;
}

- (void)addPrefsButton:(id)target
{
    UIViewController *vc = target;
    
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_sm_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_sm_pressed.png"];
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handlePrefsPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:[UIImage imageNamed:@"icon_settings_01.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.leftBarButtonItem = btn;
}

- (void)addMoreButton:(id)target
{
    UIViewController *vc = target;
    
    UIImage *bg1 = [UIImage imageNamed:@"button_light_sm_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_light_sm_pressed.png"];
    
    CGRect buttonTargetSize = CGRectMake(0, -1, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handleMorePress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:[UIImage imageNamed:@"icon_more_01.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.rightBarButtonItem = btn;
}

- (void)disableButton:(id)target
{
    UIButton *cView = target;
    cView.enabled = NO;
}


- (void)addGreenActionButtonWithLabel:(NSString *)label andTarget:(id)target toLeft:(BOOL)left overrideClear:(BOOL)clear overrideLight:(BOOL)light withTextColor:(int)textColor
{
    UIViewController *vc = target;
    
    UIImage *bg1;
    UIImage *bg2;
    
    if (clear) {
        bg1 = [UIImage imageNamed:@"button_clear_default.png"];
        bg2 = [UIImage imageNamed:@"button_clear_pressed.png"];
    } else if (light) {
        bg1 = [UIImage imageNamed:@"button_light_default.png"];
        bg2 = [UIImage imageNamed:@"button_light_pressed.png"];
    } else {
        bg1 = [UIImage imageNamed:@"button_green_default.png"];
        bg2 = [UIImage imageNamed:@"button_green_pressed.png"];
    }
    
    CGRect buttonTargetSize = CGRectMake(0, 0, 60, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    
    SEL selector = nil;
    selector = left ? @selector(handleLeftActionPress:) : @selector(handleRightActionPress:);
    
    [cView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setBackgroundImage:bg2 forState:UIControlStateDisabled];
    [cView setTitle:label forState:UIControlStateNormal];
    UIColor *col = HEXCOLOR(textColor);    
    [cView setTitleColor:col forState:UIControlStateNormal];
    
    cView.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    cView.titleLabel.lineBreakMode = UILineBreakModeClip;
    
    if (!light)
    {
        UIColor *shadowColor = HEXCOLOR(0x33333333);
        cView.titleLabel.shadowColor = shadowColor;
        cView.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    
    cView.contentEdgeInsets = UIEdgeInsetsMake(4, 2, 0, 0);
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    
    if (left) {
        vc.navigationItem.leftBarButtonItem = btn;
    } else {
        vc.navigationItem.rightBarButtonItem = btn;
    }
}

- (void)addBackButton:(id)target onLightBackground:(BOOL)onLightBackground
{
    UIViewController *vc = target;
    
    UIImage *bg1 = [UIImage imageNamed:onLightBackground ? @"button_back_light_sm_default.png" : @"button_back_clear_default.png"];
    UIImage *bg2 = [UIImage imageNamed:onLightBackground ? @"button_back_light_sm_pressed.png" : @"button_back_clear_pressed.png"];
    
    UIImage *icon = [UIImage imageNamed:(onLightBackground)?(@"icon_backArrow_dark_01.png"):(@"icon_backArrow_light_01.png")];
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handleBackPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.leftBarButtonItem = btn;
}

- (void)addSelectTimeButton:(id)target
{
    UIViewController *vc = target;
    
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_sm_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_sm_pressed.png"];
    
    UIImage *icon = [UIImage imageNamed:@"icon_time_01.png"];
    
    CGRect buttonTargetSize = CGRectMake(0, 0, bg1.size.width, bg1.size.height); // set the desired width here, if it is different than the default button size
    
    UIButton *cView = [UIButton buttonWithType:UIButtonTypeCustom];
    cView.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
    cView.adjustsImageWhenHighlighted = NO;
    [cView setFrame:buttonTargetSize];
    [cView addTarget:target action:@selector(handleSelectTimePress:) forControlEvents:UIControlEventTouchUpInside];
    
    [cView setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cView setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cView setImage:icon forState:UIControlStateNormal];
    
    UIBarButtonItem *btn = [[[UIBarButtonItem alloc] initWithCustomView:cView] autorelease];
    vc.navigationItem.rightBarButtonItem = btn;
}


/*
 imageEdgeInsets
 The inset or outset margins for the edges of the button image drawing rectangle.
 Discussion
 Use this property to resize and reposition the effective drawing rectangle for the button image. You can specify a different value for each of the four insets (top, left, bottom, right). A positive value shrinks, or insets, that edge—moving it closer to the center of the button. A negative value expands, or outsets, that edge. Use the UIEdgeInsetsMake function to construct a value for this property. The default value is UIEdgeInsetsZero.
 
 contentEdgeInsets
 The inset or outset margins for the edges of the button content drawing rectangle.
 Discussion
 Use this property to resize and reposition the effective drawing rectangle for the button content. The content comprises the button image and button title. You can specify a different value for each of the four insets (top, left, bottom, right). A positive value shrinks, or insets, that edge—moving it closer to the center of the button. A negative value expands, or outsets, that edge. Use the UIEdgeInsetsMake function to construct a value for this property. The default value is UIEdgeInsetsZero.
 
*/
- (void)removeRightAndLeftButtons:(id)target
{
    UIViewController *vc = target;
    vc.navigationItem.rightBarButtonItem = nil;
    vc.navigationItem.leftBarButtonItem = nil;
}

- (void)addCenterSegmentedControlWithDecidedIcon:(id)target
{
    [self addCenterSegmentedControlWithSearch:target searchOn:false];
    [searchBtn setImage:[UIImage imageNamed:@"icon_star_default.png"] forState:UIControlStateNormal];
    [searchBtn removeTarget:target action:@selector(handleSearchPress:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn addTarget:target action:@selector(handleDecidedPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addCenterSegmentedControlWithSearch:(id)target searchOn:(Boolean)searchOn
{
    UIViewController *vc = target;
    
    UIImage *prevImageDefault = [UIImage imageNamed:@"button_topcluster_left_default.png"];
    UIImage *prevImagePressed = [UIImage imageNamed:@"button_topcluster_left_pressed.png"];
    UIImage *prevImageIcon = [UIImage imageNamed:@"icon_arrow_left_01.png"];
    
    UIButton *prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    prevBtn.adjustsImageWhenHighlighted = NO;
    prevBtn.frame = CGRectMake(0, -1, prevImageDefault.size.width, prevImageDefault.size.height);
    
    [prevBtn setBackgroundImage:prevImageDefault forState:UIControlStateNormal];
    [prevBtn setBackgroundImage:prevImagePressed forState:UIControlStateHighlighted];
    [prevBtn setImage:prevImageIcon forState:UIControlStateNormal];
    
    [prevBtn addTarget:vc action:@selector(handlePrevPress:) forControlEvents:UIControlEventTouchUpInside];
    
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.adjustsImageWhenHighlighted = NO;
    UIImage *searchImageDefault = [UIImage imageNamed:@"button_topcluster_middle_default.png"];
    UIImage *searchImagePressed = [UIImage imageNamed:@"button_topcluster_middle_pressed.png"];
    
    searchBtn.frame = CGRectMake(prevImageDefault.size.width, -1, searchImageDefault.size.width, searchImageDefault.size.height);

    [searchBtn setImage:[UIImage imageNamed:@"icon_search_01.png"] forState:UIControlStateNormal];
    
    if (searchOn) {
        [searchBtn addTarget:vc action:@selector(handleEndSearchPress:) forControlEvents:UIControlEventTouchUpInside];
        [searchBtn setBackgroundImage:searchImagePressed forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:searchImageDefault forState:UIControlStateHighlighted];
        
    } else {
        [searchBtn addTarget:vc action:@selector(handleSearchPress:) forControlEvents:UIControlEventTouchUpInside];
        [searchBtn setBackgroundImage:searchImageDefault forState:UIControlStateNormal];
        [searchBtn setBackgroundImage:searchImagePressed forState:UIControlStateHighlighted];
    }

    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.adjustsImageWhenHighlighted = NO;
    UIImage *nextImageDefault = [UIImage imageNamed:@"button_topcluster_right_default.png"];
    UIImage *nextImagePressed = [UIImage imageNamed:@"button_topcluster_right_pressed.png"];
    UIImage *nextImageIcon = [UIImage imageNamed:@"icon_arrow_right_01.png"];
    
    nextBtn.frame = CGRectMake(prevImageDefault.size.width + searchImageDefault.size.width, -1, nextImageDefault.size.width, nextImageDefault.size.height);

    [nextBtn setBackgroundImage:nextImageDefault forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:nextImagePressed forState:UIControlStateHighlighted];
    [nextBtn setImage:nextImageIcon forState:UIControlStateNormal];
    
    [nextBtn addTarget:vc action:@selector(handleNextPress:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect buttonFrame = CGRectMake(0, 0, prevImageDefault.size.width + searchImageDefault.size.width + nextImageDefault.size.width, prevImageDefault.size.height);
    UIView *buttonHolder = [[[UIView alloc] initWithFrame:buttonFrame] autorelease];
    
    //cView.imageEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    
    [buttonHolder addSubview:prevBtn];
    [buttonHolder addSubview:searchBtn];
    [buttonHolder addSubview:nextBtn];
    
    vc.navigationItem.titleView = buttonHolder;
}

- (void)animateInView:(UIView *)view
{
    [UIView animateWithDuration:0.50f 
                               delay:0.25f 
                             options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction) 
                          animations:^(void){
                              view.alpha = 1;
                          }
                          completion:NULL];
}

@end