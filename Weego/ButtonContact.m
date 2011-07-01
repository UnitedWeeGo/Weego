//
//  ButtonContact.m
//  BigBaby
//
//  Created by Dave Prukop on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ButtonContact.h"

@interface ButtonContact (Private)

@end

@implementation ButtonContact

@synthesize delegate, index, isValid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithContact:(Contact *)contact andPosition:(CGPoint)aPosition
{
    
    CGRect frame = [ButtonContact frameWithLabel:contact.contactName];
    frame.origin.x = aPosition.x;
    frame.origin.y = aPosition.y;
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
        isValid = contact.isValid;
        [self setTitle:contact.contactName forState:UIControlStateNormal];
        [self setContentEdgeInsets:UIEdgeInsetsMake(6.0, 5.0, 2.0, 5.0)];
        [self setSelected:NO];
        [self addTarget:self action:@selector(handleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)isSelected
{
    UIColor *lightColor = HEXCOLOR(0xFFFFFFFF);
    UIColor *darkColor = HEXCOLOR(0x333333FF);
    UIColor *textColor = (isSelected) ? lightColor : darkColor;
    NSString *selectedPath = (isValid) ? @"container_contact_selected.png" : @"container_contact_red_selected.png";
    NSString *defaultPath = (isValid) ? @"contianer_contact_default.png" : @"contianer_contact_red_default.png";
    NSString *imagePath = (isSelected) ? selectedPath : defaultPath;
    [self setTitleColor:textColor forState:UIControlStateNormal];
    UIImage *bgImageDefault = [[UIImage imageNamed:imagePath] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
    [self setBackgroundImage:bgImageDefault forState:UIControlStateNormal];
}

- (void)handleButtonPressed
{
    if ([delegate respondsToSelector:@selector(buttonSelected:)]) [delegate buttonSelected:self];
}

- (void)dealloc
{
    [super dealloc];
}

+ (CGRect)frameWithLabel:(NSString *)label
{
    CGSize maxSize = {245, 16};
    CGSize frameSize = [label sizeWithFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:14] constrainedToSize:maxSize lineBreakMode:UILineBreakModeTailTruncation];
    CGRect myFrame = CGRectMake(0, 0, ceil(frameSize.width) + 20, 29);
    return myFrame;
}

@end
