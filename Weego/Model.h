//
//  Model.h
//  BigBaby
//
//  Created by Nicholas Velloff on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;
@class Location;
@class Participant;
@class GoogleLocalObject;
@class GDataXMLElement;

typedef enum {
    AppStateBackground = 0,
    AppStateEntry,
    AppStateLogin,
    AppStateDashboard,
    AppStateCreateEvent,
    AppStateEventDetails
} AppState;

typedef enum {
    BGStateHome = 0,
    BGStateEvent,
    BGStateFeed,
    BGStateCreate
} BGState;

typedef enum {
    ViewStateEntry = 0,
    ViewStateLogin,
    ViewStateRegister,
    ViewStateDashboard,
    ViewStatePrefs,
    ViewStateCreate,
    ViewStateDetails,
    ViewStateMap,
    ViewStateAddParticipant,
    ViewStateEdit,
    ViewStateFeed,
    ViewStateInfo,
    ViewStateHelp
} ViewState;

typedef enum {
	EventStateNew = 0,
	EventStateVoting,
    EventStateVotingWarning,
    EventStateDecided,
    EventStateEnded
} EventState;

#define MODEL_EVENT_GENERIC_ERROR @"genericError"

@interface Model : NSObject {
	
}

@property (nonatomic, assign) AppState currentAppState;
@property (nonatomic, assign) BGState currentBGState;
@property (nonatomic, assign) ViewState currentViewState;

@property (nonatomic, retain) NSMutableDictionary *allEvents;
@property (nonatomic, retain) NSMutableArray *locations;
@property (nonatomic, retain) NSMutableArray *participants;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSMutableArray *reportedLocations;

@property (nonatomic, assign) BOOL isInTrial;
@property (nonatomic, assign) BOOL loginAfterTrial;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, copy) NSString *lastUpdateTimeStamp;

@property (nonatomic, retain) NSMutableArray *sortedEvents;
@property (nonatomic, retain) NSMutableArray *weeksEvents;
@property (nonatomic, retain) NSMutableArray *futureEvents;
@property (nonatomic, retain) NSMutableArray *pastEvents;

@property (nonatomic, retain) Participant *loginParticipant;

@property (nonatomic, retain) Event *currentEvent;

@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) NSDate *lastFetchAttempt;
@property (nonatomic, retain) NSDate *lastReportLocationAttempt;

@property (nonatomic, retain) NSMutableArray *googleLocalSearchResults;

@property (nonatomic, retain) NSMutableDictionary *pendingVoteRequests;
@property (nonatomic, retain) NSString *infoResults;
@property (nonatomic, retain) NSString *helpResults;

+ (Model *)sharedInstance;
+ (void)destroy;

- (void)clearData;
- (void)clearEvents;
- (void)sortEvents;
- (void)flushTempItems;

- (void)createTrialParticipant;
- (void)createLoginParticipantWithUserName:(NSString *)emailAddress andRegisteredId:(NSString *)registeredId;
- (void)assignInfoToLoginParticipant:(NSString *)registeredId andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andParticipantId:(NSString *)participantId andAvatarURL:(NSString *)avatarURL;
- (void)assignIdToLoginParticipant:(NSString *)registeredId;
- (void)replaceTrialParticipantsWithLoginParticipant;

- (void)assignLoginCredentialsWithUserName:(NSString *)emailAddress andPassword:(NSString *)password;
//- (void)assignRegisteredId:(NSString *)registeredId;

- (Event *)createNewEvent;
- (void)addOrUpdateEventWithXml:(GDataXMLElement *)eventXML inEventWithId:(NSString *)eventId withTimestamp:(NSString *)timestamp;
- (void)addEvent:(Event *)anEvent;
- (void)assignOfficialId:(NSString *)officialEventId toEventWithLocalId:(NSString *)localEventId;
- (void)setCurrentEventById:(NSString *)anId;
- (void)removeCurrentEvent;
- (void)addOrUpdateLocationOrder:(NSString *)order inEventWithId:(NSString *)eventId;
- (void)addOrUpdateVotes:(NSString *)iVotedFor inEventWithId:(NSString *)eventId overwrite:(BOOL)overwrite;
- (void)removeVote:(NSString *)locationId inEventWithId:(NSString *)eventId;
//- (void)addOrUpdateVotesForDashboard:(NSString *)iVotedFor inEventWithId:(NSString *)eventId;
- (void)markCheckedInEventWithId:(NSString *)eventId;

