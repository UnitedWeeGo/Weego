//
//  Prefs.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
#import "Prefs.h"


@implementation Prefs

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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NavigationSetter sharedInstance] setNavState:NavStatePrefs withTarget:self];
    
    // sign up btn
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_lrg_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_lrg_pressed.png"];
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    UIColor *shadowColor = HEXCOLOR(0x000000FF);
    
    CGRect buttonTargetSize = CGRectMake(8, 20, bg1.size.width, bg1.size.height);
    
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
    [[self view] addSubview:logoutButton];
    
    // ------
    
    loginFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    loginFacebook.adjustsImageWhenHighlighted = NO;
    loginFacebook.frame = CGRectMake(8, 20, bg1.size.width, bg1.size.height);
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
    [self.view addSubview:loginFacebook];
    
    if ([Model sharedInstance].isInTrial) {
        logoutButton.hidden = YES;
        loginFacebook.hidden = NO;
    } else {
        logoutButton.hidden = NO;
        loginFacebook.hidden = YES;
    }
    
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    infoButton.adjustsImageWhenHighlighted = NO;
    infoButton.frame = CGRectMake(8, 75, bg1.size.width, bg1.size.height);
    [infoButton setBackgroundImage:bg1 forState:UIControlStateNormal];
    [infoButton setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [infoButton addTarget:self action:@selector(handleInfoPress:) forControlEvents:UIControlEventTouchUpInside];
    [infoButton setImage:[UIImage imageNamed:@"icon_facebook.png"] forState:UIControlStateNormal];
    [infoButton setTitle:@"Info --- >" forState:UIControlStateNormal];
    infoButton.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    infoButton.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    infoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [infoButton setTitleColor:col forState:UIControlStateNormal];
    infoButton.titleLabel.shadowColor = shadowColor;
    infoButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [self.view addSubview:infoButton];
    
}

- (void)handleFacebookPressed:(id)sender
{
    [[ViewController sharedInstance] authenticateWithFacebook];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ViewController sharedInstance] showDropShadow:0];
}

- (void)handleHomePress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}

- (void)handleInfoPress:(id)sender
{
    [[ViewController sharedInstance] navigateToInfo];
}

- (void)initiateLogout:(id)sender
{
    [[ViewController sharedInstance] logoutUser:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
 
 */
