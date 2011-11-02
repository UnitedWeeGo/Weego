//
//  SynchMinuteTimer.h
//  TimerTest
//
//  Created by Dave Prukop on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYNCH_ONE_SECOND_TIMER_TICK @"synchOneSecondTimerTick"
#define SYNCH_FIVE_SECOND_TIMER_TICK @"synchFiveSecondTimerTick"
#define SYNCH_TEN_SECOND_TIMER_TICK @"synchTenSecondTimerTick"
#define SYNCH_THIRTY_SECOND_TIMER_TICK @"synchThirtySecondTimerTick"

@interface SynchMinuteTimer : NSObject {
    NSThread *oneSecondThread;
    NSThread *fiveSecondThread;
    NSThread *tenSecondThread;
    NSThread *thirtySecondThread;
    BOOL threadDone;
}

- (void)startTimer;
- (void)stopTimer;

@end
