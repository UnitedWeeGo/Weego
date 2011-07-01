//
//  CellDashboardEvent.h
//  BigBaby
//
//  Created by Dave Prukop on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"
#import "SubViewEventInfo.h"

#define CellDashboardEventHeight 69.0

@class Event;

@interface CellDashboardEvent : BBTableViewCell {
    SubViewEventInfo *cellView;
}

@property (nonatomic, retain) Event *event;

@end
