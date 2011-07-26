//
//  Model.m
//  BigBaby
//
//  Created by Nicholas Velloff on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Model.h"
#import "Event.h"
#import "Location.h"
#import "Participant.h"
#import "Vote.h"
#import "DataParser.h"
#import "GDataXMLNode.h"
#import "FeedMessage.h"
#import "ReportedLocation.h"
#import "SuggestedTime.h"

@interface Model (Private)

- (NSString*) stringWithUUID;
- (void)sortEvents;
- (Event *)getEventById:(NSString *) eventId;
- (Location *)getLocationWithId:(NSString *)locationId fromEventWithId:(NSString *)eventId;
- (Vote *)getVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email;
- (SuggestedTime *)getSuggestedTimeWithId:(NSString *)suggestedMessageId fromEventWithId:(NSString *)eventId;
- (FeedMessage *)getFeedMessageWithId:(NSString *)messageId fromEventWithId:(NSString *)eventId;
- (ReportedLocation *)getReportedLocationWithUserId:(NSString *)reporterEmail fromEventWithId:(NSString *)eventId;

@end

@implementation Model

@synthesize currentAppState, currentBGState, currentViewState;
@synthesize allEvents, locations, participants, messages, reportedLocations;
@synthesize isInTrial, loginAfterTrial;
@synthesize userId, userEmail, userPassword, lastUpdateTimeStamp;
@synthesize sortedEvents, weeksEvents, futureEvents, pastEvents; //daysEvents
@synthesize loginParticipant;
@synthesize currentEvent;
@synthesize deviceToken;
@synthesize lastFetchAttempt, lastReportLocationAttempt;
@synthesize geoSearchResults;
@synthesize pendingVoteRequests;
@synthesize infoResults;
@synthesize helpResults;
@synthesize simpleGeoCategoryResults;
@synthesize suggestedTimes;

static Model *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (Model *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[Model alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton Model.");
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
        NSMutableDictionary *tAllEvents = [[NSMutableDictionary alloc] init];
		self.allEvents = tAllEvents;
        [tAllEvents release];
        
        NSMutableArray *tLocations = [[NSMutableArray alloc] init];
		self.locations = tLocations;
        [tLocations release];
        
        NSMutableArray *tParticipants = [[NSMutableArray alloc] init];
		self.participants = tParticipants;
        [tParticipants release];
        
//        NSMutableArray *tVotes = [[NSMutableArray alloc] init];
//		self.votes = tVotes;
//        [tVotes release];
        
        NSMutableArray *tMessages = [[NSMutableArray alloc] init];
		self.messages = tMessages;
        [tMessages release];
        
        NSMutableArray *tSuggestedTimes = [[NSMutableArray alloc] init];
		self.suggestedTimes = tSuggestedTimes;
        [tSuggestedTimes release];
        
        NSMutableArray *tReportedLocations = [[NSMutableArray alloc] init];
		self.reportedLocations = tReportedLocations;
        [tReportedLocations release];
        
        NSMutableDictionary *tPendingVoteRequests = [[NSMutableDictionary alloc] init];
        self.pendingVoteRequests = tPendingVoteRequests;
        [tPendingVoteRequests release];
    }
    return self;
}

- (void) dealloc
{
	NSLog(@"Model dealloc");
	[self.userId release];
	[self.userEmail release];
	[self.userPassword release];
	[self.lastUpdateTimeStamp release];
    
    [self.locations removeAllObjects];
	[self.locations release];
    
    [self.participants removeAllObjects];
	[self.participants release];
    
//    [self.votes removeAllObjects];
//	[self.votes release];
    [self.suggestedTimes removeAllObjects];
	[self.suggestedTimes release];
    
    [self.messages removeAllObjects];
	[self.messages release];
    
    [self.reportedLocations removeAllObjects];
	[self.reportedLocations release];

    [self.sortedEvents removeAllObjects];
    [self.sortedEvents release];
    
    [self.weeksEvents removeAllObjects];
    [self.weeksEvents release];
    
    [self.futureEvents removeAllObjects];
    [self.futureEvents release];
    
    [self.pastEvents removeAllObjects];
    [self.pastEvents release];
    
    [self.loginParticipant release];
    
    [self.currentEvent release];
    
    [self.allEvents removeAllObjects];
	[self.allEvents release];
    
    [self.deviceToken release];
    [self.lastFetchAttempt release];
    [self.lastReportLocationAttempt release];
    
    [self.geoSearchResults release];
    
    [self.pendingVoteRequests release];
    [self.infoResults release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Data

- (void)clearData
{
    [self clearEvents];
    
    self.userId = nil;
    self.userEmail = nil;
    self.userPassword = nil;
    self.lastUpdateTimeStamp = nil;
}

- (void)clearEvents
{
    [self.allEvents removeAllObjects];
	NSMutableDictionary *tAllEvents = [[NSMutableDictionary alloc] init];
    self.allEvents = tAllEvents;
    [tAllEvents release];
    [self sortEvents];
    
    [self.locations removeAllObjects];
    NSMutableArray *tAllLocations = [[NSMutableArray alloc] init];
    self.locations = tAllLocations;
    [tAllLocations release];
    
    [self.participants removeAllObjects];
    NSMutableArray *tAllParticipants = [[NSMutableArray alloc] init];
    self.participants = tAllParticipants;
    [tAllParticipants release];
    
    [self.suggestedTimes removeAllObjects];
    NSMutableArray *tAllSuggestedTimes = [[NSMutableArray alloc] init];
    self.suggestedTimes = tAllSuggestedTimes;
    [tAllSuggestedTimes release];
    
    [self.messages removeAllObjects];
    NSMutableArray *tAllMessages = [[NSMutableArray alloc] init];
    self.messages = tAllMessages;
    [tAllMessages release];
    
    [self.reportedLocations removeAllObjects];
    NSMutableArray *tAllReportedLocations = [[NSMutableArray alloc] init];
    self.reportedLocations = tAllReportedLocations;
    [tAllReportedLocations release];
}

- (void)sortEvents
{
    NSMutableArray *tSortedEvents = [[NSMutableArray alloc] init];
    self.sortedEvents = tSortedEvents;
    [tSortedEvents release];
	[self.sortedEvents addObjectsFromArray:[self.allEvents allValues]];
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:NO selector:@selector(compare:)] autorelease];
	[self.sortedEvents sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];

    NSMutableArray *tWeeksEvents = [[NSMutableArray alloc] init];
    self.weeksEvents = tWeeksEvents;
    [tWeeksEvents release];
	
    NSMutableArray *tFutureEvents = [[NSMutableArray alloc] init];
    self.futureEvents = tFutureEvents;
	[tFutureEvents release];
	
    NSMutableArray *tPastEvents = [[NSMutableArray alloc] init];
    self.pastEvents = tPastEvents;
	[tPastEvents release];
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayMidnightComps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];   
    NSDate *todayMidnight = [gregorian dateFromComponents:todayMidnightComps];
    [gregorian release];
	
    NSMutableArray *weeksEventsPast = [[NSMutableArray alloc] init];
    NSMutableArray *weeksEventsFuture = [[NSMutableArray alloc] init];
    
	for (Event *ev in self.sortedEvents) {
		float dayDiff = [ev.eventDate timeIntervalSinceDate:todayMidnight] / (60*60*24);
        if (dayDiff >= 0 && dayDiff <= 7) {
            if ([ev.eventDate timeIntervalSinceNow] < 0) [weeksEventsPast addObject:ev];
            else [weeksEventsFuture addObject:ev];
		} else if (dayDiff > 7) {
			[self.futureEvents addObject:ev];
		} else {
			[self.pastEvents addObject:ev];
		}
	}
    
