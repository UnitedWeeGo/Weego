//
//  CellEventCallToAction.m
//  BigBaby
//
//  Created by Dave Prukop on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellEventCallToAction.h"


@implementation CellEventCallToAction

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellEventCallToActionHeight;
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

        UIImage *yLogoImg = [UIImage imageNamed:@"logo_yelp.png"];
        yelpLogo = [[UIImageView alloc] initWithImage:yLogoImg];
        yelpLogo.frame = CGRectMake(182, 6, yLogoImg.size.width, yLogoImg.size.height);
        yelpLogo.hidden = YES;
        [self addSubview:yelpLogo];
        
//        self.textLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
//        self.textLabel.textColor = HEXCOLOR(0x666666FF);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.frame = CGRectMake(0, 0, 300, CellEventCallToActionHeight);
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
    yelpLogo.hidden = YES;
    fieldTitle.text = title;
}

- (void)showYelpLogo
{
    yelpLogo.hidden = NO;
}

@end
