//
//  PrefsTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrefsTVC : UITableViewController <MFMailComposeViewControllerDelegate> {
    UIView *footerView;
    UIButton *logoutButton;
    UIButton *loginFacebook;
}

@end
