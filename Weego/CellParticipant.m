//
//  CellParticipant.m
//  BigBaby
//
//  Created by Dave Prukop on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellParticipant.h"


@implementation CellParticipant

@synthesize participant;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellParticipantHeight;
        cellView = [[[SubViewParticipant alloc] initWithFrame:CGRectMake(0, 1, 300, 44)] autorelease];
        [self.contentView addSubview:cellView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setParticipant:(Participant *)aParticipant
{
    cellView.participant = aParticipant;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [participant release];
    participant = nil;
    [super dealloc];
}

@end