- (Location *)createNewLocationWithPlace:(Location *)location;
- (void)addOrUpdateLocationWithXml:(GDataXMLElement *)locationXML inEventWithId:(NSString *)eventId;
- (void)assignOfficialId:(NSString *)officialLocationId toLocationWithLocalId:(NSString *)localLocationId andHasDeal:(BOOL)hasDeal;
- (void)assignIdToWaitingLocation:(NSString *)locationId; // move to private
- (NSArray *)getLocationsForEventWithId:(NSString *)eventId;
- (void)removeLocationWithId:(NSString *)locationId fromEventWithId:(NSString *)eventId;

- (Participant *)createNewParticipantWithEmail:(NSString *)anEmailAddress; // andAddToEventWithId:(NSString *)anId;
- (void)addOrUpdateParticipantWithXml:(GDataXMLElement *)participantXML inEventWithId:(NSString *)eventId;
- (Participant *)getParticipantWithEmail:(NSString *)email fromEventWithId:(NSString *)eventId;
- (void)assignRegisteredInfoToParticipantWithEmail:(NSString *)email inEventWithId:(NSString *)eventId andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andAvatarURL:(NSString *)avatarURL;
- (NSArray *)getParticipantsForEventWithId:(NSString *)eventId;

- (void)addFeedMessageWithXml:(GDataXMLElement *)messageXML inEventWithId:(NSString *)eventId;
- (void)updateUnreadMessageCount:(NSString *)messageCount inEventWithId:(NSString *)eventId;
- (NSArray *)getFeedMessagesForEventWithId:(NSString *)eventId;
- (void)markLocalFeedMessageReadForEventWithId:(NSString *)eventId;
- (int)getUnreadMessageCountForPastEvents;
- (int)getUnreadMessageCountForFutureEvents;

//- (void)addOrRemoveVoteWithXml:(GDataXMLElement *)voteXML inEventWithId:(NSString *)eventId;
//- (void)voteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email;
//- (void)removeVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email;
//- (BOOL)userWithEmailAddress:(NSString *)email didVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId;
- (BOOL)loginUserDidVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId;
//- (int)numberOfVotesForEventWithId:(NSString *)eventId;
//- (int)numberOfVotesForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId;
//- (NSArray *)getVotesForEventWithId:(NSString *)eventId;

- (Boolean)locationExistsInCurrentEvent:(Location *)aPlace;
- (Boolean)locationExistsUsingLatLngInCurrentEvent:(Location *)aPlace;

- (NSString *)getCreateEventXML:(NSArray *)events;
- (NSString *)getUpdateEventXML:(Event *)anEvent;
- (NSString *)getUpdateParticipantsXML:(NSArray *)participantsArray withEventId:(NSString *)anEventId;
- (NSString *)getToggleVotesXML:(NSArray *)locationIds withEventId:(NSString *)anEventId;

- (void)addOrUpdateReportedLocationWithXml:(GDataXMLElement *)reportedLocXML inEventWithId:(NSString *)eventId;
- (NSArray *)getReportedLocationsForEventWithId:(NSString *)eventId;
- (void)updateReportedLocationsTimestamp:(NSString *)timestamp inEventWithId:(NSString *)eventId;

- (void)addPendingVoteRequestToLocationWithId:(NSString *)locationId withRequestId:(NSString *)requestId;
- (void)removePendingVoteRequestWithRequestId:(NSString *)requestId;
- (BOOL)locationWithIdHasPendingVoteRequest:(NSString *)locationId;
- (NSString *)locationWithRequestId:(NSString *)requestId;
- (NSString *)getAddOrUpdateLocationXMLForLocations:(NSArray *)locations withEventId:(NSString *)anEventId;

@end