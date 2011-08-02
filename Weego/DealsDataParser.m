//
//  DealsDataParser.m
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealsDataParser.h"

@implementation DealsDataParser

static DealsDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (DealsDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[DealsDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton DealsDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];	
    [Model sharedInstance].dealResults = responseString;
    [responseString release];
}
@end