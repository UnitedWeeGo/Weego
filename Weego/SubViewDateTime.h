//
//  SubViewDateTime.h
//  BigBaby
//
//  Created by Dave Prukop on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTextField.h"


@interface SubViewDateTime : UIView <UITextFieldDelegate, UIActionSheetDelegate> {
	BBTextField *dateField;
	BBTextField *timeField;
	NSDate *eventDate;
	UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
}

@property (nonatomic, retain) NSDate *eventDate;

- (id)initWithFrame:(CGRect)frame andDate:(NSDate *)aDate;

@end
