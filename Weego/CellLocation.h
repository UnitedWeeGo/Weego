//
//  CellLocation.h
//  BigBaby
//
//  Created by Dave Prukop on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewLocation.h"
#import "BBTableViewCell.h"

#define CellLocationHeight 69.0

@interface CellLocation : BBTableViewCell {
    SubViewLocation *cellView;
}

@property (nonatomic, assign) id <SubViewLocationDelegate> delegate;
@property (nonatomic, retain) Location *location;
//@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) EventState eventState;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL doShowReportingLocationIcon;

- (void)showError;

@end
