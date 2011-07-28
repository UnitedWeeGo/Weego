//
//  DashboardTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DashboardTVC.h"
#import "Controller.h"
#import "Event.h"
#import "Model.h"
#import "BBTableViewCell.h"
#import "CellDashboardEvent.h"
#import "CellDashboardCallToAction.h"

@interface DashboardTVC(Private)

- (void)fetchData;
- (void)createDataSources;
- (void)showLoadingIndicator;
- (void)handleAllEventsUpdated;
//- (void)handleAllEventsUpdatedNull;
- (BBTableViewCell *)getCellForFeaturedEventWithEvent:(Event *)anEvent andIndex:(int)index;
- (BBTableViewCell *)getCellForShowHideToggle:(NSString *)label;
- (BBTableViewCell *)getCellForEventWithEvent:(Event *)anEvent;
- (void)toggleShowHidePastEvents;
- (void)toggleShowHideFutureEvents;
- (void)showEventDetailWithId:(NSString *)eventId;
- (void)refreshDecidedEvents;

@end


@implementation DashboardTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
	[super loadView];
		
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFF26);
    [self.tableView addSubview:bevelStripe];
    [bevelStripe release];
    
    [[NavigationSetter sharedInstance] setNavState:NavStateDashboard withTarget:self];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizesSubviews = YES;
    
    [Model sharedInstance].currentBGState = BGStateHome;

    if (![Model sharedInstance].isInTrial) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
        [_refreshHeaderView release];	
        [_refreshHeaderView refreshLastUpdatedDate];
        [self fetchData];
        [self showLoadingIndicator];
    } else {
        initialLoadFinished = YES;
        [self createDataSources];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    [[ViewController sharedInstance] showHomeBackground];
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    [Model sharedInstance].currentAppState = AppStateDashboard;
    [Model sharedInstance].currentViewState = ViewStateDashboard;
    
    if ([Model sharedInstance].loginAfterTrial) {
        [Model sharedInstance].loginAfterTrial = NO;
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
        [_refreshHeaderView release];	
        [_refreshHeaderView refreshLastUpdatedDate];
        [self fetchData];
        [self showLoadingIndicator];
    }
    
    [self setUpDataFetcherMessageListeners];
    
    [self createDataSources];
    
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
    
    [[ViewController sharedInstance] hideLoadView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeDataFetcherMessageListeners];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self createDataSources];
}

- (void)fetchData
{
	Controller *controller = [Controller sharedInstance];
	[controller fetchEvents];
}

- (void)createDataSources
{
    [dataSources release];
    dataSources = [[NSMutableArray alloc] init];
    [dataSources removeAllObjects];
    Model *model = [Model sharedInstance];
    [model sortEvents];
    if ([model.weeksEvents count] > 0) {
        for (int i=0; i<[model.weeksEvents count]; i++) {
            NSMutableArray *eventDetails = [[NSMutableArray alloc] init];
            [eventDetails addObject:[model.weeksEvents objectAtIndex:i]];
            [dataSources addObject:eventDetails];
            [eventDetails release];
        }
    }
    if ([model.futureEvents count] > 0) [dataSources addObject:model.futureEvents];
	if ([model.pastEvents count] > 0) [dataSources addObject:model.pastEvents];
    if ([model.weeksEvents count] == 0 && initialLoadFinished) {
        showingInfoDisplay = YES;
        CGRect base = CGRectMake(0, 4, self.view.frame.size.width, 339);
        if ([model.pastEvents count] == 0) base = CGRectMake(0, 4, self.view.frame.size.width, 390);
        infoDisplay = [[InfoDisplay alloc] initWithFrame:base];
        infoDisplay.delegate = self;
        self.tableView.tableHeaderView = infoDisplay;
        [infoDisplay release];
        [[NavigationSetter sharedInstance] setNavState:NavStateDashboardNoEvents withTarget:self];
    } else {
        showingInfoDisplay = NO;
        self.tableView.tableHeaderView = nil;
        [[NavigationSetter sharedInstance] setNavState:NavStateDashboard withTarget:self];
    }
    [self.tableView reloadData];
}

- (void)showLoadingIndicator
{
    _reloading = YES;
    [_refreshHeaderView egoRefreshScrollViewOpenAndShowLoading:self.tableView];
}

#pragma mark - DataFetcherMessageHandler

- (void)setUpDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherSuccessMessage:) name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherErrorMessage:) name:DATA_FETCHER_ERROR object:nil];
}

