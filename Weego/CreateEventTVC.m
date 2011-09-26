//
//  CreateEventTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateEventTVC.h"
#import "Model.h"
#import "Controller.h"
#import "ViewController.h"
#import "Event.h"
#import "Location.h"
#import "Participant.h"
#import "HeaderViewCreateEvent.h"
#import "SubViewLabel.h"
#import "CellLocation.h"
#import "CellParticipant.h"
#import "CellEventCallToAction.h"
#import "BBTableViewCell.h"

typedef enum {
    eventDetailSectionEntryForm = 0,
	eventDetailSectionLocations,
	eventDetailSectionParticipants,
	numEventDetailSections
} EventDetailSections;

typedef enum {
    createEventFormRowWhat = 0,
    createEventFormRowWhen,
    numCreateEventFormRow
} CreateEventFormRow;

@interface CreateEventTVC (Private)

- (void)populateCurrentSortedLocations;
- (BOOL)orderDidChange;
- (void)reorderCells;
- (void)reorderCellFromIndex:(int)iFrom toIndex:(int)iTo withMovement:(BOOL)move;
- (void)doGotoMapView;
- (void)doGotoAddView;
- (BBTableViewCell *)getCellForFormWithLabel:(NSString *)label;
- (BBTableViewCell *)getCellForLocationWithLocation:(Location *)aLocation andIndex:(int)anIndex;
- (BBTableViewCell *)getCellForParticipantWithParticipant:(Participant *)aParticipant;
- (BBTableViewCell *)getCellForCallToAction:(NSString *)label;
- (void)pickDateTime;
- (void)datePickerDoneClick:(id)sender;
- (void)changeDateTimeInLabel:(id)sender;
- (void)handleRightActionPress:(id)sender;

@end

@implementation CreateEventTVC

@synthesize isInDuplicate, eventId;

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)setEventId:(NSString *)anEventId
{
    [detail release];
    detail = [[Model sharedInstance] duplicateEventWithId:anEventId];
    [detail retain];
}

- (void)viewDidLoad
{
	self.title = @"Create Event";
        
    self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.view addSubview:bevelStripe];
    [bevelStripe release];
        
//    [[NavigationSetter sharedInstance] setNavState:NavStateEventCreateEvent withTarget:self];
    
	if (detail == nil) {
        detail = [[[Model sharedInstance] createNewEvent] retain];
    }
    
    placeholderText = [[NSMutableString alloc] initWithString:[Model sharedInstance].loginParticipant.firstNamePossessive];
    [placeholderText appendString:@" Event"];
    
    [Model sharedInstance].currentBGState = BGStateEvent;
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [self.tableView addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
	_refreshHeaderView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    
    if (isInDuplicate) {
//        [Model sharedInstance].currentAppState = AppStateDuplicateEvent;
//        [Model sharedInstance].currentViewState = ViewStateDuplicate;
        [Model sharedInstance].currentAppState = AppStateCreateEvent;
        [Model sharedInstance].currentViewState = ViewStateCreate;
        [[NavigationSetter sharedInstance] setNavState:NavStateEventDuplicateEvent withTarget:self];
    } else {
        [Model sharedInstance].currentAppState = AppStateCreateEvent;
        [Model sharedInstance].currentViewState = ViewStateCreate;
        [[NavigationSetter sharedInstance] setNavState:NavStateEventCreateEvent withTarget:self];
    }
    
    [self.view endEditing:YES];
    
    [self setUpDataFetcherMessageListeners];
    
    [self populateCurrentSortedLocations];
    [oldSortedLocations release];
    oldSortedLocations = [currentSortedLocations copy];
    
    [self.tableView reloadData];
    
    //[[Model sharedInstance] printModel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeDataFetcherMessageListeners];
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)handleLeftActionPress:(id)sender
{
    Controller *controller = [Controller sharedInstance];
    [controller removeEvent];
    [[ViewController sharedInstance] dismissDuplicateEventModalAndReturnToDashboard:self];
//	[[ViewController sharedInstance] dismissModal:self];
}

