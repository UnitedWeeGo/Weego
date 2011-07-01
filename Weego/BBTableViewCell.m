//
//  BBTableViewCell.m
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTableViewCell.h"


@implementation BBTableViewCell

@synthesize bgView;
//@synthesize bgViewSelected;
@synthesize height;
@synthesize cellHostView;
//@synthesize colorScheme;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        height = 44.0;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        backView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backView;
        [backView release];
    }
    return self;
}

- (void)isFirst:(BOOL)firstValue isLast:(BOOL)lastValue
{
    int bgPosition = 0;
    if (firstValue == YES && lastValue == YES) bgPosition = CustomCellBackgroundViewPositionSingle;
    else if (firstValue == YES && lastValue == NO) bgPosition = CustomCellBackgroundViewPositionTop;
    else if (firstValue == NO && lastValue == NO) bgPosition = CustomCellBackgroundViewPositionMiddle;
    else if (firstValue == NO && lastValue == YES) bgPosition = CustomCellBackgroundViewPositionBottom;
    
    bgView = [[[CustomCellBackgroundView alloc] initWithFrame:CGRectMake(0,0,300,height)] autorelease];
    bgView.position = bgPosition;
    bgViewSelected = [[[CustomCellBackgroundView alloc] initWithFrame:CGRectMake(0,0,300,height)] autorelease];
    bgViewSelected.position = bgPosition;
    if (cellHostView == CellHostViewHome) {
        bgView.colorScheme = CustomCellBackgroundViewColorSchemeDark;
        bgViewSelected.colorScheme = CustomCellBackgroundViewColorSchemeSelected;
    } else if (cellHostView == CellHostViewEvent) {
        bgView.colorScheme = CustomCellBackgroundViewColorSchemeLight;
        bgViewSelected.colorScheme = CustomCellBackgroundViewColorSchemeSelected;
    }
    bgView.tag = 1;
    bgViewSelected.tag = 2;
    self.backgroundView = bgView;
    [self.backgroundView setNeedsDisplay];
    self.selectedBackgroundView = bgViewSelected;
    [self.selectedBackgroundView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    if ([self viewWithTag:1] == bgView) [bgView removeFromSuperview];
    bgView = nil;
    if ([self viewWithTag:2] == bgViewSelected) [bgViewSelected removeFromSuperview];
    bgViewSelected = nil;
    [super dealloc];
}

@end
