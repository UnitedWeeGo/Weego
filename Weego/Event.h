//
//  Event.h
//  BigBaby
//
//  Created by Nicholas Velloff on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "NSDate+Helper.h"

enum {
    AcceptanceTypePending,
	AcceptanceTypeAccepted,
    AcceptanceTypeDeclined
};
typedef NSInteger AcceptanceType;

@class Participant;
@class Location;

@interface Event : NSObject {
	NSString *participantCount;
}

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *eventTitle;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSString *acceptedParticipantList;
@property (nonatomic, copy) NSString *declinedParticipantList;
@property (nonatomic, copy) NSString *checkedInParticipantList;
@property (nonatomic, copy) NSString *lastUpdatedTimestamp;
@property (nonatomic, copy) NSString *lastReportedLocationsTimestamp;
@property (nonatomic, copy) NSString *currentLocationOrder;
@property (nonatomic, copy) NSString *participantCount;
@property (nonatomic, copy) NSString *unreadMessageCount;
@property (nonatomic, copy) NSString *topLocationId;

@property (nonatomic, retain) NSDate *eventDate;
@property (nonatomic, retain) NSDate *eventExpireDate;

@property (nonatomic) BOOL isTemporary;
@property (nonatomic) EventState currentEventState;
@property (nonatomic, readonly) int minutesToGoUntilVotingEnds;
@property (nonatomic, readonly) int minutesToGoUntilEventStarts;
@property (nonatomic) BOOL eventRead;
@property (nonatomic) BOOL hasBeenCheckedIn;
@property (nonatomic) BOOL hasPendingCheckin;

@property (nonatomic, retain) NSArray *iVotedFor;
@property (nonatomic, retain) NSArray *updatedVotes;
@property (nonatomic, readonly) AcceptanceType acceptanceStatus;
@property (nonatomic, assign) BOOL hasBeenRemoved;
@property (nonatomic, assign) BOOL hasBeenCancelled;
@property (nonatomic, readonly) BOOL iOwnEvent;
@property (nonatomic, readonly) BOOL shouldReportUserLocation;
@property (nonatomic, readonly) BOOL shouldAttemptCheckin;
@property (nonatomic, readonly) BOOL requiresLocationManagement;
@property (nonatomic) BOOL forcedDecided;

- (id)initWithId:(NSString *)anId;

- (void)populateWithXml:(GDataXMLElement *)xml;

- (NSArray *)getLocations;
- (NSArray *)getLocationsSortedByLocationId;
- (NSArray *)getLocationsByLocationOrder:(NSString *)order;
//- (NSArray *)getLocationsSortedByVotes;
- (Location *)getLocationWithUUID:(NSString *)uuid;
- (Location *)getLocationByLocationId:(NSString *)locationId;
- (Location *)getTopLocation;

- (NSArray *)getParticipants;
- (NSArray *)getParticipantsSortedByName;

- (AcceptanceType)acceptanceStatusForUserWithEmail:(NSString *)email;
- (BOOL)userHasCheckedInWithEmail:(NSString *)email;

- (BOOL)loginUserDidVoteForLocationWithId:(NSString *)locationId;
//- (int)numberOfVotesForLocationWithId:(NSString *)locationId;
//- (int)numberOfVotesTotal;
//- (NSArray *)getVotes;

- (NSArray *)getFeedMessages;
- (NSArray *)getReportedLocations;

- (void)setDefaultTime;
- (NSString *)getFormattedDateString;
- (NSString *)getTimestampDateString;

- (NSString *)getCreatorFullName;
- (NSString *)getCreatorAvatarURL;

- (void)addVoteWithLocationId:(NSString *)locationId;
- (void)removeVoteFromLocationWithId:(NSString *)locationId;
- (void)clearNewVotes;

@end