//    NSLog(@"weeksEventsPast count = %i", [weeksEventsPast count]);
//    NSLog(@"weeksEventsFuture count = %i", [weeksEventsFuture count]);
    
    NSSortDescriptor *futureSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"eventDate" ascending:YES selector:@selector(compare:)] autorelease];
	[self.futureEvents sortUsingDescriptors:[NSArray arrayWithObjects:futureSortDescriptor, nil]];
    [weeksEventsFuture sortUsingDescriptors:[NSArray arrayWithObjects:futureSortDescriptor, nil]];
    
    [self.weeksEvents addObjectsFromArray:weeksEventsFuture];
    [self.weeksEvents addObjectsFromArray:weeksEventsPast];
    [weeksEventsPast release];
    [weeksEventsFuture release];
    
    if ([self.weeksEvents count] == 0 && [self.futureEvents count] > 0) {
        Event *firstFuture = [self.futureEvents objectAtIndex:0];
        [self.weeksEvents addObject:firstFuture];
        [self.futureEvents removeObject:firstFuture];
    }
}

- (void)flushTempItems
{
    for (Event *e in [self.allEvents allValues]) {
        if (e.isTemporary) [self.allEvents removeObjectForKey:e.eventId];
    }
    NSMutableArray *removedLocations = [[NSMutableArray alloc] init];
    for (Location *l in self.locations) {
        if (l.isTemporary) [removedLocations addObject:l];
    }
    for (Location *l in removedLocations) {
        [self.locations removeObject:l];
    }
    [removedLocations release];
    NSMutableArray *removedParticipants = [[NSMutableArray alloc] init];
    for (Participant *p in self.participants) {
        if (p.isTemporary) [removedParticipants addObject:p];
    }
    for (Participant *p in removedParticipants) {
        [self.participants removeObject:p];
    }
    [removedParticipants release];
//    NSMutableArray *removedVotes = [[NSMutableArray alloc] init];
//    for (Vote *v in self.votes) {
//        if (v.isTemporary) [removedVotes addObject:v];
//    }
//    for (Vote *v in removedVotes) {
//        [self.votes removeObject:v];
//    }
//    [removedVotes release];
}

#pragma mark -
#pragma mark Login

- (void)createTrialParticipant
{
    Participant *tLoginParticipant = [[Participant alloc] init];
    self.loginParticipant = tLoginParticipant;
    [tLoginParticipant release];
    self.loginParticipant.email = @"Me";
//    self.loginParticipant.isTrialParticipant = YES;
    self.userEmail = @"Me";
}

// See if we still need this
- (void)createLoginParticipantWithUserName:(NSString *)emailAddress andRegisteredId:(NSString *)registeredId
{
	if (!registeredId) {
        Participant *tLoginParticipant = [[Participant alloc] init];
		self.loginParticipant = tLoginParticipant;
        [tLoginParticipant release];
		self.loginParticipant.email = [emailAddress lowercaseString];
	}
}

- (void)assignInfoToLoginParticipant:(NSString *)registeredId andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andParticipantId:(NSString *)participantId andAvatarURL:(NSString *)avatarURL
{
	self.lastUpdateTimeStamp = nil;
	self.userId = registeredId;
	self.userEmail = participantId; //[loginParticipant.email lowercaseString];
    Participant *tLoginParticipant = [[Participant alloc] init];
    self.loginParticipant = tLoginParticipant;
    [tLoginParticipant release];
	self.loginParticipant.firstName = firstName;
	self.loginParticipant.lastName = lastName;
    self.loginParticipant.avatarURL = avatarURL;
    self.loginParticipant.email = participantId;
}

- (void)assignIdToLoginParticipant:(NSString *)registeredId
{
//	NSLog(@"assignIdToLoginParticipant: %@", registeredId);
	self.lastUpdateTimeStamp = nil;
	self.userId = registeredId;
	self.userEmail = loginParticipant.email;
}

- (void)replaceTrialParticipantsWithLoginParticipant
{
    for (Participant *p in participants) {
        if (p.isTrialParticipant) {
            p.firstName = self.loginParticipant.firstName;
            p.lastName = self.loginParticipant.lastName;
            p.avatarURL = self.loginParticipant.avatarURL;
            p.email = self.loginParticipant.email;
            p.isTrialParticipant = NO;
        }
    }
}

#pragma mark -
#pragma mark Register

- (void)assignLoginCredentialsWithUserName:(NSString *)emailAddress andPassword:(NSString *)password
{
	self.userEmail = [emailAddress lowercaseString];
	self.userPassword = password;
}

#pragma mark -
#pragma mark Events

