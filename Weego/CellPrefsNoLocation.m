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
        self.height = CellPrefsLoginParticipantHeight;
        self.backgroundColor = [UIColor clearColor];
        
        leftMargin = 8;
        [self setUpUI];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 300, CellPrefsLoginParticipantHeight);
        
        
    }
    return self;
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
    
    UIColor *labelColor = nil;
    UIColor *titleLabelColor = nil;
    UIColor *shadowColor = nil;
    
    labelColor = HEXCOLOR(0x666666FF);
    titleLabelColor = HEXCOLOR(0x333333FF);
    shadowColor = HEXCOLOR(0xFFFFFF33);
    
	nextY = 10.0;
    
    NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    BOOL canOpenPrefs = [[UIApplication sharedApplication] canOpenURL:url];
    
    float textLeftPos = leftMargin + 60 + 6;
    fieldWidth = 320 - textLeftPos - 20;
    
    UIImage *settingsIcon = [UIImage imageNamed:@"Settings.png"];
    UIImageView *settingsIconView = [[[UIImageView alloc] initWithImage:settingsIcon] autorelease];
    settingsIconView.frame = CGRectMake(leftMargin + 10, nextY, 50, 50);
    [self addSubview:settingsIconView];
    
    if (labelLine1 == nil) labelLine1 = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                 nextY + 13, 
                                                                                 fieldWidth, 
                                                                                 16)] autorelease];
	labelLine1.textColor = titleLabelColor;
	labelLine1.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	labelLine1.backgroundColor = [ UIColor clearColor ]; 
	labelLine1.lineBreakMode = UILineBreakModeWordWrap;
	labelLine1.numberOfLines = 0;
    labelLine1.text = @"Location services disabled";
	[self addSubview:labelLine1];
    
	nextY = labelLine1.frame.origin.y + labelLine1.frame.size.height;
	
	if (labelLine2 == nil) labelLine2 = [[[UILabel alloc] initWithFrame:CGRectMake(textLeftPos, 
                                                                                   nextY, 
                                                                                   fieldWidth, 
                                                                                   14)] autorelease];
	labelLine2.textColor = labelColor;
	labelLine2.font = [UIFont fontWithName:@"MyriadPro-Regular" size:12];
	labelLine2.shadowColor = shadowColor;
	labelLine2.shadowOffset = CGSizeMake(0.0, 1.0);
	labelLine2.backgroundColor = [ UIColor clearColor ]; 
	labelLine2.lineBreakMode = UILineBreakModeTailTruncation;
	labelLine2.numberOfLines = 0;
    labelLine2.text = canOpenPrefs ? @"Click to open location settings" : @"Open setting and enable location services";
	[self addSubview:labelLine2];
    
	self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							nextY);
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