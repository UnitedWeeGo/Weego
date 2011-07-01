//
//  LoginFacebookPopup.m
//  BigBaby
//
//  Created by Dave Prukop on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginFacebookPopup.h"

@implementation LoginFacebookPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float addedY = 0.0;
        if ([Model sharedInstance].currentViewState == ViewStateMap) addedY = 40.0;
        
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modal_mask_01.png"]];
        bgView.frame = frame;
        [self addSubview:bgView];
        [bgView release];
        
        UIImageView *mainImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"modal_window_01.png"]];
        mainImage.frame = CGRectMake((frame.size.width - mainImage.image.size.width)/2 , 
                                     ((frame.size.height - mainImage.image.size.height)/2) + addedY, 
                                     mainImage.image.size.width, 
                                     mainImage.image.size.height);
        [self addSubview:mainImage];
        [mainImage release];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(mainImage.frame.origin.x + 15, 
                                                                   mainImage.frame.origin.y + 16, 
                                                                   250, 30)];
        title.font = [UIFont fontWithName:@"MyriadPro-Regular" size:24];
        title.textColor = HEXCOLOR(0xFFFFFFFF);
        title.backgroundColor = [UIColor clearColor];
        title.text = @"New Here?";
        [self addSubview:title];
        [title release];
        
        UILabel *copy = [[UILabel alloc] initWithFrame:CGRectMake(mainImage.frame.origin.x + 15, 
                                                                   mainImage.frame.origin.y + 54, 
                                                                   270, 80)];
        copy.font = [UIFont fontWithName:@"MyriadPro-Regular" size:16];
        copy.textColor = HEXCOLOR(0xFFFFFFFF);
        copy.backgroundColor = [UIColor clearColor];
        copy.numberOfLines = 2;
        copy.text = @"Weego will never post to your account without your permission.";
        [self addSubview:copy];
        [copy release];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(mainImage.frame.origin.x + mainImage.frame.size.width - 50,
                                       mainImage.frame.origin.y + 6, 
                                       44, 
                                       44);
        closeButton.backgroundColor = HEXCOLOR(0x00FF0000);
        [closeButton setImage:[UIImage imageNamed:@"icon_close_modal.png"] forState:UIControlStateNormal];
        closeButton.imageEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);
        [closeButton addTarget:self action:@selector(hideMe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        UIImage *bg1 = [UIImage imageNamed:@"button_LoginFacebook_sm_default.png"];
        UIImage *bg2 = [UIImage imageNamed:@"button_LoginFacebook_sm_pressed.png"];
        
        UIColor *col = HEXCOLOR(0xFFFFFFFF);
        UIColor *shadowColor = HEXCOLOR(0x000000FF);
        
        loginFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
        loginFacebook.frame = CGRectMake(mainImage.frame.origin.x + 13, mainImage.frame.origin.y + 132, bg1.size.width, bg1.size.height);
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
        [self addSubview:loginFacebook];
    }
    return self;
}

- (void)handleFacebookPressed:(id)sender
{
    [[ViewController sharedInstance] authenticateWithFacebook];
}

- (void)hideMe
{
    [[ViewController sharedInstance] hideFacebookPopupWithAnimation:YES];
}

- (void)dealloc
{
    [super dealloc];
}

@end
