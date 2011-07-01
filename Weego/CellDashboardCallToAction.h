//
//  CellCallToAction.h
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellDashboardCallToActionHeight 42.0

@interface CellDashboardCallToAction : BBTableViewCell {
    int feedCount;
    UIImageView *feedIconView;
    UILabel *feedCountLabel;
}

- (void)setFeedCount:(int)feedCount;

@end
