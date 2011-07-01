//
//  CellDashboardFeaturedEvent.m
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CellDashboardFeaturedEvent.h"

@interface CellDashboardFeaturedEvent (Private)

- (void)setVotingWarningTimerLabel;

@end

@implementation CellDashboardFeaturedEvent

@synthesize event, index, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.height = CellDashboardFeaturedEventHeight;
        nextY = 0;
        cellTopView = [[[SubViewEventInfo alloc] initWithFrame:CGRectMake(0, nextY, 300, 69)] autorelease]; //85
        [self.contentView addSubview:cellTopView];
        
        nextY = cellTopView.frame.origin.y + cellTopView.frame.size.height + 3;
        
        UIImage *countIcon = [UIImage imageNamed:@"icon_people_sm_01.png"];
        countIconView = [[UIImageView alloc] initWithImage:countIcon];
        countIconView.frame = CGRectMake(80, nextY, countIcon.size.width, countIcon.size.height);
        [self addSubview:countIconView];
        [countIconView release];
        
        if (labelCount == nil) labelCount = [[UILabel alloc] initWithFrame:CGRectMake(countIconView.frame.origin.x + 17, 
                                                                                      nextY, 
                                                                                      15, 
                                                                                      14)];
        labelCount.textColor = HEXCOLOR(0x666666FF);
        labelCount.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
        labelCount.backgroundColor = [ UIColor clearColor ];
        [self addSubview:labelCount];
        [labelCount release];
        
        nextY = labelCount.frame.origin.y + labelCount.frame.size.height + 2;
        
        if (labelEndsIn == nil) labelEndsIn = [[UILabel alloc] initWithFrame:CGRectMake(80, nextY, 100, 20)];
        labelEndsIn.textColor = HEXCOLOR(0x666666FF);
        labelEndsIn.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
        labelEndsIn.backgroundColor = [ UIColor clearColor ];
        labelEndsIn.hidden = YES;
        [self addSubview:labelEndsIn];
        [labelEndsIn release];
        
        if (labelTimer == nil) labelTimer = [[UILabel alloc] initWithFrame:CGRectMake(80, nextY, 100, 20)];
        labelTimer.textColor = HEXCOLOR(0x669900FF);
        labelTimer.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12];
        labelTimer.backgroundColor = [ UIColor clearColor ]; 
        labelTimer.hidden = YES;
        [self addSubview:labelTimer];
        [labelTimer release];
        
        cellBottomView = [[[SubViewLocation alloc] initWithFrame:CGRectMake(0, self.height-69.0, 300, 69)] autorelease];
        [self.contentView addSubview:cellBottomView];
        cellBottomAltView = [[[SubViewNoLocations alloc] initWithFrame:CGRectMake(0, self.height-69.0, 300, 69)] autorelease];
        [self.contentView addSubview:cellBottomAltView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        cellBottomBg = [[[CustomCellBackgroundView alloc] initWithFrame:CGRectMake(0,self.height-69.0,300,69)] autorelease];
        cellBottomBg.position = CustomCellBackgroundViewPositionBottom;
        cellBottomBg.colorScheme = CustomCellBackgroundViewColorSchemeNoBorder;
        [self.contentView insertSubview:cellBottomBg atIndex:0];
        separator = [[UIView alloc] initWithFrame:CGRectMake(0,self.height-69.0,300,1)];
        separator.backgroundColor = HEXCOLOR(0xEDEDEDFF);
        [self.contentView addSubview:separator];
        [separator release];
    }
    return self;
}

- (void)setEvent:(Event *)anEvent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [event release];
    event = anEvent;
    [event retain];
    cellTopView.event = anEvent;
    labelCount.text = anEvent.participantCount;
    
    labelEndsIn.hidden = YES;
    labelTimer.hidden = YES;
    
    if (anEvent.currentEventState == EventStateVoting) {
        labelEndsIn.hidden = NO;
        labelTimer.hidden = NO;
        labelEndsIn.text = @"Voting is ";
        [labelEndsIn sizeToFit];
        labelTimer.text = @"open";
        [labelTimer sizeToFit];
        labelTimer.frame = CGRectMake(labelEndsIn.frame.origin.x + labelEndsIn.frame.size.width, 
                                      labelTimer.frame.origin.y, 
                                      labelTimer.frame.size.width, 
                                      labelTimer.frame.size.height);
    } else if (anEvent.currentEventState == EventStateVotingWarning) {
        [self setVotingWarningTimerLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVotingWarningTimerLabel) name:TIMER_EVENT_MINUTE object:nil];
    }
        
    if (anEvent.currentEventState >= EventStateDecided) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.height = CellDashboardFeaturedEventHeight;
        cellBottomView.frame = CGRectMake(0, self.height-69.0, 300, 69);
        cellBottomAltView.frame = CGRectMake(0, self.height-69.0, 300, 69);
        cellBottomBg.frame = CGRectMake(0,self.height-69.0,300,69);
        separator.frame = CGRectMake(0,self.height-69.0,300,1);
    } else {
        self.height = CellDashboardFeaturedEventHeightWithTimer;
        cellBottomView.frame = CGRectMake(0, self.height-69.0, 300, 69);
        cellBottomAltView.frame = CGRectMake(0, self.height-69.0, 300, 69);
        cellBottomBg.frame = CGRectMake(0,self.height-69.0,300,69);
        separator.frame = CGRectMake(0,self.height-69.0,300,1);
    }
    
    if ([[anEvent getLocations] count] > 0) {
        cellBottomView.eventState = anEvent.currentEventState;
        if (anEvent.topLocationId) cellBottomView.location = [anEvent getLocationByLocationId:anEvent.topLocationId];
        else cellBottomView.location = [[anEvent getLocationsByLocationOrder:anEvent.currentLocationOrder] objectAtIndex:0];
        cellBottomView.hidden = NO;
        cellBottomAltView.hidden = YES;
    } else {
        cellBottomView.hidden = YES;
        cellBottomAltView.hidden = NO;
    }
}

- (void)setVotingWarningTimerLabel
{
    if (event.currentEventState == EventStateVotingWarning) {
        labelEndsIn.hidden = NO;
        labelTimer.hidden = NO;
        labelEndsIn.text = @"Voting ends in ";
        [labelEndsIn sizeToFit];
        labelTimer.text = [[[NSString alloc] initWithFormat:@"%i minute%@", event.minutesToGo, (event.minutesToGo != 1) ? @"s" : @""] autorelease];
        [labelTimer sizeToFit];
        labelTimer.frame = CGRectMake(labelEndsIn.frame.origin.x + labelEndsIn.frame.size.width, 
                                      labelTimer.frame.origin.y, 
                                      labelTimer.frame.size.width, 
                                      labelTimer.frame.size.height);
        
    } else if (event.currentEventState == EventStateVoting) {
        labelEndsIn.hidden = NO;
        labelTimer.hidden = NO;
        labelEndsIn.text = @"Voting is ";
        [labelEndsIn sizeToFit];
        labelTimer.text = @"open";
        [labelTimer sizeToFit];
        labelTimer.frame = CGRectMake(labelEndsIn.frame.origin.x + labelEndsIn.frame.size.width, 
                                      labelTimer.frame.origin.y, 
                                      labelTimer.frame.size.width, 
                                      labelTimer.frame.size.height);
    } else if (event.currentEventState >= EventStateDecided) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        labelEndsIn.hidden = NO;
        labelTimer.hidden = YES;
        labelEndsIn.text = @"Voting is closed";
        [labelEndsIn sizeToFit];
        [delegate eventReachedDecided:index];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [event release];
    self.delegate = nil;
    [super dealloc];
}

@end
