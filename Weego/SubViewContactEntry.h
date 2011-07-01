//
//  SubViewContactEntry.h
//  BigBaby
//
//  Created by Dave Prukop on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "ButtonContact.h"

@protocol SubViewContactEntryDelegate<NSObject>

- (void)inputFieldDidReturn:(id)sender;
- (void)handleDirectFieldTouch:(id)sender;

@optional
- (void)inputFieldDidEndEditing:(id)sender;
- (void)inputFieldDidChange:(id)sender;

@end


@interface SubViewContactEntry : UIView <UITextFieldDelegate, UIScrollViewDelegate, ButtonContactDelegate> {
    UIView *bg;
    UIView *bgStroke;
    UIScrollView *contactScrollView;
    UITextField *inputField;
    UITextField *selectConfirmField;
    UIButton *focusButton;
    NSString *localText;
    UIButton *buttonAddressBook;
    NSMutableArray *contacts;
    NSMutableArray *contactButtons;
    float currentX;
    float currentY;
    float remainingWidth;
    int numberOfLines;
    ButtonContact *currentlySelectedButton;
    BOOL allButtonsShowing;
    BOOL editMode;
    BOOL selectMode;
    BOOL deleteMode;
    
    NSString *lastChar;
    
    int currentMode;
}

@property (nonatomic, assign) id <SubViewContactEntryDelegate> delegate;
@property (nonatomic, readonly) NSString * fieldText;
@property (nonatomic, readonly) NSArray *enteredContacts;
@property (nonatomic, readonly) BOOL allValid;

- (void)addContact:(Contact *)aContact;
- (BOOL)finalizeContact;

@end
