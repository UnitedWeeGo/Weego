//
//  Event.h
//  BigBaby
//
//  Created by Nicholas Velloff on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

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
@property (nonatomic, retain) NSDate *eventDate;
@property (nonatomic, retain) NSDate *eventExpireDate;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, copy) NSString *creatorId;
@property (nonatomic, copy) NSString *acceptedParticipantList;
@property (nonatomic, copy) NSString *declinedParticipantList;
@property (nonatomic, copy) NSString *lastUpdatedTimestamp;
@property (nonatomic, copy) NSString *lastReportedLocationsTimestamp;
@property (nonatomic) BOOL isTemporary;
@property (nonatomic) EventState currentEventState;
@property (nonatomic, copy) NSString *topLocationId;
@property (nonatomic, copy) NSString *participantCount;
@property (nonatomic, copy) NSString *unreadMessageCount;
@property (nonatomic, readonly) int minutesToGo;
@property (nonatomic, copy) NSString *eventRead;
@property (nonatomic) BOOL hasBeenCheckedIn;
@property (nonatomic, copy) NSString *currentLocationOrder;
@property (nonatomic, retain) NSArray *iVotedFor;
@property (nonatomic, retain) NSArray *updatedVotes;
@property (nonatomic, readonly) AcceptanceType acceptanceStatus;

- (id)initWithId:(NSString *)anId;

- (void)populateWithXml:(GDataXMLElement *)xml;

- (NSArray *)getLocations;
- (NSArray *)getLocationsSortedByLocationId;
- (NSArray *)getLocationsByLocationOrder:(NSString *)order;
//- (NSArray *)getLocationsSortedByVotes;
- (Location *)getLocationWithUUID:(NSString *)uuid;
- (Location *)getLocationByLocationId:(NSString *)locationId;

- (NSArray *)getParticipants;
- (NSArray *)getParticipantsSortedByName;

- (AcceptanceType)acceptanceStatusForUserWithEmail:(NSString *)email;

- (BOOL)loginUserDidVoteForLocationWithId:(NSString *)locationId;
//- (int)numberOfVotesForLocationWithId:(NSString *)locationId;
//- (int)numberOfVotesTotal;
//- (NSArray *)getVotes;

- (NSArray *)getFeedMessages;
- (NSArray *)getReportedLocations;

- (NSString *)getFormattedDateString;
- (NSString *)getTimestampDateString;

- (NSString *)getCreatorFullName;
- (NSString *)getCreatorAvatarURL;

- (void)addVoteWithLocationId:(NSString *)locationId;
- (void)removeVoteFromLocationWithId:(NSString *)locationId;
- (void)clearNewVotes;

@end