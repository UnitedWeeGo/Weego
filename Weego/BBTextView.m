//
//  BBTextView.m
//  BigBaby
//
//  Created by Dave Prukop on 3/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTextView.h"


@implementation BBTextView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (UIEdgeInsets)contentInset {
	return UIEdgeInsetsZero; 
}

- (void)dealloc {
    [super dealloc];
}


@end
