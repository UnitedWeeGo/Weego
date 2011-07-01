//
//  BBTableViewCell.h
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellBackgroundView.h"

typedef enum {
    CellHostViewHome,
    CellHostViewEvent,
} CellHostView;

@interface BBTableViewCell : UITableViewCell {
    CustomCellBackgroundView *bgView;
    CustomCellBackgroundView *bgViewSelected;
    float height;
    UIColor *borderColor;
    UIColor *fillColor;
}

@property (nonatomic, retain) CustomCellBackgroundView *bgView;
//@property (nonatomic, retain) CustomCellBackgroundView *bgViewSelected;
@property (nonatomic, assign) float height;
@property (nonatomic) CellHostView cellHostView;

- (void)isFirst:(BOOL)firstValue isLast:(BOOL)lastValue;

@end
