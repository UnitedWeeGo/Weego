//
//  EventDetailTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventDetailTVC.h"
#import "Event.h"
#import "Location.h"
#import "Participant.h"
#import "SubViewLabel.h"
#import "CellLocation.h"
#import "CellParticipant.h"
#import "CellParticipantsSummary.h"
#import "CellEventCallToAction.h"
#import "BBTableViewCell.h"
#import "NSDate+Helper.h"

enum eventDetailSections {
	eventDetailSectionLocations = 0,
	eventDetailSectionParticipants,
	numEventDetailSections
};

@interface EventDetailTVC (Private)

- (void)handleHomePress:(id)sender;
- (void)handleMorePress:(id)sender;
- (void)showLoadingIndicator;
- (void)fetchData;
- (void)populateCurrentSortedLocations;
- (CellLocation *)getCellForRequestId:(NSString *)requestId;
- (BOOL)orderDidChange;
- (void)handleAllEventsUpdated;
- (void)doGotoMapView;
- (void)doGotoAddView;
- (BBTableViewCell *)getCellForLocationWithLocation:(Location *)aLocation andIndex:(int)anIndex;
- (BBTableViewCell *)getCellForParticipantWithParticipant:(Participant *)aParticipant;
- (BBTableViewCell *)getCellForParticipantsSummary;
- (BBTableViewCell *)getCellForCallToAction:(NSString *)label;
- (void)toggleShowHideOtherLocations;
- (void)toggleShowHideOtherParticipants;
- (void)reorderForNonServerVote;
- (void)reorderCells;
- (void)reorderCellFromIndex:(int)iFrom toIndex:(int)iTo withMovement:(BOOL)move;
- (void)presentMailModalViewController;
- (void)showActionSheetForMorePress;
- (void)showUserActionSheetForUser:(Participant *)part;
- (void)pickDateTime;
- (void)datePickerDoneClick:(id)sender;
- (void)presentRemoveEventAlert;

@end

@implementation EventDetailTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    detail = [Model sharedInstance].currentEvent;
    detail.eventRead = @"true";
    
    otherLocationsShowing = detail.currentEventState < EventStateDecided;
    otherParticipantsShowing = detail.currentEventState < EventStateDecided;
    
    [self populateCurrentSortedLocations];

	UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.tableView addSubview:bevelStripe];
    [bevelStripe release];
    
    if (detail.acceptanceStatus == AcceptanceTypeAccepted)
    {
        [[NavigationSetter sharedInstance] setNavState:NavStateEventDetails withTarget:self];
    }
    else if (detail.currentEventState != EventStateEnded)
    {
        [[NavigationSetter sharedInstance] setNavState:NavStateEventDetailsPending withTarget:self];
    }
    else
    {
        [[NavigationSetter sharedInstance] setNavState:NavStateEventDetailsEnded withTarget:self];
    }
        
    self.tableView.backgroundColor = [UIColor clearColor];
    
    if (![Model sharedInstance].isInTrial) {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
        [_refreshHeaderView release];
        [_refreshHeaderView refreshLastUpdatedDate];
        [self showLoadingIndicator];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [Model sharedInstance].currentAppState = AppStateEventDetails;
    [Model sharedInstance].currentViewState = ViewStateDetails;
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[detail.unreadMessageCount intValue]];
    
	tableHeaderView = [[HeaderViewDetailsEvent alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, 44)];
    tableHeaderView.event = detail;
    tableHeaderView.delegate = self;
	self.tableView.tableHeaderView = tableHeaderView;
    [tableHeaderView release];
    
    [self setUpDataFetcherMessageListeners];
    
    if (![Model sharedInstance].isInTrial) {
        [self fetchData];
    } else {
        [self populateCurrentSortedLocations];
        oldSortedLocations = [currentSortedLocations copy];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeDataFetcherMessageListeners];
}

- (void)showLoadingIndicator
{
    _reloading = YES;
    [_refreshHeaderView egoRefreshScrollViewOpenAndShowLoading:self.tableView];
}

