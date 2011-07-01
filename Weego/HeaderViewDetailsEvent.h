//
//  HeaderViewDetailsEvent.h
//  BigBaby
//
//  Created by Dave Prukop on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewEventInfo.h"

@protocol HeaderViewDetailsEventDelegate <NSObject>

- (void)eventReachedDecided;

@optional
- (void)editEventRequested;

@end

@interface HeaderViewDetailsEvent : UIView {
    float nextY;
    SubViewEventInfo *cellView;
    UILabel *labelEndsIn;
    UILabel *labelTimer;
    UIButton *editDisclosure;
}

@property (nonatomic, retain) Event *event;
@property (nonatomic, assign) id <HeaderViewDetailsEventDelegate> delegate;

@end
