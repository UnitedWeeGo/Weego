//
//  CellDashboardFeaturedEvent.h
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"
#import "SubViewEventInfo.h"
#import "SubViewLocation.h"
#import "SubViewNoLocations.h"
#import "Event.h"

#define CellDashboardFeaturedEventHeight 148.0
#define CellDashboardFeaturedEventHeightWithTimer 168.0

@class Event;

@protocol CellDashboardFeaturedEventDelegate

- (void)eventReachedDecided:(int)index;

@end

@interface CellDashboardFeaturedEvent : BBTableViewCell {
    float nextY;
    SubViewEventInfo *cellTopView;
    UILabel *labelCount;
    UIImageView *countIconView;
    UILabel *labelEndsIn;
    UILabel *labelTimer;
    SubViewLocation *cellBottomView;
    SubViewNoLocations *cellBottomAltView;
    CustomCellBackgroundView *cellBottomBg;
    UIView *separator;
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) id <CellDashboardFeaturedEventDelegate> delegate;

@end
