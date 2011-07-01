//
//  FormTextField.h
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFormInputView.h"
#import "BBTextField.h"

@interface FormTextField : BaseFormInputView <UITextFieldDelegate> {
	BBTextField *textField;
}

@end
