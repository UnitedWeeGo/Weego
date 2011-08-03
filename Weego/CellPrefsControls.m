//
//  CellPrefsControls.m
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellPrefsControls.h"

@implementation CellPrefsControls

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellPrefsControlsHeight;
        self.backgroundColor = [UIColor clearColor];
        
        UIColor *titleLabelColor = nil;
        titleLabelColor = HEXCOLOR(0x333333FF);
        
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
        self.frame = CGRectMake(0, 0, 300, CellPrefsControlsHeight);
        
        uiSwitch = [[[UISwitch alloc] init] autorelease];
        [uiSwitch addTarget:self action:@selector(handleSwitchToggle) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = uiSwitch;
    }
    return self;
}

- (void)handleSwitchToggle
{
    if (prefsKey == nil)
    {
        NSLog(@"PREFS KEY NOT SET, NO PREF REGISTERED");
        return;
    }
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setBool:uiSwitch.on forKey:prefsKey];
    [userPreferences synchronize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    if (prefsKey != nil) [prefsKey release];
    [super dealloc];
}

- (void)setTitle:(NSString *)title
{
    fieldTitle.text = title;
}

- (void)setPrefsKey:(NSString *)key
{
    if (prefsKey != nil) [prefsKey release];
    prefsKey = [key copy];
    
    BOOL prefTrue = [[NSUserDefaults standardUserDefaults] boolForKey:prefsKey];
    uiSwitch.on = prefTrue;
}

@end
