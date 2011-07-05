//
//  CellFeedMessage.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellFeedMessage.h"


@implementation CellFeedMessage

@synthesize feedMessage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.frame = CGRectMake(0, 0, 320, 44);
        cellView = [[[SubViewFeedMessage alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        [self.contentView addSubview:cellView];
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        separator.backgroundColor = HEXCOLOR(0xCCCCCCFF);
        [self.contentView addSubview:separator];
        [separator release];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setFeedMessage:(FeedMessage *)aFeedMessage
{
    CGRect trgFrame = CGRectMake(0, 0, 320, [SubViewFeedMessage calulateMyHeightWithFeedMessage:aFeedMessage]);
    self.frame = trgFrame;
    cellView.frame = trgFrame;
    cellView.feedMessage = aFeedMessage;
    
    separator.frame = CGRectMake(0, trgFrame.size.height-1, 320, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [feedMessage release];
    feedMessage = nil;
    [super dealloc];
}

@end
