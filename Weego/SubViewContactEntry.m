//
//  SubViewContactEntry.m
//  BigBaby
//
//  Created by Dave Prukop on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubViewContactEntry.h"

#define LEFT_FIELD_MARGIN 8.0
#define TOP_FIELD_MARGIN 14.0
#define TOP_BUTTON_MARGIN 8.0
#define MAX_FIELD_WIDTH 265.0

#define Z_WIDTH_SPACE @"\u200B"

typedef enum {
    AddFriendsModeEdit = 0,
    AddFriendsModeSelect,
    AddFriendsModeDelete,
    NumAddFriendsModes
} AddFriendsMode;

@interface SubViewContactEntry (Private)

- (void)setUpUI;
- (void)positionTextField;
- (void)resizeContent;
- (void)layoutButtons;
- (void)removeButtonsFromView;
- (void)deselectAllButtons;
- (void)selectLastButton;
- (void)deleteCurrentlySelected;
- (void)textFieldWasTouched;
- (void)showAllButtons:(BOOL)showAll;
- (void)showCurrentlySelected;
- (void)clearText;
- (void)placeholderCharacter;

@end

@implementation SubViewContactEntry

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [contacts release];
    [contactButtons release];
    [lastChar release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [inputField becomeFirstResponder];
}

- (void)viewWillAppear
{
    [inputField becomeFirstResponder];
}

- (void)setUpUI
{
    bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    bg.backgroundColor = HEXCOLOR(0xFFFFFFFF);
    [self addSubview:bg];
    [bg release];
    
    bgStroke = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 1)];
    bgStroke.backgroundColor = HEXCOLOR(0xCCCCCCFF);
    [self addSubview:bgStroke];
    [bgStroke release];
        
    contactScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    contactScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:contactScrollView];
    [contactScrollView release];
    
    contacts = [[NSMutableArray alloc] init];
    contactButtons = [[NSMutableArray alloc] init];
    allButtonsShowing = YES;
    
    inputField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_FIELD_MARGIN,TOP_FIELD_MARGIN,MAX_FIELD_WIDTH,16)];
    inputField.textColor = HEXCOLOR(0x333333FF);
    inputField.borderStyle = UITextBorderStyleNone;
	inputField.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	inputField.backgroundColor = [ UIColor clearColor ]; 
    inputField.keyboardType = UIKeyboardTypeDefault;
    inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    inputField.delegate = self;
        
    [contactScrollView addSubview:inputField];
    [inputField becomeFirstResponder];
    [inputField release];
    
    selectConfirmField = [[UITextField alloc] initWithFrame:CGRectMake(LEFT_FIELD_MARGIN,TOP_FIELD_MARGIN+56,MAX_FIELD_WIDTH,16)];
    selectConfirmField.hidden = YES;
    selectConfirmField.keyboardType = UIKeyboardTypeDefault;
    selectConfirmField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    selectConfirmField.autocorrectionType = UITextAutocorrectionTypeNo;
    selectConfirmField.delegate = self;
    [self addSubview:selectConfirmField];
    [selectConfirmField release];
    
    [self clearText];
    
    focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    focusButton.backgroundColor = [UIColor clearColor];
    focusButton.showsTouchWhenHighlighted = NO;
    focusButton.frame = inputField.frame;
    focusButton.hidden = YES;
    [focusButton addTarget:self action:@selector(textFieldWasTouched) forControlEvents:UIControlEventTouchUpInside];
    [contactScrollView addSubview:focusButton];
    
    buttonAddressBook = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *iconAddressBook = [UIImage imageNamed:@"icon_addressbook_01.png"];
    [buttonAddressBook setImage:iconAddressBook forState:UIControlStateNormal];
    buttonAddressBook.frame = CGRectMake(277, 8, iconAddressBook.size.width, iconAddressBook.size.height);
    [self addSubview:buttonAddressBook];

    currentMode = AddFriendsModeEdit;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"string = %@", string);
    [localText release];
    localText = [inputField.text stringByReplacingCharactersInRange:range withString:string];
    [localText retain];
    
    if ([delegate respondsToSelector:@selector(inputFieldDidChange:)]) [delegate inputFieldDidChange:self];
    
    if ([localText length] == 0) {
        if (currentMode >= NumAddFriendsModes) currentMode = 0;
        NSLog(@"currentMode = %i", currentMode);
        switch (currentMode) {
            case AddFriendsModeEdit:
                
                break;
            case AddFriendsModeSelect:
                [self selectLastButton];
                break;
            case AddFriendsModeDelete:
                [self deleteCurrentlySelected];
                break;
            default:
                break;
        }
        currentMode++;
        [selectConfirmField becomeFirstResponder];
        [self performSelector:@selector(placeholderCharacter) withObject:self afterDelay:0.01];
    } else {
        if (currentlySelectedButton) [self deleteCurrentlySelected];
        if (allButtonsShowing) [self showAllButtons:NO];
        
        if ([ButtonContact frameWithLabel:localText].size.width > remainingWidth) {
            numberOfLines++;
            currentX = LEFT_FIELD_MARGIN;
            currentY = TOP_BUTTON_MARGIN + (33 * (numberOfLines-1));
            remainingWidth = MAX_FIELD_WIDTH;
            [self positionTextField];
            [self resizeContent];
        }
        currentMode = AddFriendsModeEdit;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self finalizeContact];
}

