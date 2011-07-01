//
//  HeaderViewLoginRegister.m
//  BigBaby
//
//  Created by Dave Prukop on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderViewLoginRegister.h"

@interface HeaderViewLoginRegister (Private)

- (void)handleFacebookPressed:(id)sender;

@end

@implementation HeaderViewLoginRegister

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nextY = 16;
        
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, self.frame.size.width, 28)];
        labelTitle.textColor = HEXCOLOR(0x333333FF);
        labelTitle.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:24];
        labelTitle.backgroundColor = [ UIColor clearColor ];
        labelTitle.textAlignment = UITextAlignmentCenter;
        labelTitle.text = @"New here?";
        [self addSubview:labelTitle];
        [labelTitle release];
        
        nextY = labelTitle.frame.origin.y + labelTitle.frame.size.height;
        
        loginFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
        loginFacebook.frame = CGRectMake(9, nextY + 6, 302, 45);
        [loginFacebook setBackgroundImage:[UIImage imageNamed:@"button_LoginFacebook_default.png"] forState:UIControlStateNormal];
        [loginFacebook setBackgroundImage:[UIImage imageNamed:@"button_LoginFacebook_pressed.png"] forState:UIControlEventTouchDown];
        [loginFacebook addTarget:self action:@selector(handleFacebookPressed:) forControlEvents:UIControlEventTouchUpInside];
        [loginFacebook setImage:[UIImage imageNamed:@"icon_facebook.png"] forState:UIControlStateNormal];
        [loginFacebook setTitle:@"Login with Facebook" forState:UIControlStateNormal];
        loginFacebook.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
        loginFacebook.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        loginFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        UIColor *fbButtonTitleColor = HEXCOLOR(0xFFFFFFFF);
        [loginFacebook setTitleColor:fbButtonTitleColor forState:UIControlStateNormal];
        UIColor *shadowColor = HEXCOLOR(0x33333333);
        loginFacebook.titleLabel.shadowColor = shadowColor;
        loginFacebook.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self addSubview:loginFacebook];
        
        nextY = loginFacebook.frame.origin.y + loginFacebook.frame.size.height;
        
        labelDisclosure = [[UILabel alloc] initWithFrame:CGRectMake(60, nextY + 8, self.frame.size.width - 80, 34)];
        labelDisclosure.textColor = HEXCOLOR(0x999999FF);
        labelDisclosure.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
        labelDisclosure.backgroundColor = [ UIColor clearColor ];
        labelDisclosure.textAlignment = UITextAlignmentCenter;
        labelDisclosure.lineBreakMode = UILineBreakModeWordWrap;
        labelDisclosure.numberOfLines = 0;
        labelDisclosure.text = @"WeeGo will never post to your account without your permission.";
        [labelDisclosure sizeToFit];
        [self addSubview:labelDisclosure];
        [labelDisclosure release];

        nextY = labelDisclosure.frame.origin.y + labelDisclosure.frame.size.height;
        
        labelOr = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY+6, self.frame.size.width, 22)];
        labelOr.textColor = HEXCOLOR(0x333333FF);
        labelOr.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:18];
        labelOr.backgroundColor = [ UIColor clearColor ];
        labelOr.textAlignment = UITextAlignmentCenter;
        labelOr.text = @"or";
        [self addSubview:labelOr];
        [labelOr release];
        
        nextY = labelOr.frame.origin.y + labelOr.frame.size.height;
        
        self.frame = CGRectMake(self.frame.origin.x, 
                                self.frame.origin.y, 
                                self.frame.size.width, 
                                nextY);
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)handleFacebookPressed:(id)sender
{
    if ([delegate respondsToSelector:@selector(handleFacebookPressed)]) [delegate handleFacebookPressed];
}

@end
