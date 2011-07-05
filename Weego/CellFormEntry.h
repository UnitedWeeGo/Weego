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
    UILabel *fieldTitle;
    UITextField *inputField;
    NSString *localText;
}

@property (nonatomic, assign) int index;
@property (nonatomic, assign) id <CellFormEntryDelegate> delegate;
@property (nonatomic, assign) NSString * fieldText;

- (void)setTitle:(NSString *)title;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)setEntryType:(CellFormEntryType)type;
- (void)setReturnKeyType:(UIReturnKeyType)type;

@end