- (void)fetchData
{
	Controller *controller = [Controller sharedInstance];
	[controller fetchEventWithId:detail.eventId andTimestamp:detail.lastUpdatedTimestamp];
}

- (void)populateCurrentSortedLocations
{
    if (oldSortedLocations != nil) [oldSortedLocations release];
    oldSortedLocations = [currentSortedLocations copy];
    [currentSortedLocations release];
    currentSortedLocations = [detail getLocationsByLocationOrder:detail.currentLocationOrder];
    [currentSortedLocations retain];
    if (oldSortedLocations == nil || !otherLocationsShowing) oldSortedLocations = [currentSortedLocations copy];
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
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    switch (fetchType) {
        case DataFetchTypeToggleEventAcceptance:
            if (![pendingCountMeInFetchRequestId isEqualToString:fetchId]) return;
            if (detail.acceptanceStatus == AcceptanceTypeAccepted)
            {
                [[NavigationSetter sharedInstance] setNavState:NavStateEventDetails withTarget:self];
            }
            else
            {
                [[NavigationSetter sharedInstance] setNavState:NavStateEventDetailsPending withTarget:self];
            }
            [self.tableView reloadData];
            return;
            break;
        case DataFetchTypeLoginWithFacebookAccessToken:
            detail = [Model sharedInstance].currentEvent;
            detail.creatorId = [Model sharedInstance].userEmail;
            [[Model sharedInstance] replaceTrialParticipantsWithLoginParticipant];
            [[ViewController sharedInstance] hideFacebookPopupWithAnimation:NO];
            [Model sharedInstance].isInTrial = NO;
            [Model sharedInstance].loginAfterTrial = YES;
            _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
            _refreshHeaderView.delegate = self;
            [self.tableView addSubview:_refreshHeaderView];
            [_refreshHeaderView release];
            [_refreshHeaderView refreshLastUpdatedDate];
            tableHeaderView = [[HeaderViewDetailsEvent alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, 44)];
            tableHeaderView.event = detail;
            tableHeaderView.delegate = self;
            self.tableView.tableHeaderView = tableHeaderView;
            [tableHeaderView release];
            [self.tableView reloadData];
            break;
        case DataFetchTypeRecentParticipants:
            return;
            break;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self populateCurrentSortedLocations];
    if ([currentSortedLocations count] < 2 || [currentSortedLocations count] < [oldSortedLocations count]) oldSortedLocations = [currentSortedLocations copy];
    tableHeaderView.event = detail;
    tableHeaderView.delegate = self;
    self.tableView.tableHeaderView = tableHeaderView;
    if ([Model sharedInstance].currentViewState == ViewStateDetails)
    {
        [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateDetails withTarget:self withFeedCount:[detail.unreadMessageCount intValue]];
    }
    if (_reloading) [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    _reloading = NO;
    [self.tableView reloadData];
    if ([self orderDidChange] && otherLocationsShowing) [self reorderCells];
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    NSString *fetchId = [dict objectForKey:DataFetcherRequestUUIDKey];
    switch (fetchType) {
        case DataFetchTypeGetEvent:
            if (_reloading) {
                [_refreshHeaderView egoRefreshScrollViewShowError:self.tableView];
                _reloading = NO;
            } else {
                [_refreshHeaderView egoRefreshScrollViewOpenAndShowError:self.tableView];
            }
            break;
        case DataFetchTypeAddVoteToLocation:
            [[self getCellForRequestId:fetchId] showError];
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            [self.tableView reloadData];
            break;
        case DataFetchTypeRemoveVoteFromLocation:
            [[self getCellForRequestId:fetchId] showError];
            [[Model sharedInstance] removePendingVoteRequestWithRequestId:fetchId];
            [self.tableView reloadData];
            break;
        case DataFetchTypeToggleEventAcceptance:
            if (detail.acceptanceStatus == AcceptanceTypeAccepted)
            {
                [[NavigationSetter sharedInstance] setNavState:NavStateEventDetails withTarget:self];
            }
            else
            {
                [[NavigationSetter sharedInstance] setNavState:NavStateEventDetailsPending withTarget:self];
            }
            break;
            
        default:
            break;
    }
}

- (CellLocation *)getCellForRequestId:(NSString *)requestId
{
    NSString *locId = [[Model sharedInstance] locationWithRequestId:requestId];
    for (int i=0; i<[oldSortedLocations count]; i++) {
        Location *l = [oldSortedLocations objectAtIndex:i];
        if ([l.locationId isEqualToString:locId]) {
            return (CellLocation *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:eventDetailSectionLocations]];
        }
    }
    return nil;
}

