//
//  SimpleGeoDataParser.m
//  Weego
//
//  Created by Nicholas Velloff on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleGeoDataParser.h"
#import "Location.h"
#import "SearchCategory.h"

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

- (void)processSimpleGeoResponse:(NSArray *)places
{
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:[places count]];
    for (int i=0; i<[places count]; i++)
    {
        SGPlace *place = [places objectAtIndex:i];
        Location *loc = [[[Location alloc] initWithSimpleGeoFeatureResult:place] autorelease];
        [results addObject:loc];
    }
    [Model sharedInstance].geoSearchResults = results;
}

- (void)processSimpleGeoContextResponse:(SGContext *)context
{
    Location *loc = [[[Location alloc] initWithSimpleGeoAddressResult:context] autorelease];
    [Model sharedInstance].geoSearchResults = [NSMutableArray arrayWithObject:loc];
}

- (void)processSimpleGeoCategoryResponse:(NSArray *)categories
{
    NSMutableArray *catSet = [[[NSMutableArray alloc] init] autorelease];
    for (int i=39; i<[categories count]; i++) // the first 39 results are not relevant
    {
        NSDictionary *record = [categories objectAtIndex:i];
        SearchCategory *cat = [[[SearchCategory alloc] init] autorelease];
        [cat populateWithDict:record];
        [catSet addObject:cat];
    }
    [Model sharedInstance].categoryResults = catSet;
    SearchCategory *curLoc = [[[SearchCategory alloc] init] autorelease];
    curLoc.category = @"Current Location";
    curLoc.type = @"Current Location";
    [catSet insertObject:curLoc atIndex:0];
}
@end