- (Event *)createNewEvent
{
	Event *event = [[[Event alloc] init] autorelease];
    event.eventId = [self stringWithUUID];
    event.isTemporary = YES;
	event.creatorId = userEmail;
    NSDate *now = [NSDate date];
    int minuteInterval = 5;
    NSTimeInterval nextAllowedMinuteInterval = ceil([now timeIntervalSinceReferenceDate] / (60 * minuteInterval)) * (60 * minuteInterval) + (60 * 60); // One hour ahead rounded up to the nearest minuteInterval
    NSDate *defaultStartTime = [NSDate dateWithTimeIntervalSinceReferenceDate:nextAllowedMinuteInterval];
    event.eventDate = defaultStartTime;
    [self addEvent:event];
    self.currentEvent = event;
    Participant *p = [[Participant alloc] init];
    p.firstName = self.loginParticipant.firstName;
    p.lastName = self.loginParticipant.lastName;
    p.avatarURL = self.loginParticipant.avatarURL;
    p.email = self.loginParticipant.email;
    p.isTrialParticipant = self.isInTrial;
    p.ownerEventId = self.currentEvent.eventId;
    [self.participants addObject:p];
    [p release];
//    [self createNewParticipantWithEmail:userEmail];
	return event;
}

- (void)addOrUpdateEventWithXml:(GDataXMLElement *)eventXML inEventWithId:(NSString *)eventId withTimestamp:(NSString *)timestamp
{
    if ([self.allEvents objectForKey:eventId]) {
        Event *event = [self.allEvents objectForKey:eventId];
       if (timestamp != nil)    event.lastUpdatedTimestamp = timestamp;
        [event populateWithXml:eventXML];
        event.isTemporary = NO;
    } else {
        Event *event = [[Event alloc] init];
        event.eventId = eventId;
        if (timestamp != nil)   event.lastUpdatedTimestamp = timestamp;
        [event populateWithXml:eventXML];
        event.isTemporary = NO;
        [self.allEvents setObject:event forKey:eventId];
        [event release];
    }
}

- (void)markCheckedInEventWithId:(NSString *)eventId
{
    Event *event = [self.allEvents objectForKey:eventId];
    event.hasBeenCheckedIn = YES;
}

- (void)addEvent:(Event *)anEvent
{
    // Add condition for create event state. include notification here.
	if ([self.allEvents objectForKey:anEvent.eventId]) {
        [self sortEvents];
	} else {
		[self.allEvents setObject:anEvent forKey:anEvent.eventId];
        [self sortEvents];
	}
}

- (void)assignOfficialId:(NSString *)officialEventId toEventWithLocalId:(NSString *)localEventId
{
    
    for (Event *e in [self.allEvents allValues]) {
        if ([e.eventId isEqualToString:localEventId]) {
            e.isTemporary = NO;
            e.eventId = officialEventId;
            [self.allEvents setObject:e forKey:officialEventId];
            [self.allEvents removeObjectForKey:localEventId];
        }
    }
    for (Location *l in self.locations) {
        if ([l.ownerEventId isEqualToString:localEventId]) {
//            l.isTemporary = NO;
            l.ownerEventId = officialEventId;
        }
    }
    for (Participant *p in self.participants) {
        if ([p.ownerEventId isEqualToString:localEventId]) {
            p.isTemporary = NO;
            p.ownerEventId = officialEventId;
        }
    }
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:localEventId]) {
////            v.isTemporary = NO;
//            v.ownerEventId = officialEventId;
//        }
//    }
}

- (Event *)getEventById:(NSString *) eventId
{
	Event *ev = [self.allEvents objectForKey:eventId];
	if (ev != nil) return ev;
	return nil;
}

- (void)setCurrentEventById:(NSString *)anId
{
    if (anId) self.currentEvent = [self getEventById:anId];
    else self.currentEvent = nil;
}

- (void)removeCurrentEvent
{
    [self.allEvents removeObjectForKey:self.currentEvent.eventId];
    self.currentEvent = nil;
    [self sortEvents];
}

- (void)addOrUpdateLocationOrder:(NSString *)order inEventWithId:(NSString *)eventId
{
    Event *ev = [self.allEvents objectForKey:eventId];
    ev.currentLocationOrder = order;
    ev.topLocationId = [[order componentsSeparatedByString:@","] objectAtIndex:0];
}

- (void)addOrUpdateVotes:(NSString *)iVotedFor inEventWithId:(NSString *)eventId overwrite:(BOOL)overwrite
{
    Event *ev = [self.allEvents objectForKey:eventId];
    if (ev == nil) ev = currentEvent;
    if (overwrite) {
        ev.iVotedFor = [iVotedFor componentsSeparatedByString:@","];
        return;
    } else {
        NSMutableArray *votes = [[NSMutableArray alloc] initWithArray:ev.iVotedFor];
        NSArray *newVotes = [iVotedFor componentsSeparatedByString:@","];
        for (int i=0; i<[newVotes count]; i++) {
            BOOL isFound = NO;
            for (int j=0; j<[ev.iVotedFor count]; j++) {
                if ([[ev.iVotedFor objectAtIndex:j] isEqualToString:[newVotes objectAtIndex:i]]) {
                    isFound = YES;
                    break;
                }
            }
            if (!isFound) [votes addObject:[newVotes objectAtIndex:i]];
        }
        ev.iVotedFor = votes;
        [votes release];
    }
//    ev.locationOrder = order;
}

- (void)removeVote:(NSString *)locationId inEventWithId:(NSString *)eventId
{
    Event *ev = [self.allEvents objectForKey:eventId];
    if (ev == nil) ev = currentEvent;
    NSMutableArray *votes = [[NSMutableArray alloc] initWithArray:ev.iVotedFor];
    for (int j=0; j<[votes count]; j++) {
        if ([[votes objectAtIndex:j] isEqualToString:locationId]) {
            [votes removeObjectAtIndex:j];
        }
    }
    ev.iVotedFor = votes;
    [votes release];
}

//- (void)addOrUpdateVotesForDashboard:(NSString *)iVotedFor inEventWithId:(NSString *)eventId
//{
//    Event *ev = [self.allEvents objectForKey:eventId];
//    if (ev == nil) ev = currentEvent;
//    if (ev.iVotedFor == nil) ev.iVotedFor = iVotedFor;
//}

