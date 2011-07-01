//
//  HeaderViewLoginRegister.h
//  BigBaby
//
//  Created by Dave Prukop on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewLoginRegisterDelegate <NSObject>

- (void)handleFacebookPressed;

@end

@interface HeaderViewLoginRegister : UIView {
    float nextY;
    UILabel *labelTitle;
    UILabel *labelDisclosure;
    UILabel *labelOr;
    UIButton *loginFacebook;
}

@property (nonatomic, assign) id <HeaderViewLoginRegisterDelegate> delegate;

@end
