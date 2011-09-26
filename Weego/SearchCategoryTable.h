//
//  SearchCategoryTable.h
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCategory.h"

@protocol SearchCategoryTableDelegate <NSObject>

- (void)categorySelected:(SearchCategory *)category;
- (void)searchCategoryTableDidSelectCurrentLocation;

@end

@interface SearchCategoryTable : UIView <UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *tableView;
    NSMutableArray *filteredCategories;
    NSString *currentSearch;
    
}

@property (nonatomic, assign) id <SearchCategoryTableDelegate> delegate;

- (void)updateSearchContentsWithSearchString:(NSString *)searchString;

@end
