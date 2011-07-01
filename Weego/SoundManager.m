//
//  SoundManager.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

@interface SoundManager (Private)

- (void)initSounds;

@end

@implementation SoundManager

static SoundManager *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle

+ (SoundManager *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[SoundManager alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton SoundManager.");
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
        [self initSounds];
    }
    return self;
}

- (void)initSounds
{
    sounds = [[NSMutableDictionary alloc] init];
    NSArray *fileNames = [NSArray arrayWithObjects:@"ReceivedMessage", @"SentMessage", @"sms-received", nil];
    
    NSMutableArray *allKeys = [[[NSMutableArray alloc] init] autorelease];
    [allKeys addObject:[NSNumber numberWithInteger:SoundManagerSoundIdFeedMessageReceived]];
    [allKeys addObject:[NSNumber numberWithInteger:SoundManagerSoundIdFeedMessageSent]];
    [allKeys addObject:[NSNumber numberWithInteger:SoundManagerSoundIdInvite]];
    
    NSString *sndPath;
    CFURLRef sndURL;
    SystemSoundID ssid;
    for (int i=0; i<[allKeys count]; i++) {
        sndPath = [[NSBundle mainBundle]
                   pathForResource:[fileNames objectAtIndex:i]
                   ofType:@"wav"
                   inDirectory:@"/"];
        sndURL = (CFURLRef)[[[NSURL alloc]
                            initFileURLWithPath:sndPath] autorelease];
        
        NSNumber *keyObj = [allKeys objectAtIndex:i];
        AudioServicesCreateSystemSoundID(sndURL, &ssid);
        
        NSNumber *sndObj = [NSNumber numberWithInt:ssid];
        [sounds setObject:sndObj forKey:keyObj];
    }
}
- (void)playSoundWithId:(SoundManagerSoundId)soundId withVibration:(BOOL)doVibrate
{
    if (soundId > SoundManagerSoundIdNone)
    {
        NSNumber *sndObj = [sounds objectForKey:[NSNumber numberWithInt:soundId]];
        AudioServicesPlaySystemSound([sndObj intValue]);
    }
    if (doVibrate) AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) dealloc
{
    NSLog(@"SoundManager dealloc");
    NSEnumerator* iterator = [sounds objectEnumerator];
    NSNumber *sndObj;
    while( (sndObj = [iterator nextObject]) )
    {
        AudioServicesDisposeSystemSoundID([sndObj intValue]);
    }
    [sounds removeAllObjects];
    [sounds release];
    [super dealloc];
}

@end
