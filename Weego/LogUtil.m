//
//  LogUtil.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/* DEPRICATED
#import "LogUtil.h"


@implementation LogUtil

static LogUtil *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (LogUtil *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[LogUtil alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LogUtil.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}

- (id)init {
    if (self == [super init]) {
        //
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"LogUtil dealloc");
    [super dealloc];
}

- (void)clearLog
{
	[[Controller sharedInstance] clearLog];
}

- (void)log:(NSString*)msg
{	
    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString * logMessage = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:[NSDate date]], msg];
    
    NSLog(@"log: %@", logMessage);
    
#if !TOKEN_ENV_SANDBOX
//    NSLog(@"TOKEN_ENV==PRODUCTION, ignoring log messages");
#endif
    
#if TOKEN_ENV_SANDBOX
//    NSLog(@"TOKEN_ENV==SANDBOX");
    //[[Controller sharedInstance] writeStringToLog:logMessage];
#endif
    
	
    
	
}

@end
 */