- (BOOL)orderDidChange
{
    for (int i=0; i<[currentSortedLocations count]; i++) {
        if ([oldSortedLocations count] < i+1) return YES;
        if ([currentSortedLocations objectAtIndex:i] != [oldSortedLocations objectAtIndex:i]) return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL deleteEnabled = detail.currentEventState < EventStateDecided;
    if (indexPath.section == eventDetailSectionLocations)
    {
        if ([currentSortedLocations count] > 0 && indexPath.row != [currentSortedLocations count])
        {
            Location *loc = [currentSortedLocations objectAtIndex:indexPath.row];
            return loc.addedByMe && deleteEnabled;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellLocation *cell = (CellLocation *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editing = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellLocation *cell = (CellLocation *)[tableView cellForRowAtIndexPath:indexPath];
    cell.editing = NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Location *loc = (Location *)[currentSortedLocations objectAtIndex:indexPath.row];
        NSLog(@"Delete: %@", loc.name);
        [[Controller sharedInstance] removeLocationWithId:loc.locationId];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row == rowsForLocations-1) {
			if (detail.currentEventState < EventStateDecided) [self doGotoMapView];
            else [self toggleShowHideOtherLocations];
		} 
	} else if (indexPath.section == eventDetailSectionParticipants) {
        if (![Model sharedInstance].isInTrial) {
            if (detail.currentEventState >= EventStateDecided) {
                if (indexPath.row == 0) {
                    [self toggleShowHideOtherParticipants];
                } else if (indexPath.row == [[detail getParticipants] count] + 1) {
                    [self doGotoAddView];
                } else {
                    Participant *p = [[detail getParticipantsSortedByName] objectAtIndex:indexPath.row - 1];
                    [self showUserActionSheetForUser:p];
                    pendingMailParticipant = p;
                }
            } else {
                if (indexPath.row == [[detail getParticipants] count]) {
                    [self doGotoAddView];
                } else {
                    Participant *p = [[detail getParticipantsSortedByName] objectAtIndex:indexPath.row];
                    [self showUserActionSheetForUser:p];
                    pendingMailParticipant = p;
                }
            }
        } else {
            if (indexPath.row == 0) {
                [[ViewController sharedInstance] showFacebookPopup];
            }
        }
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	float headerHeight = 44;
	return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row < rowsForLocations-1) {
            return CellLocationHeight;
		} else if ([[detail getLocations] count] == 1 && indexPath.row == 0) {
            return CellLocationHeight;
        } else {
            return CellEventCallToActionHeight;
		}
	} else if (indexPath.section == eventDetailSectionParticipants) {
        if (indexPath.row == [[detail getParticipants] count]) return CellParticipantHeight;
    }
    return 44.0;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numEventDetailSections;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int numRows = 0;
	if (section == eventDetailSectionLocations) {
        if (detail.currentEventState >= EventStateDecided && !otherLocationsShowing) {
            int numLocations = [oldSortedLocations count];
            if (numLocations > 1) numRows = 2;
            else numRows = 1;
        } else {
            numRows = [oldSortedLocations count] + 1;
        }
        rowsForLocations = numRows;
    }
	if (section == eventDetailSectionParticipants) {
        if (otherParticipantsShowing && ![Model sharedInstance].isInTrial) {
            if (detail.currentEventState >= EventStateDecided) numRows = [[detail getParticipants] count] + 2;
            else numRows = [[detail getParticipants] count] + 1;
//            numRows = [[detail getParticipants] count] + 1;
        } else {
            numRows = 1;
        }
    }
	return numRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BBTableViewCell *cell = nil;
	if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row < rowsForLocations-1) {
            Location *loc = (Location *)[oldSortedLocations objectAtIndex:indexPath.row];
			cell = [self getCellForLocationWithLocation:loc andIndex:indexPath.row];			
            if (indexPath.row == 0 && rowsForLocations > 1) [cell isFirst:YES isLast:NO];
            else [cell isFirst:NO isLast:NO];
		} else if ([oldSortedLocations count] == 1 && indexPath.row == 0) {
            Location *loc = (Location *)[oldSortedLocations objectAtIndex:indexPath.row];
			cell = [self getCellForLocationWithLocation:loc andIndex:indexPath.row];
            [cell isFirst:YES isLast:YES];
        } else {
            NSString *cellLabel = (detail.currentEventState < EventStateDecided) ? @"Add location(s)" : ([[detail getLocations] count] == 0) ? @"No locations added" : (otherLocationsShowing) ? @"Hide other locations" : @"See other locations";
            cell = [self getCellForCallToAction:cellLabel];
            if (indexPath.row == 0) [cell isFirst:YES isLast:YES];
            else [cell isFirst:NO isLast:YES];
		}
	} else if (indexPath.section == eventDetailSectionParticipants) {
        if (indexPath.row == 0 && ![Model sharedInstance].isInTrial && detail.currentEventState >= EventStateDecided) {
            cell = [self getCellForParticipantsSummary];
            [cell isFirst:YES isLast:!otherParticipantsShowing];
        } else if (![Model sharedInstance].isInTrial) { // indexPath.row <= [[detail getParticipants] count] &&
            int index = indexPath.row;
            if (detail.currentEventState >= EventStateDecided) index = indexPath.row - 1;
            if (index < [[detail getParticipants] count]) {
                Participant *p = (Participant *)[[detail getParticipantsSortedByName] objectAtIndex:index];
                cell = [self getCellForParticipantWithParticipant:p];
                if (indexPath.row == 0) [cell isFirst:YES isLast:NO];
//                else if (detail.currentEventState >= EventStateDecided && index == [[detail getParticipants] count] - 1) [cell isFirst:NO isLast:YES];
                else [cell isFirst:NO isLast:NO];
            } else {
                cell = [self getCellForCallToAction:@"Add friend(s)"];
                if (indexPath.row == 0) [cell isFirst:YES isLast:YES];
                else [cell isFirst:NO isLast:YES];
            }
		} else if ([Model sharedInstance].isInTrial) {
            cell = [self getCellForCallToAction:@"Add friend(s)"];
            if (indexPath.row == 0) [cell isFirst:YES isLast:YES];
            else [cell isFirst:NO isLast:YES];
		}
	}
    return cell;
}

