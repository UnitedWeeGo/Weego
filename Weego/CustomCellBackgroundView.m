//
//  CellBgRoundedCorner.m
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomCellBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define ROUND_SIZE 3.0

@implementation CustomCellBackgroundView

@synthesize position, colorScheme;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.colorScheme = CustomCellBackgroundViewColorSchemeDark;
    }
    return self;
}

-(void)drawRect:(CGRect)rect 
{
    // Drawing code
    
    UIColor *borderColor = [UIColor clearColor];
    UIColor *fillColor = [UIColor clearColor];
    UIColor *dividerColor = borderColor;
    
    if (colorScheme == CustomCellBackgroundViewColorSchemeDark) {
        borderColor = HEXCOLOR(0xFFFFFFFF);
        fillColor = HEXCOLOR(0xF3F3F3FF);
        dividerColor = HEXCOLOR(0xCCCCCCFF);
    } else if (colorScheme == CustomCellBackgroundViewColorSchemeLight) {
        borderColor = HEXCOLOR(0xCCCCCCFF);
        fillColor = HEXCOLOR(0xF9F9F9FF);
        dividerColor = borderColor;
    } else if (colorScheme == CustomCellBackgroundViewColorSchemeNoBorder) {
        fillColor = HEXCOLOR(0xF9F9F9FF);
    } else if (colorScheme == CustomCellBackgroundViewColorSchemeSelected) {
        borderColor = HEXCOLOR(0xCCCCCCFF);
        fillColor = HEXCOLOR(0x999999FF);
        dividerColor = borderColor;
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
    CGContextSetLineWidth(c, 1);
    
    if (position == CustomCellBackgroundViewPositionTop) {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 0.5;
        miny = miny + 0.5;
        
        maxx = maxx - 0.5;
        maxy = maxy + 0.5;
        
        CGContextMoveToPoint(c, minx, maxy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, maxy);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        
        return;
    } else if (position == CustomCellBackgroundViewPositionBottom) {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 0.5;
        miny = miny ;
        
        maxx = maxx - 0.5;
        maxy = maxy - 0.5;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, ROUND_SIZE);
        CGContextAddLineToPoint(c, maxx, miny);
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        
        if (dividerColor != borderColor) {
            CGContextRef d = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(d, [dividerColor CGColor]);
            CGContextSetLineWidth(d, 1);
            
            CGContextMoveToPoint(d, minx, miny);
            CGContextAddLineToPoint(d, maxx, miny);
            CGContextClosePath(d);
            CGContextDrawPath(d, kCGPathStroke);
        }
        
        return;
    } else if (position == CustomCellBackgroundViewPositionMiddle) {
        CGFloat minx = CGRectGetMinX(rect) , maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 0.5;
        miny = miny ;
        
        maxx = maxx - 0.5;
        maxy = maxy + 0.5;
        
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextAddLineToPoint(c, minx, maxy);
        
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        
        if (dividerColor != borderColor) {
            CGContextRef d = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(d, [dividerColor CGColor]);
            CGContextSetLineWidth(d, 1);
            
            CGContextMoveToPoint(d, minx, miny);
            CGContextAddLineToPoint(d, maxx, miny);
            CGContextClosePath(d);
            CGContextDrawPath(d, kCGPathStroke);
        }
        
        return;
    } else if (position == CustomCellBackgroundViewPositionSingle) {
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + 0.5;
        miny = miny + 0.5;
        
        maxx = maxx - 0.5;
        maxy = maxy - 0.5;
        
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, ROUND_SIZE);
        CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, ROUND_SIZE);
        CGContextAddArcToPoint(c, minx, maxy, minx, midy, ROUND_SIZE);
        
        // Close the path
        CGContextClosePath(c);
        // Fill & stroke the path
        CGContextDrawPath(c, kCGPathFillStroke);
        return;         
    }
}
- (void)dealloc
{
    [super dealloc];
}

@end
