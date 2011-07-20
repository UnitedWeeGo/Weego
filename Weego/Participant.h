//
//  Participant.h
//  BigBaby
//
//  Created by Nicholas Velloff on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GDataXMLElement;

@interface Participant : NSObject {
	NSString *ownerEventId;
	NSString *firstName;
	NSString *lastName;
	NSString *email;
    NSString *avatarURL;
    BOOL isTemporary;
    BOOL isTrialParticipant;
    BOOL hasBeenPaired;
}

@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic) BOOL isTemporary;
@property (nonatomic) BOOL isTrialParticipant;
@property (nonatomic) BOOL hasBeenRemoved;
@property (nonatomic) BOOL hasBeenPaired;

- (void)populateWithXml:(GDataXMLElement *)xml;

@end
