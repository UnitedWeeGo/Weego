//
//  SearchCategoryTable.m
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchCategoryTable.h"
#import "CellCategory.h"

@interface SearchCategoryTable (Private)

- (void)initTable;
- (NSArray *)categoriesMatchingSearch:(NSString *)searchString;

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
    
    NSMutableArray *catSet = [Model sharedInstance].simpleGeoCategoryResults;
    NSLog(@"catSet count: %d", [catSet count]);
    
    // if the cat loading somehow failed, attempt to reload it
    if ([catSet count] == 0)
    {
        NSLog(@"no categories, attempting to reload");
        [[Controller sharedInstance] getSimpleGeoCategories];
    }
}

- (void)updateSearchContentsWithSearchString:(NSString *)searchString
{
    if ([searchString length] > 0) {
        if (currentSearch) [currentSearch release];
        currentSearch = [searchString retain];
        [NSThread detachNewThreadSelector:@selector(searchCategories) toTarget:self withObject:nil];
    }
    else
    {
        self.hidden = YES;
    }
}

- (void)searchCategories
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [NSThread setThreadPriority:0.0];
    NSArray *categoriesMatchingSearchString = [self categoriesMatchingSearch:currentSearch];
    [self performSelector:@selector(updateFilteredCategories:) onThread:[NSThread mainThread] withObject:categoriesMatchingSearchString waitUntilDone:NO];
    [pool drain];
}

- (NSArray *)categoriesMatchingSearch:(NSString *)searchString
{
	NSPredicate *pred;
	NSMutableArray *catSet = [Model sharedInstance].simpleGeoCategoryResults;
	pred = [NSPredicate predicateWithFormat:@"search_string contains[cd] %@", searchString];
	return [catSet filteredArrayUsingPredicate:pred];
}

- (void)updateFilteredCategories:(NSArray *)matchingCategories
{
    [filteredCategories removeAllObjects];
    [filteredCategories addObjectsFromArray:matchingCategories];
    self.hidden = [filteredCategories count] == 0;
    if ([filteredCategories count] > 0) [tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (delegate) [delegate categorySelected:[filteredCategories objectAtIndex:indexPath.row]];
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