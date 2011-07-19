//
//  SearchCategory.m
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchCategory.h"

@implementation SearchCategory

@synthesize type,category,category_id,subcategory;

- (void)populateWithDict:(NSDictionary *)record
{
    self.type = [record objectForKey:@"type"];
    self.category = [record objectForKey:@"category"];
    self.subcategory = [record objectForKey:@"subcategory"];
    self.category_id = [record objectForKey:@"category_id"];
}

- (NSString *)search_string
{
    return [NSString stringWithFormat:@"%@ %@", self.category, self.subcategory];
}

- (NSString *)search_category
{
    return [NSString stringWithFormat:@"%@", [self.subcategory length] > 0 ? self.subcategory : self.category];
}


@end
