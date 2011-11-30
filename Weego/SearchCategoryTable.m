//
//  SearchCategoryTable.m
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchCategoryTable.h"
#import "CellCategory.h"
#import "SearchCategory.h"

@interface SearchCategoryTable (Private)

- (void)initTable;
- (NSArray *)categoriesMatchingSearch:(NSString *)searchString;
- (void)searchCategories;
- (void)updateFilteredCategories:(NSArray *)matchingCategories;

@end

@implementation SearchCategoryTable

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        filteredCategories = [[NSMutableArray alloc] init];
        [self initTable];
        
    }
    return self;
}

- (void)initTable
{
    CGRect tableFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    tableView = [[[UITableView alloc] initWithFrame:tableFrame] autorelease];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    
    NSMutableArray *catSet = [Model sharedInstance].categoryResults;
    NSLog(@"catSet count: %d", [catSet count]);
    
    // if the cat loading somehow failed, attempt to reload it
    if ([catSet count] == 0)
    {
        NSLog(@"no categories, attempting to reload");
        if ([Model sharedInstance].searchAPIType == SearchAPITypeSimpleGeo) 
        {
            [[Controller sharedInstance] getSimpleGeoCategories];
        }
        else if ([Model sharedInstance].searchAPIType == SearchAPITypeYelp)
        {
            [[Controller sharedInstance] getYelpCategories];
        }
    }
}

- (void)updateSearchContentsWithSearchString:(NSString *)searchString
{
    if ([searchString length] > 0) {
        if (currentSearch) [currentSearch release];
        currentSearch = nil;
        currentSearch = [searchString retain];
        
        // remove multi-threading because it performs well enough without it, and stops
        // occasional crash due to thread modifying data while table is reloading
        //[NSThread detachNewThreadSelector:@selector(searchCategories) toTarget:self withObject:nil];
        
        [self searchCategories];
    }
    else
    {
        self.hidden = YES;
    }
}

- (void)searchCategories
{
    NSArray *categoriesMatchingSearchString = [self categoriesMatchingSearch:currentSearch];
    [self updateFilteredCategories:categoriesMatchingSearchString];
    
    // remove multi-threading because it performs well enough without it, and stops
    // occasional crash due to thread modifying data while table is reloading
    /*
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [NSThread setThreadPriority:0.0];
    NSArray *categoriesMatchingSearchString = [self categoriesMatchingSearch:currentSearch];
    [self performSelector:@selector(updateFilteredCategories:) onThread:[NSThread mainThread] withObject:categoriesMatchingSearchString waitUntilDone:NO];
    [pool drain];
     */
}

- (NSArray *)categoriesMatchingSearch:(NSString *)searchString
{
	NSPredicate *pred;
	NSMutableArray *catSet = [Model sharedInstance].categoryResults;
	pred = [NSPredicate predicateWithFormat:@"search_string contains[cd] %@", searchString];
	return [catSet filteredArrayUsingPredicate:pred];
}

- (void)updateFilteredCategories:(NSArray *)matchingCategories
{
    //NSLog(@"updateFilteredCategories start - attempting filter and reload of data");
    [filteredCategories removeAllObjects];
    [filteredCategories addObjectsFromArray:matchingCategories];
    self.hidden = [filteredCategories count] == 0;
    [tableView reloadData];
    //NSLog(@"updateFilteredCategories end - reload complete");
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchCategory *cat = [filteredCategories objectAtIndex:indexPath.row];
    if ([cat.type isEqualToString:@"Current Location"])
    {
        if (delegate) [delegate searchCategoryTableDidSelectCurrentLocation];
    }
    else
    {
        if (delegate) [delegate categorySelected:cat];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [filteredCategories count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    CellCategory *cell = (CellCategory *) [tableView dequeueReusableCellWithIdentifier:@"CellCategoryId"];
    if (cell == nil) {
        cell = [[[CellCategory alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellCategoryId"] autorelease];
    }
    cell.category = [filteredCategories objectAtIndex:indexPath.row];
    return cell;
}


- (void)dealloc
{
    [currentSearch release];
    [filteredCategories removeAllObjects];
    [filteredCategories release];
    [super dealloc];
}

@end