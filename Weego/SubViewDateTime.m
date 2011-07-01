//
//  SubViewDateTime.m
//  BigBaby
//
//  Created by Dave Prukop on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewDateTime.h"
#import "SubViewLabel.h"
#import "BBTextField.h"

@interface SubViewDateTime(Private)

- (void)pickDateTime:(UITextField *)textField;
- (void)datePickerDoneClick:(id)sender;
- (void)changeDateTimeInLabel:(id)sender;
- (void)changeDateInLabel:(id)sender;
- (void)changeTimeInLabel:(id)sender;

@end


@implementation SubViewDateTime

@synthesize eventDate;

- (id)initWithFrame:(CGRect)frame andDate:(NSDate *)aDate {
    
    self = [super initWithFrame:frame];
    if (self) {

        SubViewLabel *dateLabel = [[SubViewLabel alloc] initWithText:@"Date"];
		[self addSubview:dateLabel];
		[dateLabel release];
        
		dateField = [[BBTextField alloc] initWithFrame:CGRectMake(10, 34, 300, 32)];
		dateField.borderStyle = UITextBorderStyleRoundedRect;
		dateField.delegate = self;
		[self addSubview:dateField];
		[dateField release];
        		
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 76);
		
		self.eventDate = aDate;
        [self changeDateTimeInLabel:self];
        
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[self pickDateTime:textField];
	return NO;
}

- (void)pickDateTime:(UITextField *)textField {
	
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
	datePicker.date = self.eventDate;
    
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
	
	[dateActionSheet showInView:self];
	[dateActionSheet setBounds:CGRectMake(0,0,320, 464)];
}

#pragma mark -
#pragma mark Date Picker Methods

- (void)datePickerDoneClick:(id)sender
{
	[dateActionSheet dismissWithClickedButtonIndex:0 animated:YES]; 
}

- (void)changeDateTimeInLabel:(id)sender
{
    if (sender == datePicker) self.eventDate = datePicker.date;
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy h:mm a"];
	NSString *dateString = [format stringFromDate:eventDate];
	[format release];
	dateField.text = dateString;
}

- (void)changeDateInLabel:(id)sender
{
	if (sender == datePicker) self.eventDate = datePicker.date;
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM d, yyyy"];
	NSString *dateString = [format stringFromDate:eventDate];
	[format release];
	dateField.text = dateString;
}

- (void)changeTimeInLabel:(id)sender
{
	if (sender == datePicker) self.eventDate = datePicker.date;
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"h:mm a"];
	NSString *dateString = [format stringFromDate:eventDate];
	[format release];
	timeField.text = dateString;
}

- (void)dealloc {
	[self.eventDate release];
	
    [super dealloc];
}


@end
