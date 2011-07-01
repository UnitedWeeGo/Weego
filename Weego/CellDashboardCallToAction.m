//
//  CellCallToAction.m
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellDashboardCallToAction.h"
#import "CustomCellBackgroundView.h"

@interface CellDashboardCallToAction(Private)

- (void)setUpUI;
- (void)showFeedCount:(BOOL)show;

@end

@implementation CellDashboardCallToAction

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellDashboardCallToActionHeight;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:16];
        self.textLabel.textColor = HEXCOLOR(0x666666FF);
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [self setUpUI];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y + 2, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

- (void)setUpUI
{
    UIImage *feedIcon = [UIImage imageNamed:@"icon_feed_pastfuture.png"];
    feedIconView = [[[UIImageView alloc] initWithImage:feedIcon] autorelease];
    feedIconView.frame = CGRectMake(277, 13, feedIcon.size.width, feedIcon.size.height);
    feedIconView.hidden = YES;
    [self addSubview:feedIconView];
    
    feedCountLabel = [[[UILabel alloc] init] autorelease];
    feedCountLabel.textAlignment = UITextAlignmentCenter;
    feedCountLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
    [feedCountLabel setBackgroundColor:[UIColor clearColor]];
    UIColor *col2 = HEXCOLOR(0xFFFFFFFF);
    [feedCountLabel setTextColor:col2];
    NSString *countCopy = [NSString stringWithFormat:@"%d", 99];
    [feedCountLabel setText:countCopy];
    [feedCountLabel sizeToFit];
    
    CGRect frame = feedCountLabel.bounds;
    frame.origin.x = 0;
    frame.origin.y = 2;
    frame.size.width = 20;
    feedCountLabel.frame = frame;
    [feedIconView addSubview:feedCountLabel];
}

- (void)showFeedCount:(BOOL)show
{
    feedCountLabel.text = [NSString stringWithFormat:@"%d", feedCount];
    feedIconView.hidden = feedCountLabel.hidden = !show;
}

- (void)isFirst:(BOOL)firstValue isLast:(BOOL)lastValue
{
    if (firstValue == YES && lastValue == NO) {
        self.textLabel.textColor = HEXCOLOR(0x666666FF);
        [super isFirst:firstValue isLast:lastValue];
        [self showFeedCount:NO];
    } else {
        self.textLabel.textColor = HEXCOLOR(0xFFFFFFFF);
        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_clear_lrg_default.png"]] autorelease];
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_clear_lrg_pressed.png"]] autorelease];
        [self showFeedCount:feedCount > 0 ? YES : NO];
    }
}

- (void)setFeedCount:(int)count
{
    feedCount = count;
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
