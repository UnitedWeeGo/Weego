//
//  CellEventCallToAction.h
//  BigBaby
//
//  Created by Dave Prukop on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellEventCallToActionHeight 42.0

@interface CellEventCallToAction : BBTableViewCell {
    UILabel *fieldTitle;
}

- (void)setTitle:(NSString *)title;

@end
