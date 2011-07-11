//
//  SimpleGeoDataParser.m
//  Weego
//
//  Created by Nicholas Velloff on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleGeoDataParser.h"
#import "Location.h"

@interface SimpleGeoDataParser(Private)

@end

@implementation SimpleGeoDataParser

static SimpleGeoDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (SimpleGeoDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[SimpleGeoDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton SimpleGeoDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processSimpleGeoResponse:(SGFeatureCollection *)places
{
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[places count]];
    for (int i=0; i<[places count]; i++)
    {
        SGFeature *place = [[places features] objectAtIndex:i];
        Location *loc = [[[Location alloc] initWithSimpleGeoFeatureResult:place] autorelease];
        [results addObject:loc];
    }
    [Model sharedInstance].geoSearchResults = results;
}

/*
- (void)processServerResponse:(NSMutableData *)myData
{
    
    NSString *responseString = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];	
	NSError *jsonError = nil;
	SBJsonParser *json = [[SBJsonParser new] autorelease];
    
    NSDictionary *parsedJSON = [json objectWithString:responseString];
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[[parsedJSON objectForKey:@"results"] count]];
    
    if ([jsonError code]==0) {
        for (int x=0; x<[[parsedJSON objectForKey:@"results"] count]; x++) {
            Location *loc = [[[Location alloc] initWithPlacesJsonResultDict:[[parsedJSON objectForKey:@"results"] objectAtIndex:x]] autorelease];
            [results addObject:loc];
        }
    }
    [Model sharedInstance].geoSearchResults = results;
     
}
 */
@end
