//
//  CellPrefsLinks.m
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellPrefsLinks.h"

@implementation CellPrefsLinks

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellPrefsLinksHeight;
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
        
        
        
        //        self.textLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
        //        self.textLabel.textColor = HEXCOLOR(0x666666FF);
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.frame = CGRectMake(0, 0, 300, CellPrefsLinksHeight);
        
        self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_chevron_list_01.png"]] autorelease];
    }
    return self;
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

- (void)setTitle:(NSString *)title
{
    fieldTitle.text = title;
}

@end
