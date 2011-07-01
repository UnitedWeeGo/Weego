//
//  CustomUITextView.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomUITextView.h"


@implementation CustomUITextView

/* This allows us to use the full height of the UITextView before it auto
    scrolls the content. 
*/
-(void) setContentOffset:(CGPoint)contentOffset {
    [self setContentInset:UIEdgeInsetsZero];
    [super setContentOffset:contentOffset];
}

@end
