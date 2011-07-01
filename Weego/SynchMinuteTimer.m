//
//  SynchMinuteTimer.m
//  TimerTest
//
//  Created by Dave Prukop on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynchMinuteTimer.h"

@interface SynchMinuteTimer(Private)

- (void)timerTick;
- (void)postNotification:(NSNotification *)aNotification;

@end


@implementation SynchMinuteTimer

- (id) init
{
    self = [super init];
    if (self)
    {
        threadDone = NO;
    }
    return self;
}

-(void)startTimer
{
    NSLog(@"startTimer");
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) 
        NSLog(@"startTimer in background...");
    newThread = [[NSThread alloc] initWithTarget:self selector:@selector(timerTick) object:nil];
    [newThread start];
    
    [self postNotification:[NSNotification notificationWithName:SYNCH_MINUTE_TIMER_TICK object:self]];
}

- (void)stopTimer
{
    NSLog(@"stopTimer");
    [newThread cancel];
    threadDone = YES;
    [newThread release];
}

- (void)dealloc 
{
    NSLog(@"SynchMinuteTimer dealloc");
    [super dealloc];
}

- (void)postNotification:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];
}

- (void)timerTick
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    while (!threadDone) {
        NSDate *now = [NSDate date];
        
//        NSTimeInterval nextMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / 60.0) * 60.0;
//        NSDate *nextMinute = [NSDate dateWithTimeIntervalSinceReferenceDate:nextMinuteInterval];
        
//        NSLog(@"SynchMinuteTimer tick");
        
        NSTimeInterval fiveSecondsInterval = ceil([now timeIntervalSinceReferenceDate] / 5) * 5;
        NSDate *nextFiveSeconds = [NSDate dateWithTimeIntervalSinceReferenceDate:fiveSecondsInterval];
        
        [NSThread sleepUntilDate:nextFiveSeconds];
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:SYNCH_MINUTE_TIMER_TICK object:self] waitUntilDone:YES];
    }
    
    [pool drain];
}

@end
