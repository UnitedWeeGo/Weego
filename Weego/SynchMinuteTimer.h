//
//  SynchMinuteTimer.h
//  TimerTest
//
//  Created by Dave Prukop on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYNCH_FIVE_SECOND_TIMER_TICK @"synchFiveMinuteTimerTick"
#define SYNCH_TEN_SECOND_TIMER_TICK @"synchTenMinuteTimerTick"

@interface SynchMinuteTimer : NSObject {
    NSThread *fiveSecondThread;
    NSThread *tenSecondThread;
    BOOL threadDone;
}

- (void)startTimer;
- (void)stopTimer;

@end