- (void)handleRightActionPress:(id)sender
{
    if (!eventDateAdjusted)
    {
        NSString *message = [NSString stringWithFormat:@"You selected %@ for the event time. Is this ok?", [detail getFormattedDateString]];
        UIAlertView *noTimeChangeWarning = [[UIAlertView alloc] initWithTitle:@"Just checking" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes!", nil];
        [noTimeChangeWarning show];
        [noTimeChangeWarning release];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
    CellFormEntry *targetCell = (CellFormEntry *)cell;
    [targetCell resignFirstResponder];
    if (detail.eventTitle == nil || [[detail.eventTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        detail.eventTitle = [NSString stringWithFormat:@"%@ Event", [Model sharedInstance].loginParticipant.firstNamePossessive];
    }
    if (![Model sharedInstance].isInTrial) {
        _saving = YES;
        [_refreshHeaderView refreshLastUpdatedDate];
        _refreshHeaderView.hidden = NO;
        [_refreshHeaderView egoRefreshScrollViewOpenAndShowSaving:self.tableView];
        Controller *controller = [Controller sharedInstance];
        [controller addEvent:detail];
    } else {
        [[ViewController sharedInstance] dismissModal:self];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        eventDateAdjusted = YES;
        [self handleRightActionPress:self];
    }
}

- (void)populateCurrentSortedLocations
{
    if (currentSortedLocations != nil) {
        [oldSortedLocations release];
        oldSortedLocations = [currentSortedLocations copy];
    }
    [currentSortedLocations release];
    currentSortedLocations = [[NSArray alloc] initWithArray:[detail getLocationsByLocationOrder:detail.currentLocationOrder]];
    if (oldSortedLocations == nil) {
        [oldSortedLocations release];
        oldSortedLocations = [currentSortedLocations copy];
    }
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
    if (indexPath.section == eventDetailSectionLocations) {
        if ([currentSortedLocations count] > 0 && indexPath.row != [currentSortedLocations count]) {
            return YES;
        }
    } else if (indexPath.section == eventDetailSectionParticipants) {
        if ([detail.getParticipants count] > 0 && indexPath.row != [detail.getParticipants count] && indexPath.row != 0) {
            return YES;
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
        if (indexPath.section == eventDetailSectionLocations) {
            Location *loc = (Location *)[currentSortedLocations objectAtIndex:indexPath.row];
            [[Controller sharedInstance] removeLocationWithId:loc.locationId];
            [self populateCurrentSortedLocations];
            [oldSortedLocations release];
            oldSortedLocations = [currentSortedLocations copy];
            [self.tableView reloadData];
        } else if (indexPath.section == eventDetailSectionParticipants) {
            [[Model sharedInstance] removeParticipantWithEmail:((Participant *)[detail.getParticipantsSortedByName objectAtIndex:indexPath.row]).email fromEventWithId:detail.eventId];
            [self.tableView reloadData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == eventDetailSectionEntryForm) {
        if (indexPath.row == createEventFormRowWhat) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CellFormEntry *targetCell = (CellFormEntry *)cell;
            [targetCell becomeFirstResponder];
        } else if (indexPath.row == createEventFormRowWhen) {
            [self.view endEditing:YES];
            [self pickDateTime];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row == rowsForLocations-1) {
            [self.view endEditing:YES];
			[self doGotoMapView];
		}
	} else if (indexPath.section == eventDetailSectionParticipants) {
        if (![Model sharedInstance].isInTrial) {
            if (indexPath.row == [[detail getParticipants] count]) {
                [self.view endEditing:YES];
                [self doGotoAddView];
            }
        } else {
            if (indexPath.row == 0) {
                [self.view endEditing:YES];
                [[ViewController sharedInstance] showFacebookPopup];
            }
        }
	}
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 14.0;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	float headerHeight = 44;
//	return headerHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eventDetailSectionLocations) {
//        if (indexPath.row == [[detail getLocations] count]) return CellEventCallToActionHeight;
//        else return CellLocationHeight;
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
	int numRows = 1;
    if (section == eventDetailSectionEntryForm) numRows = numCreateEventFormRow;
	if (section == eventDetailSectionLocations) {
        numRows += [oldSortedLocations count];
        rowsForLocations = numRows;
    }
	if (section == eventDetailSectionParticipants && ![Model sharedInstance].isInTrial) {
        numRows += [[detail getParticipants] count];
    }
	return numRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BBTableViewCell *cell = nil;
    if (indexPath.section == eventDetailSectionEntryForm) {
        if (indexPath.row == createEventFormRowWhat) {
            CellFormEntry *targetCell = (CellFormEntry *)[self getCellForFormWithLabel:@"What"];
            [targetCell isFirst:YES isLast:NO];
            targetCell.index = createEventFormRowWhat;
            targetCell.placeholder = placeholderText;
            targetCell.fieldText = detail.eventTitle;
            [targetCell setEntryType:CellFormEntryTypeName];
            [targetCell setReturnKeyType:UIReturnKeyNext];
            cell = targetCell;
        } else if (indexPath.row == createEventFormRowWhen) {
            CellFormEntry *targetCell = (CellFormEntry *)[self getCellForFormWithLabel:@"When"];
            [targetCell isFirst:NO isLast:YES];
            targetCell.index = createEventFormRowWhen;
            targetCell.fieldText = [detail getFormattedDateString];
            [targetCell setEntryType:CellFormEntryTypePrevent];
//            [targetCell setReturnKeyType:UIReturnKeyNext];
            cell = targetCell;
        }
    } else if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row < rowsForLocations-1) {
            Location *loc = (Location *)[oldSortedLocations objectAtIndex:indexPath.row];
			cell = [self getCellForLocationWithLocation:loc andIndex:indexPath.row];			
            if (indexPath.row == 0 && rowsForLocations > 1) [cell isFirst:YES isLast:NO];
            else [cell isFirst:NO isLast:NO];
		} else {
            cell = [self getCellForCallToAction:@"Add location(s)"];
            if (indexPath.row == 0) [cell isFirst:YES isLast:YES];
            else [cell isFirst:NO isLast:YES];
		}
	} else if (indexPath.section == eventDetailSectionParticipants) {
		if (indexPath.row < [[detail getParticipants] count] && ![Model sharedInstance].isInTrial) {
			Participant *p = (Participant *)[[detail getParticipantsSortedByName] objectAtIndex:indexPath.row];
            cell = [self getCellForParticipantWithParticipant:p];
            if (indexPath.row == 0) [cell isFirst:YES isLast:NO];
            else [cell isFirst:NO isLast:NO];
		} else {
            cell = [self getCellForCallToAction:@"Add friend(s)"];
            if (indexPath.row == 0) [cell isFirst:YES isLast:YES];
            else [cell isFirst:NO isLast:YES];
		}
	}
    return cell;
}

- (BBTableViewCell *)getCellForFormWithLabel:(NSString *)label
{
//    CellFormEntry *cell = (CellFormEntry *) [self.tableView dequeueReusableCellWithIdentifier:@"FormTableCellId"];
//    if (cell == nil) {
//        cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormTableCellId"] autorelease];
//    }
    CellFormEntry *cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormTableCellId"] autorelease];
    [cell setTitle:label];
    cell.cellHostView = CellHostViewEvent;
    cell.delegate = self;
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

//#pragma mark -
//#pragma mark SubViewLocationDelegate
//- (void)mapButtonPressed:(id)sender
//{
//    SubViewLocation *svl = (SubViewLocation *)sender;
//    Location *loc = svl.location;
//    [[ViewController sharedInstance] navigateToAddLocationsWithLocationOpen:loc.locationId];    
//}
//
//- (void)likeButtonPressed:(id)sender
//{
//    SubViewLocation *svl = (SubViewLocation *)sender;
//    Location *loc = svl.location;
//    Controller *controller = [Controller sharedInstance];
//    [controller voteForLocationWithId:loc.locationId];
//    [self.tableView reloadData];
//}
//
//- (void)unlikeButtonPressed:(id)sender
//{
//    SubViewLocation *svl = (SubViewLocation *)sender;
//    Location *loc = svl.location;
//    Controller *controller = [Controller sharedInstance];
//    [controller removeVoteForLocationWithId:loc.locationId];
//    [self.tableView reloadData];
//}

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
    [self.tableView reloadData];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(reorderForNonServerVote) withObject:nil afterDelay:0.5];
}

- (void)unlikeButtonPressed:(id)sender
{
    SubViewLocation *svl = (SubViewLocation *)sender;
    Location *loc = svl.location;
    Controller *controller = [Controller sharedInstance];
    [controller toggleVoteForLocationsWithId:loc.locationId];
    [self.tableView reloadData];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(reorderForNonServerVote) withObject:nil afterDelay:0.5];
}

- (void)reorderForNonServerVote
{
    [self populateCurrentSortedLocations];
    if ([self orderDidChange]) [self reorderCells];
}

#pragma mark - Cell Reordering

- (void)reorderCells
{    
    @try {
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
    @catch (NSException *exception) {
        NSLog(@"- (void)reorderCells: crash");
        [self.tableView reloadData];
    }
}

- (void)reorderCellFromIndex:(int)iFrom toIndex:(int)iTo withMovement:(BOOL)move
{    
    if (iFrom == iTo && !move) return;
    
    NSUInteger fromPath[2] = {1, iFrom};
    NSIndexPath *fromIndexPath = [[NSIndexPath alloc] initWithIndexes:fromPath length:2];
    
    NSUInteger toPath[2] = {1, iTo};
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
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int a = scrollView.contentOffset.y;
    if (a < 0 && !_saving) a = 0;
    [[ViewController sharedInstance] showDropShadow:a];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	_saving = YES;
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _saving; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (void)egoRefreshTableHeaderClosed
{
    _refreshHeaderView.hidden = YES;
}

#pragma mark -
#pragma mark CellFormEntryDelegate

- (void)inputFieldDidReturn:(id)sender
{
//    NSLog(@"inputFieldDidReturn");
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    if (targetCell.index == createEventFormRowWhat)
    {
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:targetCell.index+1 inSection:eventDetailSectionEntryForm];
        [targetCell resignFirstResponder];
        [self pickDateTime];
        [self.tableView scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)handleDirectFieldTouch:(id)sender
{
//    NSLog(@"handleDirectFieldTouch");
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:eventDetailSectionEntryForm];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)inputFieldDidChange:(id)sender
{
//    NSLog(@"inputFieldDidChange");
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    if (targetCell.index == createEventFormRowWhat) {
        detail.eventTitle = targetCell.fieldText;
        NSIndexPath *path = [NSIndexPath indexPathForRow:targetCell.index inSection:eventDetailSectionEntryForm];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark -
#pragma mark Date Picker Methods

- (void)pickDateTime
{
	SEL changeSelector = @selector(changeDateTimeInLabel:);
	int pickerMode = UIDatePickerModeDateAndTime;
    
	dateActionSheet = [[UIActionSheet alloc] initWithTitle:@"Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	UIToolbar *pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
	[pickerDateToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
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
	datePicker.date = detail.eventDate;
    
    int minuteInterval = 5;
    NSDate *now = [NSDate date];
	datePicker.minuteInterval = minuteInterval;
    NSTimeInterval nextAllowedMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / (60 * minuteInterval)) * (60 * minuteInterval); // Current time rounded up to the nearest minuteInterval
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextAllowedMinuteInterval];
    datePicker.minimumDate = minimumDate;
    
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
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

- (void)changeDateTimeInLabel:(id)sender
{
    if (sender == datePicker) detail.eventDate = datePicker.date;
    CellFormEntry *targetCell = (CellFormEntry *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhen inSection:eventDetailSectionEntryForm]];
    targetCell.fieldText = [detail getFormattedDateString];
    eventDateAdjusted = YES;
}

#pragma mark -
#pragma mark Navigation

- (void)doGotoMapView 
{
    [[ViewController sharedInstance] navigateToAddLocationsWithEntryState:AddLocationInitStateFromNewEvent];
}

- (void)doGotoAddView 
{
    [[ViewController sharedInstance] navigateToAddParticipants];
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
        case DataFetchTypeCreateNewEvent:
            //NSLog(@"DataFetchTypeCreateNewEvent Success");
            _saving = NO;
            [[Model sharedInstance] flushTempItems];
            if (isInDuplicate) {
                [[ViewController sharedInstance] dismissDuplicateEventModalAndReturnToDashboard:self];
            } else {
                [[ViewController sharedInstance] dismissDuplicateEventModalAndReturnToDashboard:self];
//                [[ViewController sharedInstance] dismissModal:self];
            }
            break;
        case DataFetchTypeLoginWithFacebookAccessToken:
            if (![Model sharedInstance].loginDidFail) {
                [Model sharedInstance].currentEvent = detail;
                [[Model sharedInstance] replaceTrialParticipantsWithLoginParticipant];
                [[ViewController sharedInstance] hideFacebookPopupWithAnimation:NO];
                [Model sharedInstance].isInTrial = NO;
                [Model sharedInstance].loginAfterTrial = YES;
            }
            [self.tableView reloadData];
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
        case DataFetchTypeCreateNewEvent:
            NSLog(@"DataFetchTypeCreateNewEvent Error");
            if (_saving) {
                [_refreshHeaderView egoRefreshScrollViewShowError:self.tableView withCode:errorType];
                _saving = NO;
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            break;
        
        default:
            break;
    }
}

- (void)dealloc {
    NSLog(@"CreateEventTVC dealloc");
    [_refreshHeaderView cancelAnimations];
    [self removeDataFetcherMessageListeners];
    [currentSortedLocations release];
    [oldSortedLocations release];
    [detail release];
    [placeholderText release];
    [super dealloc];
}


@end
