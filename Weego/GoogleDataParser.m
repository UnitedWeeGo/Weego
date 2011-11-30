//
//  GoogleDataParser.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleDataParser.h"
#import "JSON.h"
#import "Location.h"

@interface GoogleDataParser(Private)

@end

@implementation GoogleDataParser

static GoogleDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (GoogleDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[GoogleDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton GoogleDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];	
	SBJsonParser *json = [[SBJsonParser new] autorelease];
    
    NSDictionary *parsedJSON = [json objectWithString:responseString];
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[[parsedJSON objectForKey:@"results"] count]];
    for (int x=0; x<[[parsedJSON objectForKey:@"results"] count]; x++) {
        Location *loc = [[[Location alloc] initWithPlacesJsonResultDict:[[parsedJSON objectForKey:@"results"] objectAtIndex:x]] autorelease];
        [results addObject:loc];
    }
    [Model sharedInstance].geoSearchResults = results;
}
@end