//
//  HeaderViewCreateEvent.h
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFormInputView.h"
#import "FormTextField.h"
#import "FormTextView.h"
#import "SubViewDateTime.h"

@protocol HeaderViewDelegate

- (void)heightDidChange:(UIView *)sender;

@end


@interface HeaderViewCreateEvent : UIView <BaseFormInputViewDelegate> {
	id <HeaderViewDelegate> delegate;
	float nextY;
	FormTextField *fieldTitle;
//	FormTextView *fieldDescription;
	SubViewDateTime *viewDateTime;
	NSString *title;
	NSString *description;
	NSDate *date;
}

@property (nonatomic, assign) id <HeaderViewDelegate> delegate;
@property (assign) NSString *title;
@property (assign) NSString *description;
@property (assign) NSDate *date;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)aTitle andDescription:(NSString *)aDescription andDate:(NSDate *)aDate;
- (void)prepareToSave;

@end
