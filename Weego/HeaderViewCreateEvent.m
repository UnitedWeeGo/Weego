//
//  HeaderViewCreateEvent.m
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderViewCreateEvent.h"

@interface HeaderViewCreateEvent(Private)

- (void)setUpUI;

@end


@implementation HeaderViewCreateEvent

@synthesize delegate;
@synthesize title, description, date;

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
	nextY = 0.0;
	
	fieldTitle = [[FormTextField alloc] initWithLabel:@"Title" andOriginY:nextY andType:BaseFormInputViewTypeTitle];
	fieldTitle.text = self.title;
	fieldTitle.delegate = self;
	[self addSubview:fieldTitle];
	[fieldTitle release];
	nextY = fieldTitle.frame.origin.y + fieldTitle.frame.size.height;
	
//	fieldDescription = [[FormTextView alloc] initWithLabel:@"Description" andOriginY:nextY andType:BaseFormInputViewTypeNormal];
//	fieldDescription.text = self.description;
//	fieldDescription.delegate = self;
//	[self addSubview:fieldDescription];
//	[fieldDescription release];
//	nextY = fieldDescription.frame.origin.y + fieldDescription.frame.size.height;
	
	viewDateTime = [[SubViewDateTime alloc] initWithFrame:CGRectMake(0, nextY, 320, 44)
												  andDate:self.date];
	[self addSubview:viewDateTime];
	[viewDateTime release];
	nextY = viewDateTime.frame.origin.y + viewDateTime.frame.size.height;
	
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							nextY);
	
}

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)aTitle andDescription:(NSString *)aDescription andDate:(NSDate *)aDate
{
	self.title = aTitle;
	self.description = aDescription;
	self.date = aDate;
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

#pragma mark -
#pragma mark BaseFormInputViewDelegate

- (void)heightDidChange:(UIView *)sender
{
//	nextY = fieldDescription.frame.origin.y + fieldDescription.frame.size.height;
//	[UIView beginAnimations:nil context:nil];
//	viewDateTime.frame = CGRectMake(viewDateTime.frame.origin.x, nextY, viewDateTime.frame.size.width, viewDateTime.frame.size.height);
//	[UIView commitAnimations];
//	
//	nextY = viewDateTime.frame.origin.y + viewDateTime.frame.size.height;
//	self.frame = CGRectMake(self.frame.origin.x, 
//							self.frame.origin.y, 
//							self.frame.size.width, 
//							nextY);
//	[delegate heightDidChange:self];
}

- (void)inputViewDidReturn:(UIView *)sender
{
	[sender resignFirstResponder];
}

- (void)prepareToSave
{
	self.title = fieldTitle.text;
	self.description = nil; //fieldDescription.text;
	self.date = viewDateTime.eventDate;
}

- (void)dealloc {
	self.delegate = nil;
	self.title = nil;
	self.description = nil;
	self.date = nil;
	
    [super dealloc];
}


@end
