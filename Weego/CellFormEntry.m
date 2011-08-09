//
//  CellFormEntry.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellFormEntry.h"

@interface CellFormEntry(Private)

- (void)initUI;
- (void)setTextInputTraitsWithType:(int)type andInputField:(id <UITextInputTraits>)field;

@end;

@implementation CellFormEntry

@synthesize index;
@synthesize delegate;
@synthesize placeholder;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nonEditingFieldFrame = CGRectMake(111, 16, 185, 16);
        isEditingFieldFrame = CGRectMake(111, 15, 185, 16);
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *titleLabelColor = nil;
    UIColor *entryLabelColor = nil;
    titleLabelColor = HEXCOLOR(0x666666FF);
    entryLabelColor = HEXCOLOR(0x333333FF);

    fieldTitle = [[[UILabel alloc] initWithFrame:CGRectMake(20, 17, 80, 16)] autorelease];
	fieldTitle.textColor = titleLabelColor;
	fieldTitle.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	fieldTitle.backgroundColor = [ UIColor clearColor ]; 
	fieldTitle.lineBreakMode = UILineBreakModeTailTruncation;
	fieldTitle.numberOfLines = 0;
	[self addSubview:fieldTitle];
    
    
    if (inputField == nil) inputField = [[[UITextField alloc] initWithFrame:nonEditingFieldFrame] autorelease];
    inputField.textColor = entryLabelColor;
    inputField.borderStyle = UITextBorderStyleNone;
	inputField.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	inputField.backgroundColor = [ UIColor clearColor ]; 
    inputField.delegate = self;
	[self addSubview:inputField];
    
    self.frame = CGRectMake(0, 0, 300, CellFormEntryHeight);
}

- (void)setTitle:(NSString *)title
{
    fieldTitle.text = title;
}

- (void)setFieldText:(NSString *)text
{
	inputField.text = text;
    [localText release];
    localText = text;
    [localText retain];
}

- (NSString *)fieldText
{
    NSString *evalStr = localText;
	return [evalStr length] > 0 ? localText : @"";
}

- (void)setEntryType:(CellFormEntryType)type
{
    [self setTextInputTraitsWithType:type andInputField:inputField];
}

- (void)setTextInputTraitsWithType:(int)type andInputField:(id <UITextInputTraits>)field
{
	switch (type) {
		case CellFormEntryTypeNormal:
			field.autocapitalizationType = UITextAutocapitalizationTypeSentences;
			field.autocorrectionType = UITextAutocorrectionTypeDefault;
			field.keyboardType = UIKeyboardTypeDefault;
			break;
		case CellFormEntryTypePhone:
			field.autocapitalizationType = UITextAutocapitalizationTypeWords;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.keyboardType = UIKeyboardTypePhonePad;
			break;
		case CellFormEntryTypeName:
			field.autocapitalizationType = UITextAutocapitalizationTypeWords;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.keyboardType = UIKeyboardTypeDefault;
            break;
		case CellFormEntryTypeEmail:
			field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.keyboardType = UIKeyboardTypeEmailAddress;
			break;
		case CellFormEntryTypePassword:
			field.autocapitalizationType = UITextAutocapitalizationTypeNone;
			field.autocorrectionType = UITextAutocorrectionTypeNo;
			field.secureTextEntry = YES;
			break;
        case CellFormEntryTypePrevent:
            inputField.enabled = NO;
            break;
		default:
			break;
	}
}

- (void)setReturnKeyType:(UIReturnKeyType)type
{
   inputField.returnKeyType = type; 
}

- (BOOL)becomeFirstResponder
{
	[inputField becomeFirstResponder];
    return NO;
}

- (BOOL)resignFirstResponder
{
	[inputField resignFirstResponder];
    return NO;
}

- (UITextField *)field
{
    return inputField;
}

- (void)setPlaceholder:(NSString *)aPlaceholder
{
//    [placeholderText release];
    placeholderText = aPlaceholder;
//    [placeholderText retain];
    inputField.placeholder = aPlaceholder;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
	[delegate inputFieldDidReturn:self];
	return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    inputField.frame = isEditingFieldFrame;
    inputField.placeholder = @"";
    [delegate handleDirectFieldTouch:self];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([[inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        inputField.placeholder = placeholderText;
    }
    inputField.frame = nonEditingFieldFrame;
    if ([delegate respondsToSelector:@selector(inputFieldDidEndEditing:)]) [delegate inputFieldDidEndEditing:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [localText release];
    localText = [inputField.text stringByReplacingCharactersInRange:range withString:string];
    [localText retain];
    if ([delegate respondsToSelector:@selector(inputFieldDidChange:)]) [delegate inputFieldDidChange:self];
    return YES;
}

- (void)dealloc
{
    NSLog(@"CellFormEntry dealloc");
    inputField.delegate = nil;
    [inputField resignFirstResponder];
    [localText release];
    [super dealloc];
}
@end
