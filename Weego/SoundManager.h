//
//  SoundManager.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
    SoundManagerSoundIdNone = 0,
    SoundManagerSoundIdFeedMessageReceived,
    SoundManagerSoundIdFeedMessageSent,
    SoundManagerSoundIdInvite
} SoundManagerSoundId;

@interface SoundManager : NSObject {
    NSMutableDictionary *sounds;
}

+ (SoundManager *)sharedInstance;
+ (void)destroy;
- (void)playSoundWithId:(SoundManagerSoundId)soundId withVibration:(BOOL)doVibrate;

@end
