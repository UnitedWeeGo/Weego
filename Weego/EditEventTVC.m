//
//  EditEventTVC.m
//  BigBaby
//
//  Created by Dave Prukop on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditEventTVC.h"
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
	numEventDetailSections
} EventDetailSections;

typedef enum {
    createEventFormRowWhat = 0,
    createEventFormRowWhen,
    numCreateEventFormRow
} CreateEventFormRow;

@interface EditEventTVC (Private)

- (BBTableViewCell *)getCellForFormWithLabel:(NSString *)label;
- (void)pickDateTime;
- (void)datePickerDoneClick:(id)sender;
- (void)changeDateTimeInLabel:(id)sender;

@end

@implementation EditEventTVC

@synthesize anotherTitle, anotherDate;

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
	self.title = @"Edit Event";
    
    self.view.backgroundColor = HEXCOLOR(0xF3F3F3FF);
    
    UIView *bevelStripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bevelStripe.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self.view addSubview:bevelStripe];
    [bevelStripe release];
    
    [[NavigationSetter sharedInstance] setNavState:NavStateEventEdit withTarget:self];
    [[NavigationSetter sharedInstance] setToolbarState:ToolbarStateOff withTarget:self withFeedCount:0];
    
	if (detail == nil) detail = [[Model sharedInstance].currentEvent retain];
    self.anotherTitle = detail.eventTitle;
    self.anotherDate = (detail.eventDate) ? detail.eventDate : [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [Model sharedInstance].currentAppState = AppStateEventDetails;
    [Model sharedInstance].currentViewState = ViewStateEdit;
    
    [[ViewController sharedInstance] showDropShadow:self.tableView.contentOffset.y];
    
	[self.tableView reloadData];
}

- (void)handleBackPress:(id)sender
{
    [[ViewController sharedInstance] goBack];
}
- (void)handleRightActionPress:(id)sender
{
    [self setUpDataFetcherMessageListeners];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    detail.eventTitle = self.anotherTitle;
	detail.eventDate = self.anotherDate;
    if (![Model sharedInstance].isInTrial) {
        [[Controller sharedInstance] updateEvent:detail];
    } else {
        [[ViewController sharedInstance] goBack];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == eventDetailSectionEntryForm) {
        if (indexPath.row == createEventFormRowWhat) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CellFormEntry *targetCell = (CellFormEntry *)cell;
            [targetCell becomeFirstResponder];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        } else if (indexPath.row == createEventFormRowWhen) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            CellFormEntry *targetCell = (CellFormEntry *)cell;
            [targetCell resignFirstResponder];
            [self pickDateTime];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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
            targetCell.fieldText = self.anotherTitle;
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

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int a = scrollView.contentOffset.y;
    if (a < 0) a = 0;
    [[ViewController sharedInstance] showDropShadow:a];
}

#pragma mark -
#pragma mark CellFormEntryDelegate

- (void)inputFieldDidReturn:(id)sender
{
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
    CellFormEntry *targetCell = (CellFormEntry *)sender;
    if (targetCell.index == createEventFormRowWhat) {
        self.anotherTitle = targetCell.fieldText;
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
    
    int minuteInterval = 5;
    NSDate *now = [NSDate date];
	datePicker.minuteInterval = minuteInterval;
    NSTimeInterval nextAllowedMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / (60 * minuteInterval)) * (60 * minuteInterval); // Current time rounded up to the nearest minuteInterval
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceReferenceDate:nextAllowedMinuteInterval];
    datePicker.minimumDate = minimumDate;
    
	datePicker.date = self.anotherDate;
    
    
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
    if (sender == datePicker) self.anotherDate = datePicker.date;
    CellFormEntry *targetCell = (CellFormEntry *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:createEventFormRowWhen inSection:eventDetailSectionEntryForm]];
    targetCell.fieldText = [self.anotherDate getWeegoFormattedDateString];
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
        case DataFetchTypeUpdateEvent:
            [self removeDataFetcherMessageListeners];
            [[ViewController sharedInstance] goBack];
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
        case DataFetchTypeUpdateEvent:
            NSLog(@"Unhandled Error: %d",DataFetchTypeUpdateEvent);
            [self removeDataFetcherMessageListeners];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODEL_EVENT_CREATE_EVENT_SUCCESS object:nil];
    [self removeDataFetcherMessageListeners];
	[detail release];
    [self.anotherTitle release];
    [self.anotherDate release];
    [super dealloc];
}


@end