- (BBTableViewCell *)getCellForLocationWithLocation:(Location *)aLocation andIndex:(int)anIndex
{
    CellLocation *cell = (CellLocation *) [self.tableView dequeueReusableCellWithIdentifier:@"LocationTableCellId"];
	if (cell == nil) {
		cell = [[[CellLocation alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LocationTableCellId"] autorelease];
        cell.delegate = self;
	}
    cell.index = anIndex;
    cell.eventState = detail.currentEventState;
    cell.location = aLocation;
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (BBTableViewCell *)getCellForParticipantWithParticipant:(Participant *)aParticipant
{
    CellParticipant *cell = (CellParticipant *) [self.tableView dequeueReusableCellWithIdentifier:@"ParticipantTableCellId"];
    if (cell == nil) {
        cell = [[[CellParticipant alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParticipantTableCellId"] autorelease];
    }
    cell.participant = aParticipant;
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (BBTableViewCell *)getCellForParticipantsSummary
{
    CellParticipantsSummary *cell = (CellParticipantsSummary *) [self.tableView dequeueReusableCellWithIdentifier:@"ParticipantsSummaryTableCellId"];
	if (cell == nil) {
		cell = [[[CellParticipantsSummary alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParticipantsSummaryTableCellId"] autorelease];
	}
    if (otherParticipantsShowing) {
        cell.numParticipants = [detail participantCount];
    } else {
        [cell setParticipants:[detail getParticipantsSortedByName]];
    }
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (BBTableViewCell *)getCellForCallToAction:(NSString *)label
{
    CellEventCallToAction *cell = (CellEventCallToAction *) [self.tableView dequeueReusableCellWithIdentifier:@"ShowHideTableCellId"];
	if (cell == nil) {
		cell = [[[CellEventCallToAction alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowHideTableCellId"] autorelease];
	}
    [cell setTitle:label];
    cell.cellHostView = CellHostViewEvent;
    return cell;
}

- (void)toggleShowHideOtherLocations
{
    otherLocationsShowing = !otherLocationsShowing;
    
    if ([currentSortedLocations count] > 1) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:eventDetailSectionLocations] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    }
}

- (void)toggleShowHideOtherParticipants
{
    otherParticipantsShowing = !otherParticipantsShowing;
    
//    if ([[detail getLocationsSortedByVotes] count] > 1) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:eventDetailSectionParticipants] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
//    }
}


#pragma mark -
#pragma mark SubViewLocationDelegate
- (void)mapButtonPressed:(id)sender
{
    SubViewLocation *svl = (SubViewLocation *)sender;
    Location *loc = svl.location;
    [[ViewController sharedInstance] navigateToAddLocationsWithLocationOpen:loc.locationId];
}

- (void)likeButtonPressed:(id)sender
{
    SubViewLocation *svl = (SubViewLocation *)sender;
    Location *loc = svl.location;
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
    if (![Model sharedInstance].isInTrial) [self.tableView reloadData];
    else {
        [self.tableView reloadData];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(reorderForNonServerVote) withObject:nil afterDelay:0.5];
    }    
}

- (void)unlikeButtonPressed:(id)sender
{
    SubViewLocation *svl = (SubViewLocation *)sender;
    Location *loc = svl.location;
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
    if (![Model sharedInstance].isInTrial) [self.tableView reloadData];
    else {
        [self.tableView reloadData];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(reorderForNonServerVote) withObject:nil afterDelay:0.5];
    }
}

- (void)reorderForNonServerVote
{
    [self populateCurrentSortedLocations];
    if ([self orderDidChange] && otherLocationsShowing) [self reorderCells];
}

#pragma mark - Cell Reordering

- (void)reorderCells
{    
    [self.tableView beginUpdates];
    for (int i=0; i<[currentSortedLocations count]; i++) {
        int toIndex = i;
        int fromIndex = i;
        for (int j=0; j<[oldSortedLocations count]; j++) {
            if ([oldSortedLocations objectAtIndex:j] == [currentSortedLocations objectAtIndex:i]) {
                fromIndex = j;
                break;
            }
        }
        [self reorderCellFromIndex:fromIndex toIndex:toIndex withMovement:YES];
    }
    [oldSortedLocations release];
    oldSortedLocations = [currentSortedLocations copy];
    [self.tableView endUpdates];
     
}

- (void)reorderCellFromIndex:(int)iFrom toIndex:(int)iTo withMovement:(BOOL)move
{    
    if (iFrom == iTo && !move) return;

    NSUInteger fromPath[2] = {0, iFrom};
    NSIndexPath *fromIndexPath = [[NSIndexPath alloc] initWithIndexes:fromPath length:2];
    
    NSUInteger toPath[2] = {0, iTo};
    NSIndexPath *toIndexPath = [[NSIndexPath alloc] initWithIndexes:toPath length:2];
    
    if (!move) [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    else {
        int animType = UITableViewRowAnimationNone;
        int delta = iFrom - iTo;
        
        // Figure out a way to tell if number of votes changed. Only animate if number of votes changed from old to current.
        Location *location = [currentSortedLocations objectAtIndex:iTo];
        Boolean iLikedLocation = [[Model sharedInstance] loginUserDidVoteForLocationWithId:location.locationId inEventWithId:location.ownerEventId];

        if (delta >= 1 && iLikedLocation) animType = UITableViewRowAnimationBottom;
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:animType];
    }

    if (iTo < [oldSortedLocations count]) [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:fromIndexPath] withRowAnimation:UITableViewRowAnimationNone]; //(iTo>iFrom) ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop];
    [fromIndexPath release];
    [toIndexPath release];    
}

#pragma mark -
#pragma mark HeaderViewDetailsEventDelegate

- (void)eventReachedDecided
{   
    otherLocationsShowing = NO;
    otherParticipantsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:eventDetailSectionLocations] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:eventDetailSectionParticipants] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
}

- (void)editEventRequested
{
//    [[ViewController sharedInstance] showModalEditEvent:self];
    [[ViewController sharedInstance] navigateToEditEvent];
}

#pragma mark -
#pragma mark Navigation
- (void)handleHomePress:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // removes all observers for object
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_refreshHeaderView cancelAnimations];
    [[ViewController sharedInstance] goBack];
}

- (void)doGotoMapView 
{
    [[ViewController sharedInstance] navigateToAddLocationsWithEntryState:AddLocationInitStateFromExistingEvent];
}

- (void)doGotoAddView 
{
    [[ViewController sharedInstance] navigateToAddParticipants];
}

- (void)handleMorePress:(id)sender
{
    [self showActionSheetForMorePress];
}


- (void)handleFeedPress:(id)sender
{
//	NSLog(@"handleFeedPress");
    [[ViewController sharedInstance] showModalFeed:self];
    
}

- (void)handleCountMeInPress:(id)sender
{
    NSLog(@"handleCountMeInPress");
    if (pendingCountMeInFetchRequestId != nil) [pendingCountMeInFetchRequestId release];
    pendingCountMeInFetchRequestId = [[[Controller sharedInstance] setEventAcceptanceForEvent:detail didAccept:YES] retain];
}

#pragma mark - UIActionSheet
- (void)showActionSheetForMorePress
{
    
    NSString *title;
    UIActionSheet *userOptions;
    if (detail.currentEventState == EventStateNew)
    {
        currentActionSheetState = ActionSheetStateMorePressEventTrial;
        title = @"Remove this event from your dashboard";
        userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove event", nil];
        userOptions.destructiveButtonIndex = 0;
    }
    else if (detail.currentEventState < EventStateDecided) 
    {
        switch (detail.acceptanceStatus) {
            case AcceptanceTypePending:
                currentActionSheetState = ActionSheetStateMorePressEventVotingPending;
                title = @"Let the group know if you are coming or not, or if there is a better time for you. If you decline the event you will not receive any updates from the group.";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Count me in!", @"I'm not coming", @"Suggest a new time", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 3;
                break;
            case AcceptanceTypeAccepted:
                currentActionSheetState = ActionSheetStateMorePressEventVotingAccepted;
                title = @"Let the group know that you are not going to make it, or if there is a better time for you. If you decline the event you will not receive any updates from the group.";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I'm not coming", @"Suggest a new time", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 2;
                break;
            case AcceptanceTypeDeclined:
                currentActionSheetState = ActionSheetStateMorePressEventVotingDeclined;
                title = @"Let the group know you decided to come, or if there is a better time for you.";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Count me in!", @"Suggest a new time", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 2;
                break;
            default:
                break;
        }
    }
    else if (detail.currentEventState == EventStateDecided)
    {
        switch (detail.acceptanceStatus) {
            case AcceptanceTypePending:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedPending;
                title = @"Let the group know if you are coming or not. If you decline the event you will not receive any updates from the group.";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Count me in!", @"I'm not coming", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 2;
                break;
            case AcceptanceTypeAccepted:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedAccepted;
                title = @"Let the group know that you are not going to make it. If you decline the event you will not receive any updates from the group.";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I'm not coming", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 1;
                break;
            case AcceptanceTypeDeclined:
                currentActionSheetState = ActionSheetStateMorePressEventDecidedDeclined;
                title = @"Let the group know you decided to come!";
                userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Count me in!", @"Remove event", nil];
                userOptions.destructiveButtonIndex = 1;
                break;
            default:
                break;
        }
    }
    else if (detail.currentEventState == EventStateEnded)
    {
        currentActionSheetState = ActionSheetStateMorePressEventEnded;
        title = @"Remove this event from your dashboard, or create a new event with the same group and locations.";
        userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Duplicate event", @"Remove event", nil];
        userOptions.destructiveButtonIndex = 1;
    }
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

- (void)showUserActionSheetForUser:(Participant *)part
{
    currentActionSheetState = ActionSheetStateEmailParticipant;
    NSString *title = [NSString stringWithFormat:@"How would you like to contact %@?", part.fullName];
    UIActionSheet *userOptions = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Email", nil];
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [userOptions showInView:self.view];
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //ActionSheetStateMorePressEventVotingPending, ActionSheetStateMorePressEventVotingDeclined, ActionSheetStateMorePressEventDecidedPending, ActionSheetStateMorePressEventDecidedDeclined - count me in
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending || currentActionSheetState == ActionSheetStateMorePressEventDecidedDeclined)
            {
                if (pendingCountMeInFetchRequestId != nil) [pendingCountMeInFetchRequestId release];
                pendingCountMeInFetchRequestId = [[[Controller sharedInstance] setEventAcceptanceForEvent:detail didAccept:YES] retain];
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventDecidedAccepted - count me out
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventDecidedAccepted)
            {
                if (pendingCountMeInFetchRequestId != nil) [pendingCountMeInFetchRequestId release];
                pendingCountMeInFetchRequestId = [[[Controller sharedInstance] setEventAcceptanceForEvent:detail didAccept:NO] retain];
            }
            else if (currentActionSheetState == ActionSheetStateMorePressEventEnded) // duplicate event
            {
                [[ViewController sharedInstance] showModalDuplicateEvent:self withEvent:detail];
            }
            else if (currentActionSheetState == ActionSheetStateEmailParticipant) // email modal
            {
                [self presentMailModalViewController];
            }
            else if (currentActionSheetState == ActionSheetStateMorePressEventTrial) // email modal
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 1:
            // ActionSheetStateMorePressEventVotingPending, ActionSheetStateMorePressEventDecidedPending - im not coming
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending)
            {
                if (pendingCountMeInFetchRequestId != nil) [pendingCountMeInFetchRequestId release];
                pendingCountMeInFetchRequestId = [[[Controller sharedInstance] setEventAcceptanceForEvent:detail didAccept:NO] retain];
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventVotingDeclined - suggest new time
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined)
            {
                [self pickDateTime];
            }
            // ActionSheetStateMorePressEventDecidedAccepted, ActionSheetStateMorePressEventDecidedDeclined - remove event
            if (currentActionSheetState == ActionSheetStateMorePressEventDecidedAccepted || currentActionSheetState == ActionSheetStateMorePressEventDecidedDeclined || currentActionSheetState == ActionSheetStateMorePressEventEnded)
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 2:
            // ActionSheetStateMorePressEventVotingPending - suggest new time
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending)
            {
                [self pickDateTime];
            }
            // ActionSheetStateMorePressEventVotingAccepted, ActionSheetStateMorePressEventVotingDeclined, ActionSheetStateMorePressEventDecidedPending - remove event
            else if (currentActionSheetState == ActionSheetStateMorePressEventVotingAccepted || currentActionSheetState == ActionSheetStateMorePressEventVotingDeclined || currentActionSheetState == ActionSheetStateMorePressEventDecidedPending)
            {
                [self presentRemoveEventAlert];
            }
            break;
        case 3:
            //ActionSheetStateMorePressEventVotingPending remove event
            if (currentActionSheetState == ActionSheetStateMorePressEventVotingPending)
            {
                [self presentRemoveEventAlert];
            }
            break;   
        default:
            break;
    }
}

- (void)presentRemoveEventAlert
{
    NSLog(@"Present remove event alert");
    NSString *title = @"Remove Event?";
    NSString *message = [NSString stringWithFormat:@"Removing this event will remove it from your dashboard", currentActionSheetState == EventStateEnded ? @"." : @" and \"Count you out\""];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (currentActionSheetState != ActionSheetStateMorePressEventTrial)
        {
            [[Controller sharedInstance] setRemovedForEvent:detail doCountOut:detail.currentEventState <= EventStateDecided];
        }
        detail.hasBeenRemoved = YES;
        [self handleHomePress:self];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewController Methods

- (void)presentMailModalViewController
{
    Model *model = [Model sharedInstance];
    Participant *me = [model getParticipantWithEmail:model.userEmail fromEventWithId:model.currentEvent.eventId];
    NSString *title = @"weego";
    NSString *subject = [NSString stringWithFormat:@"weego message from %@", me.fullName];
    NSString *body = @"";
    NSArray *recipients = [NSArray arrayWithObject:pendingMailParticipant.email];
    
    [[ViewController sharedInstance] showMailModalViewControllerInView:self withTitle:title andSubject:subject andMessageBody:body andToRecipients:recipients];
    pendingMailParticipant = nil;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {    
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark Date Picker Methods

- (void)pickDateTime
{
    if (suggestedDate != nil) [suggestedDate release];
    suggestedDate = [detail.eventDate copy];
    
	SEL changeSelector = @selector(setNewDateTime:);
	int pickerMode = UIDatePickerModeDateAndTime;
    
	dateActionSheet = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerDateToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(datePickerCancelClick:)];
    [barItems addObject:cancelBtn];
    [cancelBtn release];
    
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	[barItems addObject:flexSpace];
    [flexSpace release];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClick:)];
	[barItems addObject:doneBtn];
    [doneBtn release];
    
	
	[pickerDateToolbar setItems:barItems animated:YES];
    [barItems release];
	
	[dateActionSheet addSubview:pickerDateToolbar];
    [pickerDateToolbar release];
	
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 325, 250)];
	datePicker.datePickerMode = pickerMode;
	datePicker.hidden = NO;
    
    int minuteInterval = 5;
    NSDate *now = [NSDate date];
	datePicker.minuteInterval = minuteInterval;
    NSTimeInterval nextAllowedMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / (60 * minuteInterval)) * (60 * minuteInterval); // Current time rounded up to the nearest minuteInterval
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextAllowedMinuteInterval];
    datePicker.minimumDate = minimumDate;
    
	datePicker.date = detail.eventDate;
    
	[datePicker addTarget:self
	               action:changeSelector
	     forControlEvents:UIControlEventValueChanged];
	[dateActionSheet addSubview:datePicker];
	[datePicker release];
	
	[dateActionSheet showInView:self.view];
	[dateActionSheet setBounds:CGRectMake(0,0,320, 464)];
    [dateActionSheet release];
}

- (void)datePickerDoneClick:(id)sender
{
    if ([detail.eventDate compare:suggestedDate] == NSOrderedSame) return; //exit if suggested date is same as current date
    
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSString *suggestedTimeString = [NSDate stringFromDate:suggestedDate withFormat:@"yyyy-MM-dd HH:mm:ss" timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSLog(@"suggestedTimeString: %@", suggestedTimeString);
    [[Controller sharedInstance] suggestTimeForEvent:detail withSuggestedTime:suggestedTimeString];
}

- (void)datePickerCancelClick:(id)sender
{
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

- (void)setNewDateTime:(id)sender
{
    if (suggestedDate != nil) [suggestedDate release];
    suggestedDate = [datePicker.date retain];
    
}

- (void)dealloc {
    NSLog(@"EventDetailTVC dealloc");
    [suggestedDate release];
    [pendingCountMeInFetchRequestId release];
    [self removeDataFetcherMessageListeners];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // removes all observers for object
    [oldSortedLocations release];
    [currentSortedLocations release];
    [super dealloc];
}


@end