#pragma mark -
#pragma mark Locations

- (Boolean)locationExistsInCurrentEvent:(Location *)aPlace
{
    NSArray *savedLocations = [self.currentEvent getLocations];
    for (Location *loc in savedLocations) {
        if ([loc.g_id isEqualToString: aPlace.g_id]) return true;
    }
    return false;
}

- (Boolean)locationExistsUsingLatLngInCurrentEvent:(Location *)aPlace
{
    NSArray *savedLocations = [self.currentEvent getLocations];
    for (Location *loc in savedLocations) {
        if (loc.coordinate.latitude == aPlace.coordinate.latitude && loc.coordinate.longitude == loc.coordinate.longitude) return true;
    }
    return false;
}


- (Location *)createNewLocationWithPlace:(Location *)location
{
    location.ownerEventId = self.currentEvent.eventId;
    location.addedById = userEmail;
    location.tempId = [self stringWithUUID];
    location.locationId = [self stringWithUUID];
    location.isTemporary = YES;
    [self.locations addObject:location];
    return location;
}

- (void)addOrUpdateLocationWithXml:(GDataXMLElement *)locationXML inEventWithId:(NSString *)eventId
{
    NSString *locId = [[locationXML attributeForName:@"id"] stringValue];
    
//    NSString *removeLocStr = [[locationXML attributeForName:@"hasBeenRemoved"] stringValue];
//    BOOL removeLocation = [[removeLocStr lowercaseString] isEqualToString:@"true"];
    
    NSString *tempId = [[locationXML attributeForName:@"tempId"] stringValue];
    if (tempId) {
        [self assignOfficialId:locId toLocationWithLocalId:tempId andHasDeal:NO];
    }
    Location *loc = [self getLocationWithId:locId fromEventWithId:eventId];
    if (loc) {
        [loc populateWithXml:locationXML];
    } else {
        Location *loc = [[Location alloc] init];
        loc.ownerEventId = eventId;
        [loc populateWithXml:locationXML];
        [self.locations addObject:loc];
        [loc release];
    }
}

- (void)assignOfficialId:(NSString *)officialLocationId toLocationWithLocalId:(NSString *)localLocationId andHasDeal:(BOOL)hasDeal
{
    for (Location *l in self.locations) {
        if ([l.tempId isEqualToString:localLocationId]) {
            if (l.isTemporary == NO) return;
            l.isTemporary = NO;
            l.tempId = nil;
            l.locationId = officialLocationId;
            return;
//            l.hasDeal = hasDeal;
        }
    }
}

- (void)assignIdToWaitingLocation:(NSString *)locationId
{
//	NSLog(@"new location id = %@", locationId);
//	Location *identifiedLocation = [[pendingLocations allValues] objectAtIndex:0];  //locationWaitingForId;
//    [pendingLocations removeObjectForKey:identifiedLocation.locationId];
//	identifiedLocation.locationId = locationId;
//	[self addLocation:identifiedLocation toEventWithId:identifiedLocation.ownerEventId];
////	locationWaitingForId = nil;
//	[[NSNotificationCenter defaultCenter] postNotificationName:MODEL_EVENT_ADD_LOCATION_SUCCESS object:nil];
}

- (Location *)getLocationWithId:(NSString *)locationId fromEventWithId:(NSString *)eventId
{
    for (Location *loc in self.locations) {
        if ([loc.locationId isEqualToString:locationId] && [loc.ownerEventId isEqualToString:eventId]) return loc;
    }
	return nil;
}

- (NSArray *)getLocationsForEventWithId:(NSString *)eventId
{
    NSMutableArray *returnLocations = [[NSMutableArray alloc] init];
    for (Location *loc in self.locations) {
        if ([loc.ownerEventId isEqualToString:eventId] && !loc.hasBeenRemoved) [returnLocations addObject:loc];
    }
    return [returnLocations autorelease];
}

- (void)removeLocationWithId:(NSString *)locationId fromEventWithId:(NSString *)eventId
{
    Location *loc = [self getLocationWithId:locationId fromEventWithId:eventId];
    if (loc) [self.locations removeObject:loc];
    [[self getEventById:eventId] removeVoteFromLocationWithId:locationId];
}

#pragma mark -
#pragma mark Participants

- (Participant *)createNewParticipantWithEmail:(NSString *)anEmailAddress // andAddToEventWithId:(NSString *)anId
{
    Participant *participant = [[[Participant alloc] init] autorelease];
    participant.ownerEventId = self.currentEvent.eventId;
    participant.email = anEmailAddress;
    Participant *pairedParticipant = [self getPairedParticipantWithEmail:anEmailAddress];
    if (pairedParticipant) {
        participant.firstName = pairedParticipant.firstName;
        participant.lastName = pairedParticipant.lastName;
        participant.avatarURL = pairedParticipant.avatarURL;
    }
//    participant.isTrialParticipant = self.isInTrial;
    participant.isTemporary = YES;
    if ([self getParticipantWithEmail:anEmailAddress fromEventWithId:self.currentEvent.eventId] == nil) [self.participants addObject:participant];
    return participant;
}

- (void)addOrUpdateParticipantWithXml:(GDataXMLElement *)participantXML inEventWithId:(NSString *)eventId
{
    NSString *pEmail = [[participantXML attributeForName:@"email"] stringValue];
    Participant *p = [self getParticipantWithEmail:pEmail fromEventWithId:eventId];
    if (p) {
        [p populateWithXml:participantXML];
    } else {
        Participant *p = [[Participant alloc] init];
        p.ownerEventId = eventId;
        [p populateWithXml:participantXML];
        [self.participants addObject:p];
        [p release];
    }
}

- (Participant *)getParticipantWithEmail:(NSString *)email fromEventWithId:(NSString *)eventId
{
    for (Participant *p in self.participants) {
        if ([p.email isEqualToString:email] && [p.ownerEventId isEqualToString:eventId]) return p;
    }
	return nil;
}

- (Participant *)getPairedParticipantWithEmail:(NSString *)email
{
    for (Participant *p in self.participants) {
        if ([p.email isEqualToString:email] && p.hasBeenPaired) {
            NSLog(@"p %@", p.avatarURL);
            return p;
        }
    }
	return nil;
}

