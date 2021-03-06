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
- (void)showAlertWithCode:(int)code;
- (void)presentRemoveEventAlertWithCancel:(BOOL)isCancel;
- (void)confirmDeleteOrRemovalOfEvent;

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
    
    [Model sharedInstance].currentEvent = nil;
    
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_refreshHeaderView reset:self.tableView];
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
    //NSLog(@"createDataSources");
    [dataSources release];
    dataSources = [[NSMutableArray alloc] init];
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
            //NSLog(@"DataFetchTypeGetDashboardEvents Success");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            initialLoadFinished = YES;
            [self createDataSources];
            if (_reloading) [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
            _reloading = NO;
            break;
        case DataFetchTypeGetEvent:
            [self createDataSources];
            break;
        case DataFetchTypeRemoveEvent:
            [self createDataSources];
            break;
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    int errorType = [[dict objectForKey:DataFetcherErrorKey] intValue];
    switch (fetchType) {
        case DataFetchTypeGetDashboardEvents:
            NSLog(@"DataFetchTypeGetDashboardEvents Error");
            if (_reloading) {
                [_refreshHeaderView egoRefreshScrollViewShowError:self.tableView withCode:errorType];
                _reloading = NO;
            } else {
                [_refreshHeaderView egoRefreshScrollViewOpenAndShowError:self.tableView withCode:errorType];
            }
            break;
        case DataFetchTypeRemoveEvent:
            [self showAlertWithCode:errorType];
            break;
        default:
            break;
    }
}

- (void)showAlertWithCode:(int)code
{
    NSString *title = @"Error";
    NSString *message = @"";
    
    switch (code) {
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"Not Connected To Internet", @"Error Status");
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"Request Timed Out, Try Again...", @"Error Status");
            break;
        default:
            message = NSLocalizedString(@"An Error Occurred, Try Again...", @"Error Status");
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
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
    if (section >= [dataSources count]) return 0;
    NSArray *sectionData = [dataSources objectAtIndex:section]; // crashed (2 out of range) - 0...1
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
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
        if (eventToDelete.iOwnEvent && eventToDelete.currentEventState < EventStateStarted)
        {
            return @"Cancel Event";
        }
        else
        {
            return @"Remove";
        }
    }
    return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass: [CellDashboardFeaturedEvent class]])
        {
            CellDashboardFeaturedEvent *fecell = (CellDashboardFeaturedEvent *)cell;
            eventToDeleteOrRemove = fecell.event;
        }
        else if ([cell isKindOfClass: [CellDashboardEvent class]])
        {
            CellDashboardEvent *fecell = (CellDashboardEvent *)cell;
            eventToDeleteOrRemove = fecell.event;
        }
        [self presentRemoveEventAlertWithCancel:eventToDeleteOrRemove.iOwnEvent && eventToDeleteOrRemove.currentEventState < EventStateStarted && eventToDeleteOrRemove.currentEventState != EventStateNew];
    }
}

- (void)confirmDeleteOrRemovalOfEvent
{
    Model *model = [Model sharedInstance];
    if (!model.isInTrial)
    {
        if (eventToDeleteOrRemove.iOwnEvent && eventToDeleteOrRemove.currentEventState < EventStateStarted)
        {
            NSLog(@"count out:YES cancel event:YES");
            [[Controller sharedInstance] setRemovedForEvent:eventToDeleteOrRemove doCountOut:YES doCancel:YES];
        }
        else
        {
            NSLog(@"count out:%d cancel event:NO", eventToDeleteOrRemove.currentEventState <= EventStateDecided);
            [[Controller sharedInstance] setRemovedForEvent:eventToDeleteOrRemove doCountOut:(eventToDeleteOrRemove.currentEventState <= EventStateDecided) doCancel:NO];
            eventToDeleteOrRemove.hasBeenRemoved = YES;
        }
    }
    else
    {
        eventToDeleteOrRemove.hasBeenRemoved = YES;
    }
    [self createDataSources];
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


#pragma mark -
#pragma mark Table view helpers
- (void)toggleShowHidePastEvents
{
    pastShowing = !pastShowing;
    int mySection = 0;
    for (int i=0; i<[dataSources count]; i++) {
        if ([dataSources objectAtIndex:i] == [Model sharedInstance].pastEvents) mySection = i;
    }
    
    @try
    {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:mySection] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];

    }
    @catch (NSException *crash) 
    {
        NSLog(@"- (void)toggleShowHidePastEvents: crash");
        [self.tableView reloadData];
    }
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
}

- (void)toggleShowHideFutureEvents
{
    futureShowing = !futureShowing;
    int mySection = 0;
    for (int i=0; i<[dataSources count]; i++) {
        if ([dataSources objectAtIndex:i] == [Model sharedInstance].futureEvents) mySection = i;
    }
    
    @try
    {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:mySection] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    @catch (NSException *crash) 
    {
        NSLog(@"- (void)toggleShowHideFutureEvents: crash");
        [self.tableView reloadData];
    }
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
}

- (void)showEventDetailWithId:(NSString *)eventId
{
    [[ViewController sharedInstance] navigateToEventDetailWithId:eventId];
}

#pragma mark -
#pragma mark remove/cancel verification UIAlertViewDelegate
- (void)presentRemoveEventAlertWithCancel:(BOOL)isCancel
{
    NSLog(@"Present remove/cancel event alert");
    
    NSString *title = isCancel? @"Cancel event?" : @"Remove event?";
    NSString *standardMessage = [NSString stringWithFormat:@"Removing this event will remove it from your dashboard", eventToDeleteOrRemove.currentEventState <= EventStateDecided ? @"." : @" and \"Count you out\"."];
    NSString *ownerMessage = @"Are you sure you want to cancel this event?";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:(isCancel ? ownerMessage:standardMessage) delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self confirmDeleteOrRemovalOfEvent];
    }
    eventToDeleteOrRemove = nil;
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
    @try
    {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    @catch (NSException *crash) 
    {
        NSLog(@"- (void)eventReachedDecided: crash");
        [self.tableView reloadData];
    }
}
                    
- (void)refreshDecidedEvents
{
    [refreshTimer release];
    refreshTimer = nil;
    
    @try
    {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:decidedSections withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    @catch (NSException *crash) 
    {
        NSLog(@"- (void)refreshDecidedEvents: crash");
        [self.tableView reloadData];
    }
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
