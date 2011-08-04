//
//  SubViewContactsSearchBar.m
//  Weego
//
//  Created by Dave Prukop on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewSearchBar.h"

@interface SubViewSearchBar (Private)

- (void)setUpUI;
- (void)showClearButton:(BOOL)shouldShowButton;
- (void)clearTextRequested;
- (void)addressBookRequested;
- (void)cancelRequested;
- (void)bgButtonPressed;

@end

@implementation SubViewSearchBar

@synthesize delegate, placeholderText;

- (void)dealloc
{
    self.placeholderText = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nonEditingFieldOrigin = CGPointMake(35, 13);
        isEditingFieldOrigin = CGPointMake(35, 12);
        nonEditingFieldSize = CGSizeMake(220, 16);
        isEditingFieldSize = CGSizeMake(180, 16);
        nonEditingBgFrame = CGRectMake(5, 0, 310, self.frame.size.height);
        isEditingBgFrame = CGRectMake(5, 0, 240, self.frame.size.height);
        nonEditingCancelFrame = CGRectMake(self.frame.size.width, 4, 60, 32);
        isEditingCancelFrame = CGRectMake(self.frame.size.width - 65, 4, 60, 32);
        nonEditingBgButtonFrame = CGRectMake(5, 0, 265, self.frame.size.height);
        isEditingBgButtonFrame = CGRectMake(5, 0, 205, self.frame.size.height);
        
        self.placeholderText = @"";
        localText = @"";
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    UIImage *bgImage = [UIImage imageNamed:@"searchBar_bg.png"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
    bgImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:bgImageView];
    [bgImageView release];
    
    
    UIImage *fieldBgImage = [[UIImage imageNamed:@"searchBarField_bg.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0];
    fieldBgImageView = [[UIImageView alloc] initWithImage:fieldBgImage];
    fieldBgImageView.frame = CGRectMake(5, 0, 310, self.frame.size.height);
    [self addSubview:fieldBgImageView];
    [fieldBgImageView release];
    
    fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fieldButton setBackgroundColor:[UIColor clearColor]];
    fieldButton.frame = nonEditingBgButtonFrame;
    [fieldButton addTarget:self action:@selector(bgButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:fieldButton];
    
    UIImage *fieldIconImage = [UIImage imageNamed:@"searchBar_icon.png"];
    UIImageView *fieldIconImageView = [[UIImageView alloc] initWithImage:fieldIconImage];
    fieldIconImageView.frame = CGRectMake(10, 12, fieldIconImage.size.width, fieldIconImage.size.height);
    [fieldButton addSubview:fieldIconImageView];
    [fieldIconImageView release];
    
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(nonEditingFieldOrigin.x, nonEditingFieldOrigin.y, nonEditingFieldSize.width, nonEditingFieldSize.height)];
    searchField.textColor = HEXCOLOR(0x333333FF);
	searchField.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
	searchField.backgroundColor = [UIColor clearColor];
    searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.keyboardType = UIKeyboardTypeEmailAddress;
    searchField.delegate = self;
    searchField.placeholder = self.placeholderText;
	[self addSubview:searchField];
    
    buttonClear = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *iconClearButton = [UIImage imageNamed:@"icon_clearTextField_01.png"];
    [buttonClear setImage:iconClearButton forState:UIControlStateNormal];
    buttonClear.frame = CGRectMake(searchField.frame.origin.x + searchField.frame.size.width, 4, 32, 32);
    [buttonClear addTarget:self action:@selector(clearTextRequested) forControlEvents:UIControlEventTouchUpInside];
    buttonClear.hidden = YES;
    [self addSubview:buttonClear];
    
    buttonAddressBook = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *iconAddressBook = [UIImage imageNamed:@"searchBar_bookmark_icon.png"];
    [buttonAddressBook setImage:iconAddressBook forState:UIControlStateNormal];
    buttonAddressBook.frame = CGRectMake(277, 4, 36, 32);
    [buttonAddressBook addTarget:self action:@selector(addressBookRequested) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonAddressBook];
    
    UIImage *bg1 = [UIImage imageNamed:@"button_clear_default.png"];
    UIImage *bg2 = [UIImage imageNamed:@"button_clear_pressed.png"];
    CGRect buttonTargetSize = nonEditingCancelFrame;
    buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCancel.adjustsImageWhenHighlighted = NO;
    [buttonCancel setFrame:buttonTargetSize];
    [buttonCancel addTarget:self action:@selector(cancelRequested) forControlEvents:UIControlEventTouchUpInside];
    [buttonCancel setBackgroundImage:bg1 forState:UIControlStateNormal];
    [buttonCancel setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    [buttonCancel setBackgroundImage:bg2 forState:UIControlStateDisabled];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    buttonCancel.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    UIColor *col = HEXCOLOR(0x333333FF);    
    [buttonCancel setTitleColor:col forState:UIControlStateNormal];
    buttonCancel.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    buttonCancel.titleLabel.lineBreakMode = UILineBreakModeClip;
//    UIColor *shadowColor = HEXCOLOR(0x33333333);
//    buttonCancel.titleLabel.shadowColor = shadowColor;
//    buttonCancel.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    buttonCancel.alpha = 0;
    [self addSubview:buttonCancel];

}

- (void)setPlaceholderText:(NSString *)text
{
    if (placeholderText) [placeholderText release];
    placeholderText = [text retain];
    searchField.placeholder = placeholderText;
}

- (NSString *)text
{
    return localText;
}

- (void)resetField
{
    [self clearTextRequested];
    [searchField resignFirstResponder];
}

- (void)showError:(BOOL)shouldShowError
{
    UIColor *normalColor = HEXCOLOR(0x333333FF);
    UIColor *errorColor = HEXCOLOR(0xFF0000FF);
    searchField.textColor = (shouldShowError) ? errorColor : normalColor;
}

#pragma mark - Private Methods

- (void)showClearButton:(BOOL)shouldShowButton
{
    buttonClear.frame = CGRectMake(searchField.frame.origin.x + searchField.frame.size.width, 4, 32, 32);
    buttonClear.hidden = !shouldShowButton;
}

- (void)clearTextRequested
{
    localText = @"";
    searchField.text = @"";
    buttonClear.hidden = YES;
    searchField.frame = CGRectMake(nonEditingFieldOrigin.x, nonEditingFieldOrigin.y, searchField.frame.size.width, searchField.frame.size.height);
    if ([self.delegate respondsToSelector:@selector(searchBarClearButtonClicked:)]) [self.delegate searchBarClearButtonClicked:self];
}

- (void)addressBookRequested
{
    if ([self.delegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) [self.delegate searchBarBookmarkButtonClicked:self];
}

- (void)cancelRequested
{
    [self clearTextRequested];
    [searchField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) [self.delegate searchBarCancelButtonClicked:self];
}

- (void)bgButtonPressed
{
    [searchField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [localText release];
    localText = [searchField.text stringByReplacingCharactersInRange:range withString:string];
    [localText retain];
    if ([localText isEqualToString:@""]) {
        searchField.frame = CGRectMake(nonEditingFieldOrigin.x, nonEditingFieldOrigin.y, searchField.frame.size.width, searchField.frame.size.height);
        [self showClearButton:NO];
    } else {
        searchField.frame = CGRectMake(isEditingFieldOrigin.x, isEditingFieldOrigin.y, searchField.frame.size.width, searchField.frame.size.height);
        [self showClearButton:YES];
    }
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) [self.delegate searchBar:self textDidChange:localText];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) [self.delegate searchBarTextDidBeginEditing:self];
    buttonAddressBook.hidden = YES;
    CGPoint fieldOrigin = ([localText isEqualToString:@""]) ? nonEditingFieldOrigin : isEditingFieldOrigin;
    searchField.placeholder = @"";
    searchField.frame = CGRectMake(fieldOrigin.x, fieldOrigin.y, isEditingFieldSize.width, isEditingFieldSize.height);
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         fieldButton.frame = isEditingBgButtonFrame;
                         fieldBgImageView.frame = isEditingBgFrame;
                         buttonCancel.frame = isEditingCancelFrame;
                         buttonCancel.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         [self showClearButton:![localText isEqualToString:@""]];
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) [self.delegate searchBarTextDidEndEditing:self];
    [self showClearButton:NO];
    CGPoint fieldOrigin = nonEditingFieldOrigin;
    searchField.frame = CGRectMake(fieldOrigin.x, fieldOrigin.y, nonEditingFieldSize.width, nonEditingFieldSize.height);
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         fieldButton.frame = nonEditingBgButtonFrame;
                         fieldBgImageView.frame = nonEditingBgFrame;
                         buttonCancel.frame = nonEditingCancelFrame;
                         buttonCancel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         buttonAddressBook.hidden = NO;
                         searchField.placeholder = ([localText isEqualToString:@""]) ? placeholderText : @"";
                     }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) [self.delegate searchBarShouldBeginEditing:self];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) [self.delegate searchBarShouldEndEditing:self];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarReturnButtonClicked:)]) [self.delegate searchBarReturnButtonClicked:self];
    return YES;
}

@end
