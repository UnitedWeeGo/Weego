//
//  PrivacyDataParser.m
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrivacyDataParser.h"

@implementation PrivacyDataParser

static PrivacyDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (PrivacyDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[PrivacyDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton PrivacyDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];	
    [Model sharedInstance].privacyResults = responseString;
    [responseString release];
}

@end