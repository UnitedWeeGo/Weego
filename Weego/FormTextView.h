//
//  FormTextView.h
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFormInputView.h"
#import "BBTextView.h"


@interface FormTextView : BaseFormInputView <UITextViewDelegate> {
	UITextField *bg;
	BBTextView *textView;
}

//@property (nonatomic, retain) BBTextView *textView;

@end
