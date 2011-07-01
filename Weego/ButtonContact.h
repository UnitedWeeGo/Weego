//
//  ButtonContact.h
//  BigBaby
//
//  Created by Dave Prukop on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol ButtonContactDelegate <NSObject>

- (void)buttonSelected:(id)sender;

@end

@interface ButtonContact : UIButton {
    BOOL isValid;
}

@property (nonatomic, assign) id<ButtonContactDelegate> delegate;
@property (nonatomic, assign) int index;
@property (nonatomic, readonly) BOOL isValid;

- (id)initWithContact:(Contact *)contact andPosition:(CGPoint)aPosition;
- (void)setSelected:(BOOL)isSelected;

+ (CGRect)frameWithLabel:(NSString *)label;

@end