/*
- (void)assignRegisteredInfoToParticipantWithEmail:(NSString *)email inEventWithId:(NSString *)eventId andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andAvatarURL:(NSString *)avatarURL
{
    if (eventId) {
        Participant *identifiedParticipant = [self getParticipantWithEmail:email fromEventWithId:eventId];
        identifiedParticipant.firstName = firstName;
        identifiedParticipant.lastName = lastName;
        identifiedParticipant.avatarURL = avatarURL;
    }
}
 */

- (NSArray *)getParticipantsForEventWithId:(NSString *)eventId
{
    NSMutableArray *returnParticipants = [[NSMutableArray alloc] init];
    for (Participant *p in self.participants) {
        if ([p.ownerEventId isEqualToString:eventId] && !p.hasBeenRemoved) [returnParticipants addObject:p];
    }
    return [returnParticipants autorelease];
}

- (void)addOrUpdateParticipantWithXml:(GDataXMLElement *)participantXML
{
    Participant *newp = [[Participant alloc] init];
    [newp populateWithXml:participantXML];
    BOOL isFound = NO;
    for (Participant *p in self.participants) {
        if ([p.email isEqualToString:newp.email] && p.hasBeenPaired) isFound = YES;
    }
    if (!isFound) [self.participants addObject:newp];
    [newp release];
}

- (NSArray *)getRecentParticipants
{
    NSMutableArray *returnParticipants = [[NSMutableArray alloc] init];
    for (Participant *p in self.participants) {
        BOOL isFound = NO;
        if ([p.email isEqualToString:userEmail]) continue;
        for (Participant *p2 in returnParticipants) {
            if ([p2.email isEqualToString:p.email]) isFound = YES;
        }
        if (!isFound && !p.hasBeenRemoved && p.hasBeenPaired) [returnParticipants addObject:p];
    }
    return [returnParticipants autorelease];
}

#pragma mark -
#pragma mark ReportedLocations

- (void)addOrUpdateReportedLocationWithXml:(GDataXMLElement *)reportedLocXML inEventWithId:(NSString *)eventId
{
    ReportedLocation *reportedLocation = [[ReportedLocation alloc] init];
    reportedLocation.ownerEventId = eventId;
    [reportedLocation populateWithXml:reportedLocXML];
    
    ReportedLocation *existingReportedLocation = [self getReportedLocationWithUserId:reportedLocation.userId fromEventWithId:eventId];

    if (existingReportedLocation) {
        [existingReportedLocation populateWithXml:reportedLocXML]; // checks for existing obj and updates if it exists
    } else {
        [self.reportedLocations addObject:reportedLocation];
    }
    [reportedLocation release];
}

- (ReportedLocation *)getReportedLocationWithUserId:(NSString *)reporterEmail fromEventWithId:(NSString *)eventId
{
    for (ReportedLocation *loc in self.reportedLocations) {
        if ([loc.userId isEqualToString:reporterEmail] && [loc.ownerEventId isEqualToString:eventId]) return loc;
    }
	return nil;
}

- (NSArray *)getReportedLocationsForEventWithId:(NSString *)eventId
{
    NSMutableArray *returnMessages = [[NSMutableArray alloc] init];
    for (ReportedLocation *loc in self.reportedLocations) {
        if ([loc.ownerEventId isEqualToString:eventId]) [returnMessages addObject:loc];
    }
    
    return [returnMessages autorelease];
}

- (void)updateReportedLocationsTimestamp:(NSString *)timestamp inEventWithId:(NSString *)eventId
{
    [self getEventById:eventId].lastReportedLocationsTimestamp = timestamp;
}

#pragma mark -
#pragma mark SuggestedTimes
- (void)addSuggestedTimeWithXml:(GDataXMLElement *)suggestedTimeXML inEventWithId:(NSString *)eventId
{
    SuggestedTime *suggestedTime = [[SuggestedTime alloc] init];
    suggestedTime.ownerEventId = eventId;
    [suggestedTime populateWithXml:suggestedTimeXML];
    SuggestedTime *existingSuggestedTime = [self getSuggestedTimeWithId:suggestedTime.suggestedTimeId fromEventWithId:eventId];
    if (existingSuggestedTime) {
        [existingSuggestedTime populateWithXml:suggestedTimeXML]; // checks for existing message and updates if it exists
    } else {
        [self.suggestedTimes addObject:suggestedTime];
    }
    [suggestedTime release];
}

- (SuggestedTime *)getSuggestedTimeWithId:(NSString *)suggestedMessageId fromEventWithId:(NSString *)eventId
{
    for (SuggestedTime *sugTime in self.suggestedTimes) {
        if ([sugTime.suggestedTimeId isEqualToString:suggestedMessageId] && [sugTime.ownerEventId isEqualToString:eventId]) return sugTime;
    }
	return nil;
}
- (SuggestedTime *)getSuggestedTimeWithEmail:(NSString *)email fromEventWithId:(NSString *)eventId
{
    for (SuggestedTime *sugTime in self.suggestedTimes) {
        if ([sugTime.email isEqualToString:email] && [sugTime.ownerEventId isEqualToString:eventId]) return sugTime;
    }
	return nil;
}


#pragma mark -
#pragma mark FeedMessages

- (void)addFeedMessageWithXml:(GDataXMLElement *)messageXML inEventWithId:(NSString *)eventId
{
    FeedMessage *message = [[FeedMessage alloc] init];
    message.ownerEventId = eventId;
    [message populateWithXml:messageXML];
    FeedMessage *existingMessage = [self getFeedMessageWithId:message.messageId fromEventWithId:eventId];
    if (existingMessage) {
        [existingMessage populateWithXml:messageXML]; // checks for existing message and updates if it exists
    } else {
        [self.messages addObject:message];
    }
    [message release];
}

- (FeedMessage *)getFeedMessageWithId:(NSString *)messageId fromEventWithId:(NSString *)eventId
{
    for (FeedMessage *mess in self.messages) {
        if ([mess.messageId isEqualToString:messageId] && [mess.ownerEventId isEqualToString:eventId]) return mess;
    }
	return nil;
}


