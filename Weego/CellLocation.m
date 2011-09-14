//
//  CellLocation.m
//  BigBaby
//
//  Created by Dave Prukop on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellLocation.h"


@implementation CellLocation

@synthesize delegate;
@synthesize location;
@synthesize index;
@synthesize eventState;
@synthesize editing;
@synthesize doShowReportingLocationIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellLocationHeight;
        cellView = [[[SubViewLocation alloc] initWithFrame:CGRectMake(0, 0, 300, 69)] autorelease];
        [self.contentView addSubview:cellView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDelegate:(id<SubViewLocationDelegate>)aDelegate
{
    cellView.delegate = aDelegate;
}

- (void)setDoShowReportingLocationIcon:(BOOL)toShowReportingLocationIcon
{
    cellView.doShowReportingLocationIcon = toShowReportingLocationIcon;
}

- (void)setLocation:(Location *)aLocation
{
    cellView.location = aLocation;
}

- (void)setEventState:(EventState)aEventState
{
    cellView.eventState = aEventState;
}

- (void)setIndex:(int)value
{
    cellView.index = value;
}

- (void)setEditing:(BOOL)isEditing
{
    cellView.editing = isEditing;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showError
{
    [cellView showError];
}

- (void)dealloc
{
    delegate = nil;
    [location release];
    location = nil;
    [super dealloc];
}

@end
