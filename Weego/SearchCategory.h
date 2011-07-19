//
//  SearchCategory.h
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SearchCategory : NSObject {
    
}

@property (nonatomic, readonly) NSString *search_string;
@property (nonatomic, readonly) NSString *search_category;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *category_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *subcategory;

- (void)populateWithDict:(NSDictionary *)dict;

@end