- (void)removeDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_ERROR object:nil];
}

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    switch (fetchType) {
        case DataFetchTypeGetDashboardEvents:
            NSLog(@"DataFetchTypeGetDashboardEvents Success");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            initialLoadFinished = YES;
            [self createDataSources];
            if (_reloading) [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
            _reloading = NO;
            break;
            
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    switch (fetchType) {
        case DataFetchTypeGetDashboardEvents:
            NSLog(@"DataFetchTypeGetDashboardEvents Error");
            if (_reloading) {
                [_refreshHeaderView egoRefreshScrollViewShowError:self.tableView];
                _reloading = NO;
            } else {
                [_refreshHeaderView egoRefreshScrollViewOpenAndShowError:self.tableView];
            }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark Navigation

- (void)handlePlusPress:(id)sender
{
    [[ViewController sharedInstance] showModalCreateEvent:self];
}

- (void)handlePrefsPress:(id)sender
{
	[[ViewController sharedInstance] showPrefsView:self];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [dataSources count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Model *model = [Model sharedInstance];
    NSArray *sectionData = [dataSources objectAtIndex:section];
    if (sectionData == model.futureEvents) return (futureShowing) ? [sectionData count]+1 : 1;
    else if (sectionData == model.pastEvents) return (pastShowing) ? [sectionData count]+1 : 1;
    else {
        return 1;
    }
    return [sectionData count]; // Should never get here
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBTableViewCell *cell = nil;
    
    NSArray *currentSource = [dataSources objectAtIndex:indexPath.section];
    if (currentSource == [Model sharedInstance].pastEvents) {
        if (indexPath.row == 0) {
            cell = [self getCellForShowHideToggle:[[[NSString alloc] initWithFormat:@"Past Events (%i)", [currentSource count]] autorelease]];
            [(CellDashboardCallToAction*) cell setFeedCount:[[Model sharedInstance] getUnreadMessageCountForPastEvents]];
            if (pastShowing) [cell isFirst:YES isLast:NO];
            else [cell isFirst:YES isLast:YES];
        } else {
            cell = [self getCellForEventWithEvent:(Event *)[currentSource objectAtIndex:indexPath.row-1]];
            if (indexPath.row < [currentSource count]) [cell isFirst:NO isLast:NO];
            else [cell isFirst:NO isLast:YES];
        }
    } else if (currentSource == [Model sharedInstance].futureEvents) {
        if (indexPath.row == 0) {
            cell = [self getCellForShowHideToggle:[[[NSString alloc] initWithFormat:@"Future Events (%i)", [currentSource count]] autorelease]];
            [(CellDashboardCallToAction*) cell setFeedCount:[[Model sharedInstance] getUnreadMessageCountForFutureEvents]];
            if (futureShowing) [cell isFirst:YES isLast:NO];
            else {
                [cell isFirst:YES isLast:YES];
            }
        } else {
            cell = [self getCellForEventWithEvent:(Event *)[currentSource objectAtIndex:indexPath.row-1]];
            if (indexPath.row < [currentSource count]) [cell isFirst:NO isLast:NO];
            else [cell isFirst:NO isLast:YES];
        }
    } else {
        cell = [self getCellForFeaturedEventWithEvent:(Event *)[currentSource objectAtIndex:indexPath.row] andIndex:indexPath.section];
        [cell isFirst:YES isLast:YES];
    }
    return cell;
}

- (BBTableViewCell *)getCellForFeaturedEventWithEvent:(Event *)anEvent andIndex:(int)index
{
    CellDashboardFeaturedEvent *cell = (CellDashboardFeaturedEvent *) [self.tableView dequeueReusableCellWithIdentifier:@"FeaturedEventTableCellId"];
	if (cell == nil) {
		cell = [[[CellDashboardFeaturedEvent alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FeaturedEventTableCellId"] autorelease];
	}
    cell.event = anEvent;
    cell.index = index;
    cell.delegate = self;
    cell.cellHostView = CellHostViewHome;
    return cell;
}


- (BBTableViewCell *)getCellForShowHideToggle:(NSString *)label
{
    CellDashboardCallToAction *cell = (CellDashboardCallToAction *) [self.tableView dequeueReusableCellWithIdentifier:@"ShowHideTableCellId"];
	if (cell == nil) {
		cell = [[[CellDashboardCallToAction alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowHideTableCellId"] autorelease];
	}
    cell.textLabel.text = label;
    cell.cellHostView = CellHostViewHome;
    return cell;
}

- (BBTableViewCell *)getCellForEventWithEvent:(Event *)anEvent
{
    CellDashboardEvent *cell = (CellDashboardEvent *) [self.tableView dequeueReusableCellWithIdentifier:@"EventTableCellId"];
	if (cell == nil) {
		cell = [[[CellDashboardEvent alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventTableCellId"] autorelease];
	}
    cell.event = anEvent;
    cell.cellHostView = CellHostViewHome;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    return [cell isKindOfClass: [CellDashboardFeaturedEvent class]] || [cell isKindOfClass: [CellDashboardEvent class]];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CellLocation *cell = (CellLocation *)[tableView cellForRowAtIndexPath:indexPath];
    //cell.editing = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CellLocation *cell = (CellLocation *)[tableView cellForRowAtIndexPath:indexPath];
    //cell.editing = NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Model *model = [Model sharedInstance];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        Event *eventToDelete;
        if ([cell isKindOfClass: [CellDashboardFeaturedEvent class]])
        {
            CellDashboardFeaturedEvent *fecell = (CellDashboardFeaturedEvent *)cell;
            eventToDelete = fecell.event;
        }
        else if ([cell isKindOfClass: [CellDashboardEvent class]])
        {
            CellDashboardEvent *fecell = (CellDashboardEvent *)cell;
            eventToDelete = fecell.event;
        }
        if (!model.isInTrial)
        {
            [[Controller sharedInstance] setRemovedForEvent:eventToDelete doCountOut:eventToDelete.currentEventState <= EventStateDecided];
        }
        eventToDelete.hasBeenRemoved = YES;
        [model printModel];
        [self createDataSources];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentSource = [dataSources objectAtIndex:indexPath.section];
    if (currentSource == [Model sharedInstance].futureEvents) {
        if (indexPath.row == 0) {
            [self toggleShowHideFutureEvents];
        } else {
            Event *event = [currentSource objectAtIndex:indexPath.row-1];
            [self showEventDetailWithId:event.eventId];
        }
    } else if (currentSource == [Model sharedInstance].pastEvents) {
        if (indexPath.row == 0) {
            [self toggleShowHidePastEvents];
        } else {
            Event *event = [currentSource objectAtIndex:indexPath.row-1];
            [self showEventDetailWithId:event.eventId];
        }
    } else {
        Event *event = [currentSource objectAtIndex:0];
        [self showEventDetailWithId:event.eventId];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 44.0;
    Model *model = [Model sharedInstance];
    NSArray *sectionData = [dataSources objectAtIndex:indexPath.section];
    if (sectionData == model.pastEvents || sectionData == model.futureEvents) {
        if (indexPath.row == 0) height = CellDashboardCallToActionHeight;
        else height = CellDashboardEventHeight;
    } else {
        Event *ev = [sectionData objectAtIndex:indexPath.row];
        height = (ev.currentEventState < EventStateDecided) ? CellDashboardFeaturedEventHeightWithTimer : CellDashboardFeaturedEventHeight;
    }
    return height;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return (showingInfoDisplay) ? 19.0 : 4.0;
    return 1.0;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 11.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}

- (void)toggleShowHidePastEvents
{
    pastShowing = !pastShowing;
    int mySection = 0;
    for (int i=0; i<[dataSources count]; i++) {
        if ([dataSources objectAtIndex:i] == [Model sharedInstance].pastEvents) mySection = i;
    }
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:mySection] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)toggleShowHideFutureEvents
{
    futureShowing = !futureShowing;
    int mySection = 0;
    for (int i=0; i<[dataSources count]; i++) {
        if ([dataSources objectAtIndex:i] == [Model sharedInstance].futureEvents) mySection = i;
    }
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:mySection] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)showEventDetailWithId:(NSString *)eventId
{
    [[ViewController sharedInstance] navigateToEventDetailWithId:eventId];
//                                                  andPushOnStack:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    [[ViewController sharedInstance] showDropShadow:scrollView.contentOffset.y];
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
	[self fetchData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (void)egoRefreshTableHeaderClosed
{
    _reloading = NO;
}

#pragma mark -
#pragma mark CellDashboardFeaturedEventDelegate

- (void)eventReachedDecided:(int)index
{
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
//    NSLog(@"eventReachedDecided : %i", index);
//    if (decidedSections == nil) {
//        decidedSections = [[[NSMutableIndexSet alloc] init] retain];
//    }
//    [decidedSections addIndex:index];
//    NSLog(@"decidedSections count = %i", [decidedSections count]);
//    if (refreshTimer == nil) {
//        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshDecidedEvents) userInfo:nil repeats:NO];
//    }
}
                    
- (void)refreshDecidedEvents
{
    NSLog(@"refreshDecidedEvents");
    [refreshTimer release];
    refreshTimer = nil;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:decidedSections withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [decidedSections release];
    decidedSections = nil;
}

#pragma mark - InfoDisplayDelegate

- (void)infoDisplayWillBeginLoading
{
    
}

- (void)infoDisplayDidFinishLoading
{
    [infoDisplay showContent];
}

- (void)dealloc {
    NSLog(@"DashboardTVC dealloc");
    self.tableView.tableHeaderView = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _refreshHeaderView.delegate = nil;
    [dataSources removeAllObjects];
    [dataSources release];
    dataSources = nil;
    
    if (decidedSections) [decidedSections release];
    
    [self removeDataFetcherMessageListeners];
    [super dealloc];
}


@end