- (NSArray *)getFeedMessagesForEventWithId:(NSString *)eventId
{
    NSMutableArray *returnMessages = [[NSMutableArray alloc] init];
    for (FeedMessage *mess in self.messages) {
        if ([mess.ownerEventId isEqualToString:eventId]) [returnMessages addObject:mess];
    }
    
    NSSortDescriptor *futureSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"messageSentTimestamp" ascending:NO selector:@selector(compare:)] autorelease];
    [returnMessages sortUsingDescriptors:[NSArray arrayWithObjects:futureSortDescriptor, nil]];
    return [returnMessages autorelease];
}

- (void)removeFeedMessagesForEventWithId:(NSString *)eventId
{
    NSMutableArray *returnMessages = [[[NSMutableArray alloc] init] autorelease];
    for (FeedMessage *mess in self.messages) {
        if ([mess.ownerEventId isEqualToString:eventId]) [returnMessages addObject:mess];
    }
}

- (void)markLocalFeedMessageReadForEventWithId:(NSString *)eventId
{
    for (FeedMessage *mess in self.messages) {
        if ([mess.ownerEventId isEqualToString:eventId]) mess.userReadMessage = YES;
    }
}

- (void)updateUnreadMessageCount:(NSString *)messageCount inEventWithId:(NSString *)eventId
{
    [self getEventById:eventId].unreadMessageCount = messageCount;
}

- (int)getUnreadMessageCountForPastEvents
{
    int count = 0;
    for (Event *ev in self.pastEvents) {
        int unreadMessageCount = [ev.unreadMessageCount intValue];
        count += unreadMessageCount;
    }
    return count;
}

- (int)getUnreadMessageCountForFutureEvents
{
    int count = 0;
    for (Event *ev in self.futureEvents) {
        int unreadMessageCount = [ev.unreadMessageCount intValue];
        count += unreadMessageCount;
    }
    return count;
}

#pragma mark -
#pragma mark Votes

//- (void)addOrRemoveVoteWithXml:(GDataXMLElement *)voteXML inEventWithId:(NSString *)eventId
//{
//    NSString *locationId = [[voteXML attributeForName:@"locationId"] stringValue];
//    NSString *email = [[voteXML attributeForName:@"email"] stringValue];
//    NSString *removeVoteStr = [[voteXML attributeForName:@"hasBeenRemoved"] stringValue];
//    BOOL removeVote = [[removeVoteStr lowercaseString] isEqualToString:@"true"];
//    if (removeVote) [self removeVoteForLocationWithId:locationId inEventWithId:eventId fromUserWithId:email];
//    else [self voteForLocationWithId:locationId inEventWithId:eventId fromUserWithId:email];
//}
//
//- (void)voteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email
//{
//    Vote *v = [self getVoteForLocationWithId:locationId inEventWithId:eventId fromUserWithId:email];
//    if (v) {
//        v.removeVote = NO;
//    } else {
//        Vote *v = [[Vote alloc] init];
//        v.ownerEventId = eventId;
//        v.locationId = locationId;
//        v.userId = email;
//        v.removeVote = NO;
//        [self.votes addObject:v];
//        [v release];
//    }
//}
//
//- (void)removeVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email
//{
//    Vote *v = [self getVoteForLocationWithId:locationId inEventWithId:eventId fromUserWithId:email];
//    if (v) {
//        v.removeVote = YES;
//    }
//}
//
//- (Vote *)getVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId fromUserWithId:(NSString *)email
//{
//    Vote *returnVote = nil;
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:eventId] && [v.locationId isEqualToString:locationId] && [v.userId isEqualToString:email]) {
//            returnVote = v;
//            break;
//        }
//    }
//    return returnVote;
//}
//
//- (BOOL)userWithEmailAddress:(NSString *)email didVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId
//{
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:eventId] && [v.locationId isEqualToString:locationId] && [v.userId isEqualToString:email]) {
//            return !v.removeVote;
//        }
//    }
//    return NO;
//}

- (BOOL)loginUserDidVoteForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId
{
    return [[self getEventById:eventId] loginUserDidVoteForLocationWithId:locationId]; //[self userWithEmailAddress:userEmail didVoteForLocationWithId:locationId inEventWithId:eventId];
}

//- (int)numberOfVotesForEventWithId:(NSString *)eventId
//{
//    int numVotes = 0;
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:eventId] && !v.removeVote) {
//            numVotes++;
//        }
//    }
//    return numVotes;
//}
//
//- (int)numberOfVotesForLocationWithId:(NSString *)locationId inEventWithId:(NSString *)eventId
//{
//    int numVotes = 0;
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:eventId] && [v.locationId isEqualToString:locationId] && !v.removeVote) {
//            numVotes++;
//        }
//    }
//    return numVotes;
//}
//
//- (NSArray *)getVotesForEventWithId:(NSString *)eventId
//{
//    NSMutableArray *returnVotes = [[NSMutableArray alloc] init];
//    for (Vote *v in self.votes) {
//        if ([v.ownerEventId isEqualToString:eventId]) [returnVotes addObject:v];
//    }
//    return [returnVotes autorelease];
//}

- (NSString *)getCreateEventXML:(NSArray *)events
{
    GDataXMLElement *request = [GDataXMLNode elementWithName:@"request"];
    
    for (Event *anEvent in events) {
        GDataXMLElement *eventNode = [GDataXMLNode elementWithName:@"event"];
        
        GDataXMLElement *eventInfo = [GDataXMLNode elementWithName:@"eventInfo"];
        GDataXMLElement *eventDate = [GDataXMLNode attributeWithName:@"eventDate" stringValue:[anEvent getTimestampDateString]];
        if (anEvent.isTemporary && anEvent.eventId) {
            GDataXMLElement *requestId = [GDataXMLNode attributeWithName:@"requestId" stringValue:anEvent.eventId];
            [eventNode addChild:requestId];
        }
        GDataXMLElement *eventTitle = [GDataXMLNode elementWithName:@"eventTitle" stringValue:anEvent.eventTitle];
        GDataXMLElement *eventDescription = [GDataXMLNode elementWithName:@"eventDescription" stringValue:anEvent.eventDescription];
        [eventInfo addChild:eventDate];
        [eventInfo addChild:eventTitle];
        [eventInfo addChild:eventDescription];
        
        [eventNode addChild:eventInfo];
        
        NSArray *locationsArray = [anEvent getLocationsSortedByLocationId];    
        if ([locationsArray count] > 0) {
            GDataXMLElement *locationsNode = [GDataXMLNode elementWithName:@"locations"];
            for (int i=0; i<[locationsArray count]; i++) {
                Location *loc = (Location *)[locationsArray objectAtIndex:i];
                GDataXMLElement *location = [GDataXMLNode elementWithName:@"location"];
                GDataXMLElement *latitude = [GDataXMLNode attributeWithName:@"latitude" stringValue:[NSString stringWithFormat:@"%f", loc.coordinate.latitude]];
                GDataXMLElement *longitude = [GDataXMLNode attributeWithName:@"longitude" stringValue:[NSString stringWithFormat:@"%f", loc.coordinate.longitude]];
                GDataXMLElement *name = [GDataXMLNode elementWithName:@"name" stringValue:loc.name];
                GDataXMLElement *vicinity = [GDataXMLNode elementWithName:@"vicinity" stringValue:loc.vicinity];
                GDataXMLElement *g_id = [GDataXMLNode elementWithName:@"g_id" stringValue:loc.g_id];
                GDataXMLElement *g_reference = [GDataXMLNode elementWithName:@"g_reference" stringValue:loc.g_reference];
                GDataXMLElement *location_type = [GDataXMLNode elementWithName:@"location_type" stringValue:loc.location_type];
                GDataXMLElement *formatted_address = [GDataXMLNode elementWithName:@"formatted_address" stringValue:loc.formatted_address];
                GDataXMLElement *formatted_phone_number = [GDataXMLNode elementWithName:@"formatted_phone_number" stringValue:loc.formatted_phone_number];
                [location addChild:latitude];
                [location addChild:longitude];
                [location addChild:name];
                [location addChild:vicinity];
                [location addChild:g_id];
                [location addChild:g_reference];
                [location addChild:location_type];
                [location addChild:formatted_address];
                [location addChild:formatted_phone_number];
                [locationsNode addChild:location];
            }
            [eventNode addChild:locationsNode];
        }
        
        NSArray *participantsArray = [anEvent getParticipantsSortedByName];    
        if ([participantsArray count] > 1) {
            GDataXMLElement *participantsNode = [GDataXMLNode elementWithName:@"participants"];
            for (int i=0; i<[participantsArray count]; i++) {
                Participant *part = (Participant *)[participantsArray objectAtIndex:i];
                if (![part.email isEqualToString:[Model sharedInstance].userEmail]) {
                    GDataXMLElement *participant = [GDataXMLNode elementWithName:@"participant"];
                    GDataXMLElement *email = [GDataXMLNode attributeWithName:@"email" stringValue:part.email];
                    [participant addChild:email];
                    [participantsNode addChild:participant];
                }
            }
            [eventNode addChild:participantsNode];
        }
        
        NSArray *votesArray = anEvent.iVotedFor;
        if ([votesArray count] > 0) {
            GDataXMLElement *votesNode = [GDataXMLNode elementWithName:@"votes"];
            for (NSString *v in anEvent.iVotedFor) {
                GDataXMLElement *vote = [GDataXMLNode elementWithName:@"vote"];
                NSString *index = @"";
                for (int j=0; j<[locationsArray count]; j++) {
                    Location *l = [locationsArray objectAtIndex:j];
                    if ([l.locationId isEqualToString:v]) {
                        index = [[[NSString alloc] initWithFormat:@"%i",j] autorelease];
                        break;
                    }
                }
                GDataXMLElement *selectedLocationIndex = [GDataXMLNode attributeWithName:@"selectedLocationIndex" stringValue:index];
                [vote addChild:selectedLocationIndex];
                [votesNode addChild:vote];
            }
            NSLog(@"votes on create = %@", votesArray);
            [eventNode addChild:votesNode];
        }
        [request addChild:eventNode];
    }
    
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:request] autorelease];
	NSLog(@"xml = %@", [[document rootElement] XMLString]);
	return [[document rootElement] XMLString];
}

