//
//  UnderlineLabel.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UnderlineLabel.h"


@implementation UnderlineLabel

- (id) initWithFrame:(CGRect)frame andColor:(UIColor *)color
{
    underlineColor = [color retain];
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    if (underlineColor == nil) underlineColor = [[UIColor alloc] initWithWhite:1.0f alpha:1.0f];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, underlineColor.CGColor);
    
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height - 2.5);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - 2.5);
    
    CGContextStrokePath(context);
    
    [super drawRect:rect]; 
    
}

- (void) dealloc
{
    [underlineColor release];
    [super dealloc];
}

@end