#pragma mark - Public Methods

- (NSString *)fieldText
{
    NSString *evalStr = [localText stringByReplacingOccurrencesOfString:Z_WIDTH_SPACE withString:@""];
	return [evalStr length] == 0 ? @"" : evalStr;
}

- (void)addContact:(Contact *)aContact
{
    [contacts addObject:aContact];
    allButtonsShowing = YES;
    if (currentlySelectedButton) {
        [self deleteCurrentlySelected];
    } else {
        [self layoutButtons];
    }
//    [self clearText];
}

- (BOOL)finalizeContact
{
    if ([self.fieldText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        Contact *c = [[Contact alloc] init];
        c.contactName = self.fieldText;
        c.emailAddress = self.fieldText;
        [self addContact:c];
        [c release];
        return YES;
    }
    return NO;
}

- (NSArray *)enteredContacts
{
    return contacts;
}

- (BOOL)allValid
{
    for (ButtonContact *bc in contactButtons) {
        if (!bc.isValid) return NO;
    }
    return YES;
}

#pragma mark - Private Methods

- (void)positionTextField
{
//    NSLog(@"");
    inputField.frame = CGRectMake(currentX, TOP_FIELD_MARGIN + (33 * (numberOfLines-1)), remainingWidth, 16);
    focusButton.frame = inputField.frame;
}

- (void)resizeContent
{
//    contactScrollView.contentSize = CGSizeMake(self.frame.size.width, 44 + (33 * (numberOfLines-1)));
//    if (!allButtonsShowing) contactScrollView.contentOffset = CGPointMake(0, 33 * (numberOfLines-1));
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         contactScrollView.contentSize = CGSizeMake(self.frame.size.width, 44 + (33 * (numberOfLines-1)));
                         if (!allButtonsShowing) contactScrollView.contentOffset = CGPointMake(0, 33 * (numberOfLines-1));
                     }
                     completion:NULL];
}

- (void)layoutButtons
{
    numberOfLines = 1;
    currentX = LEFT_FIELD_MARGIN;
    currentY = TOP_BUTTON_MARGIN; // + (33 * (numberOfLines-1));
    remainingWidth = MAX_FIELD_WIDTH;
    
    [self removeButtonsFromView];
    for (int i=0; i<[contacts count]; i++) {
        Contact *aContact = [contacts objectAtIndex:i];
        float nextRight = currentX + [ButtonContact frameWithLabel:aContact.contactName].size.width;
        if (nextRight > MAX_FIELD_WIDTH) {
            numberOfLines++;
            currentX = LEFT_FIELD_MARGIN;
            currentY = TOP_BUTTON_MARGIN + (33 * (numberOfLines-1));
            remainingWidth = MAX_FIELD_WIDTH;
        }
        ButtonContact *bc = [[ButtonContact alloc] initWithContact:aContact andPosition:CGPointMake(currentX, currentY)];
        bc.delegate = self;
        bc.index = i;
        [contactScrollView addSubview:bc];
        [contactButtons addObject:bc];
        [bc release];
        currentX += bc.frame.size.width + 5;
        remainingWidth = MAX_FIELD_WIDTH - currentX + LEFT_FIELD_MARGIN;
    }
    
    [self positionTextField];
    [self resizeContent];
    [self showAllButtons:allButtonsShowing];
    
    [self clearText];
    if ([delegate respondsToSelector:@selector(inputFieldDidChange:)]) [delegate inputFieldDidChange:self];
}