- (NSString *)getUpdateEventXML:(Event *)anEvent
{
	GDataXMLElement *eventNode = [GDataXMLNode elementWithName:@"event"];
	GDataXMLElement *eventId = [GDataXMLNode attributeWithName:@"id" stringValue:[anEvent eventId]];
	[eventNode addChild:eventId];
	
	GDataXMLElement *eventInfo = [GDataXMLNode elementWithName:@"eventInfo"];
	GDataXMLElement *eventDate = [GDataXMLNode attributeWithName:@"eventDate" stringValue:[anEvent getTimestampDateString]];
	GDataXMLElement *eventTitle = [GDataXMLNode elementWithName:@"eventTitle" stringValue:anEvent.eventTitle];
	GDataXMLElement *eventDescription = [GDataXMLNode elementWithName:@"eventDescription" stringValue:anEvent.eventDescription];
	[eventInfo addChild:eventDate];
	[eventInfo addChild:eventTitle];
	[eventInfo addChild:eventDescription];
    
	[eventNode addChild:eventInfo];
	GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:eventNode] autorelease];
    NSLog(@"xml = %@", [[document rootElement] XMLString]);
	return [[document rootElement] XMLString];	
}

- (NSString *)getUpdateParticipantsXML:(NSArray *)participantsArray withEventId:(NSString *)anEventId
{
    GDataXMLElement *eventNode = [GDataXMLNode elementWithName:@"event"];
	GDataXMLElement *eventId = [GDataXMLNode attributeWithName:@"id" stringValue:anEventId];
	[eventNode addChild:eventId];
    
	if ([participantsArray count] > 0) {
		GDataXMLElement *participantsNode = [GDataXMLNode elementWithName:@"participants"];
		for (int i=0; i<[participantsArray count]; i++) {
			Participant *part = (Participant *)[participantsArray objectAtIndex:i];
			if (![part.email isEqualToString:[Model sharedInstance].userEmail]) {
				GDataXMLElement *participant = [GDataXMLNode elementWithName:@"participant"];
				GDataXMLElement *email = [GDataXMLNode attributeWithName:@"email" stringValue:part.email];
				[participant addChild:email];
				[participantsNode addChild:participant];
			}
		}
		[eventNode addChild:participantsNode];
	}

    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:eventNode] autorelease];
    NSLog(@"xml = %@", [[document rootElement] XMLString]);
	return [[document rootElement] XMLString];
}

