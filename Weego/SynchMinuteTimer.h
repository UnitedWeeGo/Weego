//
//  SynchMinuteTimer.h
//  TimerTest
//
//  Created by Dave Prukop on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYNCH_MINUTE_TIMER_TICK @"synchMinuteTimerTick"


@interface SynchMinuteTimer : NSObject {
//    NSThread *timerThread;
//    NSRunLoop *runLoop;
//    NSTimer *synchTimer;
    
    NSThread *newThread;
    BOOL threadDone;
}

- (void)startTimer;
- (void)stopTimer;

@end
