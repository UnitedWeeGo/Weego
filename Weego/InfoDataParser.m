//
//  InfoDataParser.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoDataParser.h"

@implementation InfoDataParser

static InfoDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (InfoDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[InfoDataParser alloc] init];       
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
    [Model sharedInstance].infoResults = responseString;
    [responseString release];
}
@end