- (NSString *)getToggleVotesXML:(NSArray *)locationIds withEventId:(NSString *)anEventId
{
    GDataXMLElement *eventNode = [GDataXMLNode elementWithName:@"event"];
	GDataXMLElement *eventId = [GDataXMLNode attributeWithName:@"id" stringValue:anEventId];
	[eventNode addChild:eventId];
    
	if ([locationIds count] > 0) {
		GDataXMLElement * votesNode = [GDataXMLNode elementWithName:@"votes"];
		for (int i=0; i<[locationIds count]; i++) {
			NSString *locId = (NSString *)[locationIds objectAtIndex:i];
            GDataXMLElement *vote = [GDataXMLNode elementWithName:@"vote"];
            GDataXMLElement *locationId = [GDataXMLNode attributeWithName:@"locationId" stringValue:locId];
            [vote addChild:locationId];
            [votesNode addChild:vote];
		}
		[eventNode addChild:votesNode];
	}
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:eventNode] autorelease];
    NSLog(@"xml = %@", [[document rootElement] XMLString]);
	return [[document rootElement] XMLString];
}

- (NSString *)getAddOrUpdateLocationXMLForLocations:(NSArray *)locationsArray withEventId:(NSString *)anEventId
{
    GDataXMLElement *eventNode = [GDataXMLNode elementWithName:@"event"];
	GDataXMLElement *eventId = [GDataXMLNode attributeWithName:@"id" stringValue:anEventId];
	[eventNode addChild:eventId];
    
    if ([locationsArray count] > 0) {
		GDataXMLElement *locationsNode = [GDataXMLNode elementWithName:@"locations"];
		for (int i=0; i<[locationsArray count]; i++) {
			Location *loc = (Location *)[locationsArray objectAtIndex:i];
            GDataXMLElement *location = [GDataXMLNode elementWithName:@"location"];
            if (loc.locationId != nil && !loc.isTemporary) // this will update instead of adding a new one
            {
                GDataXMLElement *locationId = [GDataXMLNode attributeWithName:@"locationId" stringValue:loc.locationId];
                [location addChild:locationId];
            }
            if (loc.tempId != nil) {
                GDataXMLElement *tempId = [GDataXMLNode attributeWithName:@"tempId" stringValue:loc.tempId];
                [location addChild:tempId];
            }
			GDataXMLElement *latitude = [GDataXMLNode attributeWithName:@"latitude" stringValue:[NSString stringWithFormat:@"%f", loc.coordinate.latitude]];
			GDataXMLElement *longitude = [GDataXMLNode attributeWithName:@"longitude" stringValue:[NSString stringWithFormat:@"%f", loc.coordinate.longitude]];
			GDataXMLElement *name = [GDataXMLNode elementWithName:@"name" stringValue:loc.name];
			GDataXMLElement *vicinity = [GDataXMLNode elementWithName:@"vicinity" stringValue:loc.vicinity];
            GDataXMLElement *g_id = [GDataXMLNode elementWithName:@"g_id" stringValue:loc.g_id];
            GDataXMLElement *g_reference = [GDataXMLNode elementWithName:@"g_reference" stringValue:loc.g_reference];
            GDataXMLElement *location_type = [GDataXMLNode elementWithName:@"location_type" stringValue:loc.location_type];
            GDataXMLElement *formatted_address = [GDataXMLNode elementWithName:@"formatted_address" stringValue:loc.formatted_address];
            GDataXMLElement *formatted_phone_number = [GDataXMLNode elementWithName:@"formatted_phone_number" stringValue:loc.formatted_phone_number];
			[location addChild:latitude];
			[location addChild:longitude];
			[location addChild:name];
			[location addChild:vicinity];
            [location addChild:g_id];
            [location addChild:g_reference];
            [location addChild:location_type];
            [location addChild:formatted_address];
            [location addChild:formatted_phone_number];
			[locationsNode addChild:location];
		}
		[eventNode addChild:locationsNode];
	}
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:eventNode] autorelease];
    NSLog(@"xml = %@", [[document rootElement] XMLString]);
	return [[document rootElement] XMLString];
}

#pragma mark -
#pragma mark Pending Requests

- (void)addPendingVoteRequestToLocationWithId:(NSString *)locationId withRequestId:(NSString *)requestId
{
    [self.pendingVoteRequests setObject:locationId forKey:requestId];
}

- (void)removePendingVoteRequestWithRequestId:(NSString *)requestId
{
    [self.pendingVoteRequests removeObjectForKey:requestId];
}

- (BOOL)locationWithIdHasPendingVoteRequest:(NSString *)locationId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", locationId];
    return [[[self.pendingVoteRequests allValues] filteredArrayUsingPredicate:pred] count] > 0;
}

- (NSString *)locationWithRequestId:(NSString *)requestId
{
    return [self.pendingVoteRequests objectForKey:requestId];
}

#pragma mark -
#pragma mark Unique ID Generator

- (NSString*) stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

- (void)printModel
{
    for (Event *ev in [allEvents allValues]) {
        NSLog(@"EVENT: %@ %@", ev.eventTitle, ev.eventId);
        NSArray *locs = [ev getLocations];
        for (Location *loc in locs) {
            NSLog(@"    LOCATION: %@ %@", loc.name, loc.locationId);
        }
        NSArray *parts = [ev getParticipants];
        for (Participant *part in parts) {
            NSLog(@"    PARTICIPANT: %@ %@", part.fullName, part.email);
        }
    }
    NSLog(@"ALL LOCATIONS ---------------------------------------------");
    for (Location *loc in self.locations) {
        NSLog(@"LOCATION: %@ %@", loc.name, loc.locationId);
    }
    NSLog(@"ALL PARTICIPANTS ------------------------------------------");
    for (Participant *part in self.participants) {
        NSLog(@"PARTICIPANT: %@ %@", part.fullName, part.email);
    }
}

@end
