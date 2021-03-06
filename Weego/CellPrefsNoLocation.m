//
//  CellPrefsNoLocation.m
//  Weego
//
//  Created by Nicholas Velloff on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CellPrefsNoLocation.h"

@interface CellPrefsNoLocation (Private)

- (void)setUpUI;

@end

@implementation CellPrefsNoLocation

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellPrefsNoLocationHeight;
        
        [self setUpUI];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 300, CellPrefsNoLocationHeight);
        
        
    }
    return self;
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];

    UIImage *icon = [UIImage imageNamed:@"icon_iOS_Settings.png"];
    UIImageView *iconView = [[[UIImageView alloc] initWithImage:icon] autorelease];
    iconView.frame = CGRectMake(18, 9, icon.size.width, icon.size.height);
    [self addSubview:iconView];
    
    UIFont *primaryFont = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    UIFont *secondaryFont = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
    
    int labelLeftPos = 76;
    
    primaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, 14, 0, 0)] autorelease];
    primaryInfoLabel.backgroundColor = [UIColor clearColor];
    primaryInfoLabel.textColor = HEXCOLOR(0x333333FF);
    [primaryInfoLabel setFont:primaryFont];
    primaryInfoLabel.text = @"iOS \"Location Services\":";
    primaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    primaryInfoLabel.numberOfLines = 0;
    [primaryInfoLabel sizeToFit];
    [self addSubview:primaryInfoLabel];
    
    primaryInfoLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos + primaryInfoLabel.frame.size.width + 3, 14, 0, 0)] autorelease];
    primaryInfoLabel2.backgroundColor = [UIColor clearColor];
    primaryInfoLabel2.textColor = [UIColor redColor];
    [primaryInfoLabel2 setFont:primaryFont];
    primaryInfoLabel2.text = @"Disabled";
    primaryInfoLabel2.lineBreakMode = UILineBreakModeTailTruncation; 
    primaryInfoLabel2.numberOfLines = 0;
    [primaryInfoLabel2 sizeToFit];
    [self addSubview:primaryInfoLabel2];
    
    secondaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, primaryInfoLabel.frame.origin.y + primaryInfoLabel.frame.size.height, 0, 0)] autorelease];
    secondaryInfoLabel.backgroundColor = [UIColor clearColor];
    secondaryInfoLabel.textColor = HEXCOLOR(0x666666FF);
    [secondaryInfoLabel setFont:secondaryFont];
    secondaryInfoLabel.text = @"Open iOS \"Settings\" and then \"Enable\"";
    secondaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    secondaryInfoLabel.numberOfLines = 0;
    [secondaryInfoLabel sizeToFit];
    [self addSubview:secondaryInfoLabel];
    
    tertiaryInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelLeftPos, secondaryInfoLabel.frame.origin.y + secondaryInfoLabel.frame.size.height - 2, 0, 0)] autorelease];
    tertiaryInfoLabel.backgroundColor = [UIColor clearColor];
    tertiaryInfoLabel.textColor = HEXCOLOR(0x666666FF);
    [tertiaryInfoLabel setFont:secondaryFont];
    tertiaryInfoLabel.text = @"\"Location Services\" for Weego";
    tertiaryInfoLabel.lineBreakMode = UILineBreakModeTailTruncation; 
    tertiaryInfoLabel.numberOfLines = 0;
    [tertiaryInfoLabel sizeToFit];
    [self addSubview:tertiaryInfoLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end