//
//  CellDashboardEvent.m
//  BigBaby
//
//  Created by Dave Prukop on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellDashboardEvent.h"

@implementation CellDashboardEvent

@synthesize event;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellDashboardEventHeight;
        cellView = [[SubViewEventInfo alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        [self.contentView addSubview:cellView];
        [cellView release];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setEvent:(Event *)anEvent
{
    cellView.event = anEvent;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    NSLog(@"CellDashboardEvent dealloc");
    [event release];
    [super dealloc];
}

@end
