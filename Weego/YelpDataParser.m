//
//  YelpDataParser.m
//  Weego
//
//  Created by Nicholas Velloff on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YelpDataParser.h"
#import "JSON.h"
#import "Location.h"

@interface YelpDataParser(Private)

@end

@implementation YelpDataParser

static YelpDataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (YelpDataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[YelpDataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton YelpDataParser.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (void)processServerResponse:(NSMutableData *)myData
{
    NSString *responseString = [[[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding] autorelease];
	SBJsonParser *json = [[SBJsonParser new] autorelease];    
    
    NSObject *parsedJSON = [json objectWithString:responseString];
    
    if ([parsedJSON isKindOfClass:[NSArray class]]) // test for return type - CATEGORIES
    {
        NSLog(@"Data is categories");
        NSArray *cats = (NSArray *)parsedJSON;
        NSMutableArray *catSet = [[[NSMutableArray alloc] init] autorelease];
        for (int i=0; i<[cats count]; i++)
        {
            NSString *categoryString = [cats objectAtIndex:i];
            SearchCategory *cat = [[[SearchCategory alloc] init] autorelease];
            [cat populateWithWeegoCategory:categoryString];
            [catSet addObject:cat];
        }
        [Model sharedInstance].categoryResults = catSet;
        SearchCategory *curLoc = [[[SearchCategory alloc] init] autorelease];
        curLoc.category = @"Current Location";
        curLoc.type = @"Current Location";
        [catSet insertObject:curLoc atIndex:0];
        
    }
    else if ([parsedJSON isKindOfClass:[NSDictionary class]]) // test for return type - YELP RESULTS
    {
        NSLog(@"Data is yelp result");
        NSArray *results = [(NSDictionary *)parsedJSON objectForKey:@"businesses"];
        
        NSMutableArray *locObjects = [[[NSMutableArray alloc] init] autorelease];
        
        for (int x=0; x<[results count]; x++) {
            Location *loc = [[[Location alloc] initWithYelpJsonResultDict:[results objectAtIndex:x]] autorelease];
            [locObjects addObject:loc];
        }
        [Model sharedInstance].geoSearchResults = locObjects;
    }
}

@end
