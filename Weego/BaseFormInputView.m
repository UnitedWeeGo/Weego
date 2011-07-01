//
//  BaseFormInputView.m
//  BigBaby
//
//  Created by Dave Prukop on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseFormInputView.h"
#import "SubViewLabel.h"

@implementation BaseFormInputView

@synthesize delegate;

- (id)initWithLabel:(NSString *)aLabel andOriginY:(CGFloat)yPos andType:(int)type;
{
    self = [super init];
    if (self) {
		nextY = 0.0;
		
		fieldType = type;
		
		SubViewLabel *label = [[SubViewLabel alloc] initWithText:aLabel];
		[self addSubview:label];
		[label release];
		nextY = label.frame.origin.y + label.frame.size.height;
		
		[self setUpUI];
		
		self.frame = CGRectMake(self.frame.origin.x, 
								yPos, 
								320, 
								nextY);
    }
    return self;
}

- (void)setUpUI
{
	// Override in subclass
}

- (void)setText:(NSString *)text
{
	// Override in subclass
}

- (NSString *)text
{
	// Override in subclass
	return nil;
}

//- (BOOL)becomeFirstResponder
//{
//	// Override in subclass
//    return NO;
//}
//
//- (void)resignFirstResponder
//{
//	// Override in subclass
//}

- (void)setTextInputTraitsWithType:(int)type andInputField:(id <UITextInputTraits>)field
{
	switch (type) {
		case BaseFormInputViewTypeNormal:
			field.autocapitalizationType = UITextAutocapitalizationTypeSentences;
			field.autocorrectionType = UITextAutocorrectionTypeDefault;
			field.keyboardType = UIKeyboardTypeDefault;
			break;
		case BaseFormInputViewTypeTitle:
			field.autocapitalizationType = UITextAutocapitalizationTypeWords;
			field.autocorrectionType = UITextAutocorrectionTypeDefault;
			field.keyboardType = UIKeyboardTypeDefault;
			break;
		case BaseFormInputViewTypeName:
			field.autocapitalizationType = UITextAutocapitalizationTypeWords;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.keyboardType = UIKeyboardTypeDefault;
			break;
		case BaseFormInputViewTypeEmail:
			field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.keyboardType = UIKeyboardTypeEmailAddress;
			break;
		case BaseFormInputViewTypePassword:
			field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.secureTextEntry = YES;
			break;

		default:
			break;
	}
}

- (void)dealloc {
	self.delegate = nil;
	
    [super dealloc];
}


@end
