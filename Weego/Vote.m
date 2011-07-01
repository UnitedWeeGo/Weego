//
//  Vote.m
//  BigBaby
//
//  Created by Dave Prukop on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Vote.h"


@implementation Vote

@synthesize ownerEventId, locationId, userId, removeVote, isTemporary;

- (void)dealloc {
    [ownerEventId release];
    [locationId release];
    [userId release];
    [super dealloc];
}

@end
