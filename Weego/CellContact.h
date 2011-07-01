//
//  CellContact.h
//  BigBaby
//
//  Created by Dave Prukop on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface CellContact : UITableViewCell {
    UILabel *labelName;
    UILabel *labelLabel;
    UILabel *labelEmail;
    UIView *separator;
}

@property (nonatomic, assign) Contact *contact;

@end
