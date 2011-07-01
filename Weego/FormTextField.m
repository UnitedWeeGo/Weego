//
//  FormTextField.m
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormTextField.h"
#import "SubViewLabel.h"


@implementation FormTextField

- (void)setUpUI
{
	textField = [[BBTextField alloc] initWithFrame:CGRectMake(10, nextY, 300, 32)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	[self setTextInputTraitsWithType:fieldType andInputField:textField];
	[self addSubview:textField];
	[textField release];
	
	nextY = textField.frame.origin.y + textField.frame.size.height;
}

- (void)setText:(NSString *)text
{
	textField.text = text;
}

- (NSString *)text
{
	return textField.text;
}

- (BOOL)becomeFirstResponder
{
	[textField becomeFirstResponder];
    return NO;
}

- (BOOL)resignFirstResponder
{
	[textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
	[delegate inputViewDidReturn:self];
	return NO;
}

- (void)dealloc {	
    [super dealloc];
}


@end
