//
//  BBTextField.m
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTextField.h"


@implementation BBTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 5);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 5);
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
