//
//  SubViewNoLocations.m
//  BigBaby
//
//  Created by Dave Prukop on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewNoLocations.h"


@implementation SubViewNoLocations

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, 280, 30)];
        labelTitle.backgroundColor = [UIColor clearColor];
        labelTitle.font = [UIFont fontWithName:@"MyriadPro-SemiboldIt" size:16];
        labelTitle.textColor = HEXCOLOR(0x666666FF);
        labelTitle.text = @"No locations added";
        [self addSubview:labelTitle];
        [labelTitle release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
