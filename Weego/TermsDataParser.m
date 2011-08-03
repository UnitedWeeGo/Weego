//
//  TermsDataParser.m
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TermsDataParser.h"

@implementation TermsDataParser

static TermsDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (TermsDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[TermsDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton TermsDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];	
    [Model sharedInstance].termsResults = responseString;
    [responseString release];
}

@end