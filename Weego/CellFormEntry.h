//
//  CellFormEntry.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBTableViewCell.h"

#define CellFormEntryHeight 44.0

typedef enum {
    CellFormEntryTypeNormal,
    CellFormEntryTypeName,
    CellFormEntryTypeEmail,
    CellFormEntryTypePhone,
    CellFormEntryTypePassword,
    CellFormEntryTypePrevent
} CellFormEntryType;

@protocol CellFormEntryDelegate<NSObject>

- (void)inputFieldDidReturn:(id)sender;
- (void)handleDirectFieldTouch:(id)sender;

@optional
- (void)inputFieldDidEndEditing:(id)sender;
- (void)inputFieldDidChange:(id)sender;

@end

@interface CellFormEntry : BBTableViewCell <UITextFieldDelegate> {
    CGRect nonEditingFieldFrame;
    CGRect isEditingFieldFrame;
    
    UILabel *fieldTitle;
    UITextField *inputField;
    NSString *localText;
    NSString *placeholderText;
}

@property (nonatomic, assign) int index;
@property (nonatomic, assign) id <CellFormEntryDelegate> delegate;
@property (nonatomic, readonly) UITextField *field;
@property (nonatomic, assign) NSString *fieldText;
@property (nonatomic, assign) NSString *placeholder;

- (void)setTitle:(NSString *)title;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)setEntryType:(CellFormEntryType)type;
- (void)setReturnKeyType:(UIReturnKeyType)type;

@end
