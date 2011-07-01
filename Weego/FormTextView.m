//
//  FormTextView.m
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FormTextView.h"
#import "SubViewLabel.h"

@implementation FormTextView

- (void)setUpUI
{
	bg = [[UITextField alloc] initWithFrame:CGRectMake(10, nextY, 300, 32)];
	bg.borderStyle = UITextBorderStyleRoundedRect;
	bg.enabled = NO;
	[self addSubview:bg];
	[bg release];
	
	textView = [[BBTextView alloc] initWithFrame:CGRectMake(12, nextY-3, 296, 88)];
	textView.font = [UIFont systemFontOfSize:17];
	textView.backgroundColor = [UIColor clearColor];
	textView.scrollEnabled = NO;
	textView.scrollsToTop = NO;
	textView.returnKeyType = UIReturnKeyDone;
	textView.delegate = self;
	//		textView.borderStyle = UITextBorderStyleRoundedRect;
	[self addSubview:textView];
	[textView release];
	
	nextY = bg.frame.origin.y + bg.frame.size.height;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)aTextView {
	NSLog(@"textView.frame.size.height = %0.f : textView.contentSize.height = %0.f", textView.frame.size.height, textView.contentSize.height);
	if (textView.frame.size.height != textView.contentSize.height) {
		int lines = floor((textView.contentSize.height - 16) / 21);
		[UIView beginAnimations:nil context:nil];
		textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.contentSize.height);
		bg.frame = CGRectMake(bg.frame.origin.x, bg.frame.origin.y, bg.frame.size.width, (21*lines)+11);
		[UIView commitAnimations];
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, bg.frame.origin.y + bg.frame.size.height);
		[delegate heightDidChange:self];
	}
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
	}
	return YES;
}

- (void)setText:(NSString *)text
{
	textView.text = text;
	[self textViewDidChange:textView];
}

- (NSString *)text
{
	return textView.text;
}

- (BOOL)becomeFirstResponder
{
	[textView becomeFirstResponder];
    return NO;
}

- (BOOL)resignFirstResponder
{
	[textView resignFirstResponder];
    return NO;
}


- (void)dealloc {
	self.delegate = nil;
	
    [super dealloc];
}


@end
