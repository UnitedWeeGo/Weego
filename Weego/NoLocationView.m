//
//  NoLocationView.m
//  Weego
//
//  Created by Nicholas Velloff on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NoLocationView.h"

@interface NoLocationView ()

- (void)setupUI;

@end

@implementation NoLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    // add the icon
    UIImage *icon = [UIImage imageNamed:@"icon_iOS_Settings.png"];
    UIImageView *iconView = [[[UIImageView alloc] initWithImage:icon] autorelease];
    iconView.frame = CGRectMake(7, 7, icon.size.width, icon.size.height);
    [self addSubview:iconView];
    
    UIFont *primaryFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
    UIFont *secondaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    
    int labelLeftPos = 65;
    
    primaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, 12, 0, 0)] autorelease];
    primaryInfoLabel.backgroundColor = [UIColor clearColor];
    primaryInfoLabel.textColor = [UIColor whiteColor];
    [primaryInfoLabel setFont:primaryFont];
    primaryInfoLabel.text = @"iOS \"Location Services\":";
    primaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    primaryInfoLabel.numberOfLines = 0;
    [primaryInfoLabel sizeToFit];
    [self addSubview:primaryInfoLabel];
    
    primaryInfoLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos + primaryInfoLabel.frame.size.width + 3, 12, 0, 0)] autorelease];
    primaryInfoLabel2.backgroundColor = [UIColor clearColor];
    primaryInfoLabel2.textColor = [UIColor blackColor];
    [primaryInfoLabel2 setFont:primaryFont];
    primaryInfoLabel2.text = @"Disabled";
    primaryInfoLabel2.lineBreakMode = UILineBreakModeTailTruncation; 
    primaryInfoLabel2.numberOfLines = 0;
    [primaryInfoLabel2 sizeToFit];
    [self addSubview:primaryInfoLabel2];
    
    secondaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, primaryInfoLabel.frame.origin.y + primaryInfoLabel.frame.size.height, 0, 0)] autorelease];
    secondaryInfoLabel.backgroundColor = [UIColor clearColor];
    secondaryInfoLabel.textColor = [UIColor blackColor];
    [secondaryInfoLabel setFont:secondaryFont];
    secondaryInfoLabel.text = @"Open iOS \"Settings\" and then \"Enable\"";
    secondaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    secondaryInfoLabel.numberOfLines = 0;
    [secondaryInfoLabel sizeToFit];
    [self addSubview:secondaryInfoLabel];
    
    tertiaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, secondaryInfoLabel.frame.origin.y + secondaryInfoLabel.frame.size.height - 2, 0, 0)] autorelease];
    tertiaryInfoLabel.backgroundColor = [UIColor clearColor];
    tertiaryInfoLabel.textColor = [UIColor blackColor];
    [tertiaryInfoLabel setFont:secondaryFont];
    tertiaryInfoLabel.text = @"\"Location Services\" for Weego";
    tertiaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    tertiaryInfoLabel.numberOfLines = 0;
    [tertiaryInfoLabel sizeToFit];
    [self addSubview:tertiaryInfoLabel];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
