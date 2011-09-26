//
//  CellCategory.m
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellCategory.h"

@interface CellCategory (Private)

- (void)setUpUI;

@end

@implementation CellCategory

@synthesize category;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpUI
{
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    UIColor *titleLabelColor = nil;
    
    titleLabelColor = HEXCOLOR(0x333333FF);
    
    labelCategoryName = [[[UILabel alloc] initWithFrame:CGRectMake(8, 10, 312, 16)] autorelease];
	labelCategoryName.textColor = titleLabelColor;
	labelCategoryName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
	labelCategoryName.shadowOffset = CGSizeMake(0.0, 1.0);
	labelCategoryName.backgroundColor = [ UIColor clearColor ]; 
	labelCategoryName.lineBreakMode = UILineBreakModeTailTruncation;
	labelCategoryName.numberOfLines = 0;
	[self addSubview:labelCategoryName];
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 31, 320, 1)];
    separator.backgroundColor = HEXCOLOR(0xCCCCCCFF);
    [self addSubview:separator];
    [separator release];
}

- (void)setCategory:(SearchCategory *)aCategory
{
    labelCategoryName.text = aCategory.search_category;
    UIColor *titleLabelColor;
    if ([aCategory.type isEqualToString:@"Current Location"])
    {
        titleLabelColor = HEXCOLOR(0x2957FFFF);
    }
    else
    {
        titleLabelColor = HEXCOLOR(0x333333FF);
    }
    labelCategoryName.textColor = titleLabelColor;
}

- (void)dealloc
{
    [super dealloc];
}

@end
