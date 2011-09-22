//
//  SynchMinuteTimer.m
//  TimerTest
//
//  Created by Dave Prukop on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SynchMinuteTimer.h"

@interface SynchMinuteTimer(Private)

- (void)fiveSecondTick;
- (void)tenSecondTick;
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
    fiveSecondThread = [[NSThread alloc] initWithTarget:self selector:@selector(fiveSecondTick) object:nil];
    [fiveSecondThread start];
    
    tenSecondThread = [[NSThread alloc] initWithTarget:self selector:@selector(tenSecondTick) object:nil];
    [tenSecondThread start];
    
    thirtySecondThread = [[NSThread alloc] initWithTarget:self selector:@selector(thirtySecondTick) object:nil];
    [thirtySecondThread start];
    
    [self postNotification:[NSNotification notificationWithName:SYNCH_FIVE_SECOND_TIMER_TICK object:self]];
}

- (void)stopTimer
{
    NSLog(@"stopTimer");
    [fiveSecondThread cancel];
    [tenSecondThread cancel];
    [thirtySecondThread cancel];
    threadDone = YES;
    [fiveSecondThread release];
    [tenSecondThread release];
    [thirtySecondThread release];
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

- (void)fiveSecondTick
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    while (!threadDone) {
        NSDate *now = [NSDate date];
        
        NSTimeInterval fiveSecondsInterval = ceil([now timeIntervalSinceReferenceDate] / 5) * 5;
        NSDate *nextFiveSeconds = [NSDate dateWithTimeIntervalSinceReferenceDate:fiveSecondsInterval];
        
        [NSThread sleepUntilDate:nextFiveSeconds];
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:SYNCH_FIVE_SECOND_TIMER_TICK object:self] waitUntilDone:YES];
    }
    
    [pool drain];
}

- (void)tenSecondTick
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    while (!threadDone) {
        NSDate *now = [NSDate date];
        
        NSTimeInterval tenSecondsInterval = ceil([now timeIntervalSinceReferenceDate] / 10) * 10;
        NSDate *nextTenSeconds = [NSDate dateWithTimeIntervalSinceReferenceDate:tenSecondsInterval];
        
        [NSThread sleepUntilDate:nextTenSeconds];
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:SYNCH_TEN_SECOND_TIMER_TICK object:self] waitUntilDone:YES];
    }
    
    [pool drain];
}

- (void)thirtySecondTick
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    while (!threadDone) {
        NSDate *now = [NSDate date];
        
        NSTimeInterval thirtySecondsInterval = ceil([now timeIntervalSinceReferenceDate] / 30) * 30;
        NSDate *nextThirtySeconds = [NSDate dateWithTimeIntervalSinceReferenceDate:thirtySecondsInterval];
        
        [NSThread sleepUntilDate:nextThirtySeconds];
        [self performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:SYNCH_THIRTY_SECOND_TIMER_TICK object:self] waitUntilDone:YES];
    }
    
    [pool drain];
}


@end
