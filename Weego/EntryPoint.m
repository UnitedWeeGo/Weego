//
//  EntryPoint.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryPoint.h"

@interface EntryPoint (Private)

- (void)handleFacebookPressed:(id)sender;

@end

@implementation EntryPoint

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

- (void)loadView
{
    [super loadView];
//    [[NavigationSetter sharedInstance] setNavState:NavStateEntry withTarget:self];
    
    // background screen
    UIImage *bgImage = [UIImage imageNamed:@"load_screen.png"];
    UIImageView *bgImageView = [[[UIImageView alloc] initWithImage:bgImage] autorelease];
    bgImageView.frame = CGRectMake(0, -20, bgImage.size.width, bgImage.size.height);
    [[self view] addSubview:bgImageView];
    
    UIColor *col = HEXCOLOR(0xFFFFFFFF);
    UIColor *shadowColor = HEXCOLOR(0x000000FF);

    // sign up btn
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_lrg2x_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_lrg2x_pressed.png"];
    
    /*
    CGRect buttonTargetSize = CGRectMake(8, 328, bg1.size.width, bg1.size.height);
    
    
    UIButton *cViewSignUp = [UIButton buttonWithType:UIButtonTypeCustom];
    cViewSignUp.adjustsImageWhenHighlighted = NO;
    [cViewSignUp setFrame:buttonTargetSize];
    
    SEL selector = nil;
    selector = @selector(handleTryNowPress:);
    
    [cViewSignUp addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [cViewSignUp setBackgroundImage:bg1 forState:UIControlStateNormal];
    [cViewSignUp setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [cViewSignUp setBackgroundImage:bg2 forState:UIControlStateDisabled];
    [cViewSignUp setTitle:@"Try Now" forState:UIControlStateNormal];
    
    [cViewSignUp setTitleColor:col forState:UIControlStateNormal];
    
    cViewSignUp.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    cViewSignUp.titleLabel.lineBreakMode = UILineBreakModeClip;
    
    cViewSignUp.titleLabel.shadowColor = shadowColor;
    cViewSignUp.titleLabel.shadowOffset = CGSizeMake(1.0, 2.0);
    
    cViewSignUp.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    [[self view] addSubview:cViewSignUp];
    */
    
    loginFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    loginFacebook.frame = CGRectMake(8, 380, bg1.size.width, bg1.size.height);
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
    
}
/*
- (void)handleSignUpPress:(id)sender
{
    [[ViewController sharedInstance] showRegistration:self];
}
*/
- (void)handleTryNowPress:(id)sender
{
    [Model sharedInstance].isInTrial = YES;
    [[Model sharedInstance] createTrialParticipant];
    [[ViewController sharedInstance] navigateToDashboard];
}
/*
- (void)handleLoginPress:(id)sender
{
    [[ViewController sharedInstance] showLogin:self];
}
 */

- (void)handleFacebookPressed:(id)sender
{
    [[ViewController sharedInstance] authenticateWithFacebook];
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NavigationSetter sharedInstance] setNavState:NavStateEntry withTarget:self];
    [[ViewController sharedInstance] showDropShadow:0];
    [[ViewController sharedInstance] showHomeBackground];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
