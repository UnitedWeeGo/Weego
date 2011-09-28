//
//  CellToggle.m
//  Weego
//
//  Created by Nicholas Velloff on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellToggle.h"

@implementation CellToggle

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellToggleHeight;
        self.backgroundColor = [UIColor clearColor];
        
        UIColor *titleLabelColor = nil;
        titleLabelColor = HEXCOLOR(0x666666FF);
        
        if (fieldTitle == nil) fieldTitle = [[[UILabel alloc] initWithFrame:CGRectMake(20, 
                                                                                       17, 
                                                                                       300, 
                                                                                       16)] autorelease];
        fieldTitle.textColor = titleLabelColor;
        fieldTitle.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
        fieldTitle.backgroundColor = [ UIColor clearColor ]; 
        fieldTitle.lineBreakMode = UILineBreakModeTailTruncation;
        fieldTitle.numberOfLines = 0;
        [self addSubview:fieldTitle];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 300, CellToggleHeight);
        
        uiSwitch = [[[UISwitch alloc] init] autorelease];
        [uiSwitch addTarget:self action:@selector(handleSwitchToggle) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = uiSwitch;
    }
    return self;
}

- (void)handleSwitchToggle
{
    if (self.delegate) [self.delegate userToggledCellWithTitle:fieldTitle.text toValue:uiSwitch.on];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    delegate = nil;
    [super dealloc];
}

- (void)setTitle:(NSString *)title andCurrentStatus:(BOOL)isOn
{
    fieldTitle.text = title;
    uiSwitch.on = isOn;
}

@end
