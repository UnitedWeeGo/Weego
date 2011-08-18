//
//  HeaderViewDetailsEvent.m
//  BigBaby
//
//  Created by Dave Prukop on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderViewDetailsEvent.h"

@interface HeaderViewDetailsEvent (Private)

- (void)setVotingWarningTimerLabel;
- (void)editEventPressed:(id)sender;
    
@end

@implementation HeaderViewDetailsEvent

@synthesize event, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nextY = 11;
        cellView = [[SubViewEventInfo alloc] initWithFrame:CGRectMake(5, nextY, 300, 50)];
        [self addSubview:cellView];
        [cellView release];
        nextY = cellView.frame.origin.y + cellView.frame.size.height + 1;
        
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
                
        nextY = labelEndsIn.frame.origin.y + labelEndsIn.frame.size.height - 4;
        
        editDisclosure = [UIButton buttonWithType:UIButtonTypeCustom];
        editDisclosure.frame = CGRectMake(276, 30, 32, 32);
        [editDisclosure setImage:[UIImage imageNamed:@"icon_chevron_edit_01.png"] forState:UIControlStateNormal];
        [editDisclosure addTarget:self action:@selector(editEventPressed:) forControlEvents:UIControlEventTouchUpInside];
        editDisclosure.hidden = YES;
        [self addSubview:editDisclosure];
        
        self.frame = CGRectMake(self.frame.origin.x, 
                                self.frame.origin.y, 
                                self.frame.size.width, 
                                nextY);
    }
    return self;
}

- (void)setEvent:(Event *)anEvent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [event release];
    event = anEvent;
    [event retain];
    cellView.event = anEvent;
    
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVotingWarningTimerLabel) name:SYNCH_FIVE_SECOND_TIMER_TICK object:nil];
    } else if (anEvent.currentEventState >= EventStateDecided) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        nextY = cellView.frame.origin.y + cellView.frame.size.height;
        self.frame = CGRectMake(self.frame.origin.x, 
                                self.frame.origin.y, 
                                self.frame.size.width, 
                                nextY);
    }
    if ([anEvent.creatorId isEqualToString:[Model sharedInstance].userEmail] && anEvent.currentEventState < EventStateDecided) {
        editDisclosure.hidden = NO;
    }
}

- (void)setVotingWarningTimerLabel
{
//    NSLog(@"minutesToGo = %i", event.minutesToGo);
    if (event.minutesToGoUntilVotingEnds > 0) {
        labelEndsIn.hidden = NO;
        labelTimer.hidden = NO;
        labelEndsIn.text = @"Voting ends in ";
        [labelEndsIn sizeToFit];
        labelTimer.text = [[[NSString alloc] initWithFormat:@"%i minute%@", event.minutesToGoUntilVotingEnds, (event.minutesToGoUntilVotingEnds != 1) ? @"s" : @""] autorelease];
        [labelTimer sizeToFit];
        labelTimer.frame = CGRectMake(labelEndsIn.frame.origin.x + labelEndsIn.frame.size.width, 
                                      labelTimer.frame.origin.y, 
                                      labelTimer.frame.size.width, 
                                      labelTimer.frame.size.height);
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        labelEndsIn.hidden = NO;
        labelTimer.hidden = YES;
        editDisclosure.hidden = YES;
        labelEndsIn.text = @"Voting is closed";
        [labelEndsIn sizeToFit];
        [delegate eventReachedDecided];
    }
}

- (void)editEventPressed:(id)sender
{
    if ([delegate respondsToSelector:@selector(editEventRequested)]) [delegate editEventRequested];
}

- (void)dealloc
{
    NSLog(@"HeaderViewDetailsEvent dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [event release];
    self.delegate = nil;
    [super dealloc];
}

@end