- (void)removeButtonsFromView
{
    for (int i=0; i<[contactButtons count]; i++) {
        ButtonContact *bc = [contactButtons objectAtIndex:i];
        [bc removeFromSuperview];
    }
    [contactButtons removeAllObjects];
}

- (void)deselectAllButtons
{
    for (int i=0; i<[contactButtons count]; i++) {
        ButtonContact *bc = [contactButtons objectAtIndex:i];
        [bc setSelected:NO];
    }
    currentlySelectedButton = nil;
    inputField.hidden = NO;
    focusButton.hidden = YES;
}

- (void)selectLastButton
{
    if ([contactButtons count] > 0) {
        ButtonContact *bc = [contactButtons lastObject];
        [self buttonSelected:bc];
        currentMode = AddFriendsModeSelect;
        [self showAllButtons:YES];
    } else {
        [self deselectAllButtons];
    }
}

- (void)deleteCurrentlySelected
{
    if ([contacts count] > 0 && currentlySelectedButton) {
        int index = currentlySelectedButton.index;
        [contacts removeObjectAtIndex:index];
        [self layoutButtons];
        currentMode = AddFriendsModeEdit;
    }
    [self deselectAllButtons];
}

- (void)textFieldWasTouched
{
    NSLog(@"textFieldWasTouched");
    [self clearText];
    [self deselectAllButtons];
}

- (void)showAllButtons:(BOOL)showAll
{
    allButtonsShowing = showAll;
    CGRect newFrame;
    CGPoint newPoint;
    if (showAll) {
        newFrame = CGRectMake(contactScrollView.frame.origin.x, contactScrollView.frame.origin.y, 
                              contactScrollView.frame.size.width, 
                              contactScrollView.contentSize.height);
        newPoint = CGPointMake(0, 0);
    } else {
        newFrame = CGRectMake(contactScrollView.frame.origin.x, contactScrollView.frame.origin.y, 
                              contactScrollView.frame.size.width, 
                              44);
        newPoint = CGPointMake(0, 33 * (numberOfLines-1));
    }
    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         self.frame = newFrame;
                         contactScrollView.frame = newFrame;
                         bg.frame = contactScrollView.frame;
                         bgStroke.frame = CGRectMake(bgStroke.frame.origin.x, bg.frame.size.height, 
                                                     bgStroke.frame.size.width, 
                                                     bgStroke.frame.size.height);
                         contactScrollView.contentOffset = newPoint;
                     }
                     completion:NULL];
}

- (void)showCurrentlySelected
{
    CGRect newFrame;
    CGPoint newPoint;
    newFrame = CGRectMake(contactScrollView.frame.origin.x, contactScrollView.frame.origin.y, 
                          contactScrollView.frame.size.width, 
                          44);
    newPoint = CGPointMake(0, currentlySelectedButton.frame.origin.y - TOP_BUTTON_MARGIN);

    [UIView animateWithDuration:0.30f 
                          delay:0 
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction) 
                     animations:^(void){
                         self.frame = newFrame;
                         contactScrollView.frame = newFrame;
                         bg.frame = contactScrollView.frame;
                         bgStroke.frame = CGRectMake(bgStroke.frame.origin.x, bg.frame.size.height, 
                                                     bgStroke.frame.size.width, 
                                                     bgStroke.frame.size.height);
                         contactScrollView.contentOffset = newPoint;
                     }
                     completion:NULL];
}

- (void)clearText
{
    inputField.text = Z_WIDTH_SPACE;
    [localText release];
    localText = @"";
    [localText retain];
    currentMode = AddFriendsModeSelect;
}

- (void)placeholderCharacter
{
    inputField.text = Z_WIDTH_SPACE;
    [inputField becomeFirstResponder];
}


#pragma mark - ButtonContactDelegate

- (void)buttonSelected:(id)sender
{
    [self deselectAllButtons];
    [self clearText];
    currentlySelectedButton = (ButtonContact *)sender;
    [currentlySelectedButton setSelected:YES];
    inputField.hidden = YES;
    focusButton.hidden = NO;
    currentMode = AddFriendsModeDelete;
    if (!currentlySelectedButton.isValid) {
        [self showCurrentlySelected];
        [localText release];
        localText = ((Contact *)[contacts objectAtIndex:currentlySelectedButton.index]).contactName;
        [localText retain];
        if ([delegate respondsToSelector:@selector(inputFieldDidChange:)]) [delegate inputFieldDidChange:self];
    } else {
        [self showAllButtons:YES];
    }
}

@end
