//
//  HelpDataParser.m
//  BigBaby
//
//  Created by Dave Prukop on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpDataParser.h"

@implementation HelpDataParser

static HelpDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (HelpDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[HelpDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton InfoDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];	
    [Model sharedInstance].helpResults = responseString;
}

@end
