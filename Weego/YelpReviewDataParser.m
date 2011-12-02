//
//  YelpReviewDataParser.m
//  Weego
//
//  Created by Nicholas Velloff on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YelpReviewDataParser.h"

@implementation YelpReviewDataParser

static YelpReviewDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (YelpReviewDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[YelpReviewDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton YelpReviewDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];	
    [Model sharedInstance].reviewResults = responseString;
    [responseString release];
}
@end
