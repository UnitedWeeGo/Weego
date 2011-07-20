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

- (void)doGotoMapView;
- (void)doGotoAddView;
- (BBTableViewCell *)getCellForFormWithLabel:(NSString *)label;
- (BBTableViewCell *)getCellForLocationWithLocation:(Location *)aLocation andIndex:(int)anIndex;
- (BBTableViewCell *)getCellForParticipantWithParticipant:(Participant *)aParticipant;
- (BBTableViewCell *)getCellForCallToAction:(NSString *)label;
- (void)pickDateTime;
- (void)datePickerDoneClick:(id)sender;
- (void)changeDateTimeInLabel:(id)sender;

@end

@implementation CreateEventTVC

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
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
    NSLog(@"detail.eventId = %@", detail.eventId);
    
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
    
    [Model sharedInstance].currentAppState = AppStateCreateEvent;
    [Model sharedInstance].currentViewState = ViewStateCreate;
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    [[NavigationSetter sharedInstance] setNavState:NavStateEventCreateEvent withTarget:self];
    
	[self.tableView reloadData];
    
    [self setUpDataFetcherMessageListeners];
    
    [[Model sharedInstance] printModel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeDataFetcherMessageListeners];
}

- (void)handleLeftActionPress:(id)sender
{
    Controller *controller = [Controller sharedInstance];
    [controller removeEvent];
	[[ViewController sharedInstance] dismissModal:self];
}

- (void)handleRightActionPress:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
    CellFormEntry *targetCell = (CellFormEntry *)cell;
    [targetCell resignFirstResponder];
    _saving = YES;
	[_refreshHeaderView refreshLastUpdatedDate];
    _refreshHeaderView.hidden = NO;
    [_refreshHeaderView egoRefreshScrollViewOpenAndShowSaving:self.tableView];
    Controller *controller = [Controller sharedInstance];
	[controller addEvent:detail];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eventDetailSectionLocations)
    {
        if ([[detail getLocations] count] > 0 && indexPath.row != [[detail getLocations] count])
        {
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
        Location *loc = (Location *)[[detail getLocations] objectAtIndex:indexPath.row];
        NSLog(@"Delete: %@", loc.name);
        [[Controller sharedInstance] removeLocationWithId:loc.locationId];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == eventDetailSectionEntryForm) {
        if (indexPath.row == createEventFormRowWhat) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CellFormEntry *targetCell = (CellFormEntry *)cell;
            [targetCell becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        } else if (indexPath.row == createEventFormRowWhen) {
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
//            CellFormEntry *targetCell = (CellFormEntry *)cell;
//            [targetCell resignFirstResponder];
            [[self.tableView superview] endEditing:YES];
            [self pickDateTime];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    } else if (indexPath.section == eventDetailSectionLocations) {
		if (indexPath.row == [[detail getLocations] count]) {
//            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
//            CellFormEntry *targetCell = (CellFormEntry *)cell;
//            [targetCell resignFirstResponder];
            [[self.tableView superview] endEditing:YES];
			[self doGotoMapView];
		}
	} else if (indexPath.section == eventDetailSectionParticipants) {
        if (![Model sharedInstance].isInTrial) {
            if (indexPath.row == [[detail getParticipants] count]) {
//                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
//                CellFormEntry *targetCell = (CellFormEntry *)cell;
//                [targetCell resignFirstResponder];
                [[self.tableView superview] endEditing:YES];
                [self doGotoAddView];
            }
        } else {
            if (indexPath.row == 0) {
//                UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhat inSection:eventDetailSectionEntryForm]];
//                CellFormEntry *targetCell = (CellFormEntry *)cell;
//                [targetCell resignFirstResponder];
                [[self.tableView superview] endEditing:YES];
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
        if (indexPath.row == [[detail getLocations] count]) return CellEventCallToActionHeight;
        else return CellLocationHeight;
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
	if (section == eventDetailSectionLocations) numRows += [[detail getLocations] count];
	if (section == eventDetailSectionParticipants && ![Model sharedInstance].isInTrial) {
        NSLog(@"Number of participants = %i", [[detail getParticipants] count]);
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
		if (indexPath.row < [[detail getLocations] count]) {
            Location *loc = (Location *)[[detail getLocationsByLocationOrder:detail.currentLocationOrder] objectAtIndex:indexPath.row];
			cell = [self getCellForLocationWithLocation:loc andIndex:indexPath.row];			
            if (indexPath.row == 0) [cell isFirst:YES isLast:NO];
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
    CellFormEntry *cell = (CellFormEntry *) [self.tableView dequeueReusableCellWithIdentifier:@"FormTableCellId"];
    if (cell == nil) {
        cell = [[[CellFormEntry alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormTableCellId"] autorelease];
    }
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
    [controller voteForLocationWithId:loc.locationId];
    [self.tableView reloadData];
}

- (void)unlikeButtonPressed:(id)sender
{
    SubViewLocation *svl = (SubViewLocation *)sender;
    Location *loc = svl.location;
    Controller *controller = [Controller sharedInstance];
    [controller removeVoteForLocationWithId:loc.locationId];
    [self.tableView reloadData];
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
            NSLog(@"DataFetchTypeCreateNewEvent Success");
            _saving = NO;
            [[ViewController sharedInstance] dismissModal:self];
            break;
        case DataFetchTypeLoginWithFacebookAccessToken:
            [Model sharedInstance].currentEvent = detail;
            [[Model sharedInstance] replaceTrialParticipantsWithLoginParticipant];
            [[ViewController sharedInstance] hideFacebookPopupWithAnimation:NO];
            [Model sharedInstance].isInTrial = NO;
            [Model sharedInstance].loginAfterTrial = YES;
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
    switch (fetchType) {
        case DataFetchTypeCreateNewEvent:
            NSLog(@"DataFetchTypeCreateNewEvent Error");
            if (_saving) {
                [_refreshHeaderView egoRefreshScrollViewShowError:self.tableView];
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
    [self removeDataFetcherMessageListeners];
    [detail release];
    [super dealloc];
}


@end
