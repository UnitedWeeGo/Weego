//
//  BaseFormInputView.h
//  BigBaby
//
//  Created by Dave Prukop on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BaseFormInputViewTypeNormal 0
#define BaseFormInputViewTypeTitle 1
#define BaseFormInputViewTypeName 2
#define BaseFormInputViewTypeEmail 3
#define BaseFormInputViewTypePassword 4

@protocol BaseFormInputViewDelegate

- (void)heightDidChange:(UIView *)sender;
- (void)inputViewDidReturn:(UIView *)sender;

@end

@interface BaseFormInputView : UIView {
	id <BaseFormInputViewDelegate> delegate;
	float nextY;
	int fieldType;
}

@property (nonatomic, assign) id <BaseFormInputViewDelegate> delegate;
@property (assign) NSString *text;

- (id)initWithLabel:(NSString *)aLabel andOriginY:(CGFloat)yPos andType:(int)type;
- (void)setUpUI;
- (void)setTextInputTraitsWithType:(int)type andInputField:(id <UITextInputTraits>)field;

@end
