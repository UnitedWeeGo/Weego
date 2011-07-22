//
//  Event.m
//  BigBaby
//
//  Created by Nicholas Velloff on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "Participant.h"
#import "Location.h"
#import "VoteCollection.h"
#import "Vote.h"

@interface Event(Private)

- (NSDate *)getDateFromString:(NSString *)dateString;

@end

@implementation Event

@synthesize eventId, eventTitle, eventDate, eventExpireDate, eventDescription, creatorId, acceptedParticipantList, declinedParticipantList, lastUpdatedTimestamp, lastReportedLocationsTimestamp;
@synthesize isTemporary, currentEventState;
@synthesize topLocationId;
@synthesize participantCount, unreadMessageCount, eventRead, hasBeenCheckedIn;
@synthesize currentLocationOrder, iVotedFor;
@synthesize updatedVotes;
@synthesize acceptanceStatus,hasBeenRemoved;

- (id)initWithId:(NSString *)anId
{
	self = [self init];
	if (self != nil) {
        self.eventTitle = @"";
		self.eventId = anId;
	}
	return self;
}

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uCreatorId = ((GDataXMLElement *) [[xml elementsForName:@"creatorId"] objectAtIndex:0]).stringValue;
    NSString *uAcceptedParticipantList = ((GDataXMLElement *) [[xml elementsForName:@"acceptedParticipantList"] objectAtIndex:0]).stringValue;
    NSString *uDeclinedParticipantList = ((GDataXMLElement *) [[xml elementsForName:@"declinedParticipantList"] objectAtIndex:0]).stringValue;
    NSString *uEventTitle = ((GDataXMLElement *) [[xml elementsForName:@"eventTitle"] objectAtIndex:0]).stringValue;
    NSString *uEventDate = [[xml attributeForName:@"eventDate"] stringValue];
    NSString *uEventExpireDate = [[xml attributeForName:@"eventExpireDate"] stringValue];
    NSString *uEventRead = [[xml attributeForName:@"hasBeenRead"] stringValue];
    NSString *uCheckedIn = [[xml attributeForName:@"hasCheckedIn"] stringValue];
    NSString *uEventDescription = ((GDataXMLElement *) [[xml elementsForName:@"eventDescription"] objectAtIndex:0]).stringValue;
    NSString *uLastUpdatedTimestamp = nil;
    NSString *uTopLocationId = [[xml attributeForName:@"topLocationId"] stringValue];
    NSString *uCount = [[xml attributeForName:@"count"] stringValue];
    
    if (uCreatorId) self.creatorId = uCreatorId;
    if (uAcceptedParticipantList) self.acceptedParticipantList = uAcceptedParticipantList;
    if (uDeclinedParticipantList) self.declinedParticipantList = uDeclinedParticipantList;
	if (uEventTitle) self.eventTitle = uEventTitle;
    if (uEventRead) self.eventRead = uEventRead;
    if (uCheckedIn) self.hasBeenCheckedIn = [uCheckedIn isEqualToString:@"true"];
	if (uEventDate) self.eventDate = [self getDateFromString:uEventDate];
    if (uEventExpireDate) self.eventExpireDate = [self getDateFromString:uEventExpireDate];
	if (uEventDescription) self.eventDescription = uEventDescription;
    if (uLastUpdatedTimestamp) self.lastUpdatedTimestamp = uLastUpdatedTimestamp;
    if (uTopLocationId) self.topLocationId = uTopLocationId;
    if (uCount) self.participantCount = uCount;    
}

- (AcceptanceType)acceptanceStatus
{
    return [self acceptanceStatusForUserWithEmail:[Model sharedInstance].userEmail];
}

- (AcceptanceType)acceptanceStatusForUserWithEmail:(NSString *)email
{
    BOOL hasAccepted = [acceptedParticipantList rangeOfString:email].location != NSNotFound;
    BOOL hasDeclined = [declinedParticipantList rangeOfString:email].location != NSNotFound;
    if (hasAccepted)
    {
        return AcceptanceTypeAccepted;
    } 
    else if (hasDeclined) 
    {
        return AcceptanceTypeDeclined;
    }
    return AcceptanceTypePending;
}

- (BOOL)participantHasAcceptedEventWithEmail:(NSString *)email
{
    return [acceptedParticipantList rangeOfString:email].location != NSNotFound;
}

- (NSArray *)getLocations
{
    return [[Model sharedInstance] getLocationsForEventWithId:self.eventId];
}

- (NSArray *)getLocationsSortedByLocationId
{
    NSMutableArray *sortedLocations = [[NSMutableArray alloc] initWithArray:[self getLocations]];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"locationId" ascending:YES selector:@selector(compare:)] autorelease];
	[sortedLocations sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return [sortedLocations autorelease];
}

- (NSArray *)getLocationsByLocationOrder:(NSString *)order
{
    NSMutableArray *sortedLocations = [[[NSMutableArray alloc] init] autorelease];
    if (order != nil && [order stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        NSArray *locationIds = [order componentsSeparatedByString:@","];
        for (int i=0; i<[locationIds count]; i++) {
            [sortedLocations addObject:[self getLocationByLocationId:[locationIds objectAtIndex:i]]];
        }
        return sortedLocations;
    }
    return [self getLocations];
    
//    NSMutableArray *sortedLocations = [[NSMutableArray alloc] initWithArray:[self getLocations]];
//    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"numberOfVotes" ascending:NO selector:@selector(compare:)] autorelease];
//	[sortedLocations sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//    if ([sortedLocations count] > 0) {
//        Location *topLocation = [sortedLocations objectAtIndex:0];
//        self.topLocationId = topLocation.locationId;
//    }
//    return [sortedLocations autorelease];
}

- (Location *)getLocationWithUUID:(NSString *)uuid
{
    NSArray *allLocations = [self getLocations];
    for (Location *location in allLocations) {
        if ([location.g_id isEqualToString:uuid]) return location;
    }
    return nil;
}

- (Location *)getLocationByLocationId:(NSString *)locationId
{
    NSArray *allLocations = [self getLocations];
    for (Location *location in allLocations) {
        if ([location.locationId isEqualToString:locationId]) return location;
    }
    return nil;
}

- (NSArray *)getParticipants
{
    NSArray *returnedParticipants = [[Model sharedInstance] getParticipantsForEventWithId:self.eventId];
    self.participantCount = [[[NSString alloc] initWithFormat:@"%i",[returnedParticipants count]] autorelease];
    return returnedParticipants;
}

- (NSArray *)getParticipantsSortedByName
{
    NSMutableArray *sortedParticipants = [[NSMutableArray alloc] initWithArray:[self getParticipants]];
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES selector:@selector(compare:)] autorelease];
	[sortedParticipants sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    return [sortedParticipants autorelease];
}

- (BOOL)loginUserDidVoteForLocationWithId:(NSString *)locationId;
{
    if (iVotedFor != nil) {
//        NSArray *locationIds = [iVotedFor componentsSeparatedByString:@","];
        for (int i=0; i<[iVotedFor count]; i++) {
            if ([locationId isEqualToString:[iVotedFor objectAtIndex:i]]) {
                return YES;
            }
        }
    }
    return NO; //[[Model sharedInstance] loginUserDidVoteForLocationWithId:locationId inEventWithId:self.eventId];
}

//- (int)numberOfVotesForLocationWithId:(NSString *)locationId
//{
//    return [[Model sharedInstance] numberOfVotesForLocationWithId:locationId inEventWithId:self.eventId];
//}
//
//- (int)numberOfVotesTotal
//{
//    return [[Model sharedInstance] numberOfVotesForEventWithId:self.eventId];
//}
//
//- (NSArray *)getVotes
//{
//    return [[Model sharedInstance] getVotesForEventWithId:self.eventId];
//}

- (NSArray *)getFeedMessages
{
    return [[Model sharedInstance] getFeedMessagesForEventWithId:self.eventId];
}

- (NSArray *)getReportedLocations
{
    return [[Model sharedInstance] getReportedLocationsForEventWithId:self.eventId];
}

- (NSDate *)getDateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *aDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return aDate;
}

- (NSString *)getFormattedDateString
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMMM d, yyyy h:mm a"];
	[formatter setTimeZone:[NSTimeZone localTimeZone]];
    
	NSString *output = [formatter stringFromDate:self.eventDate];
    [formatter release];
	return output;
}

- (NSString *)getTimestampDateString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *output = [dateFormatter stringFromDate:self.eventDate];
    [dateFormatter release];
	return output;
}

- (NSString *)getCreatorFullName
{
    return [[Model sharedInstance] getParticipantWithEmail:self.creatorId fromEventWithId:self.eventId].fullName;
}

- (NSString *)getCreatorAvatarURL
{
    return [[Model sharedInstance] getParticipantWithEmail:self.creatorId fromEventWithId:self.eventId].avatarURL;
}

- (EventState)currentEventState
{
    int state = 0;
    
    if (self.minutesToGoUntilVotingEnds > 90) state = EventStateVoting;
    if (self.minutesToGoUntilVotingEnds <= 90) state = EventStateVotingWarning;
    if (self.minutesToGoUntilVotingEnds <= 0) state = EventStateDecided;
    if (self.minutesToGoUntilEventStarts < -60) state = EventStateEnded;
    if (self.isTemporary) state = EventStateNew;

    return state;
}

- (int)minutesToGoUntilVotingEnds
{
    NSDate *now = [NSDate date];
    NSTimeInterval flooredEventExpireDateInterval = floor([self.eventExpireDate timeIntervalSinceReferenceDate] / 60) * 60;
    NSDate *flooredEventExpireDate = [NSDate dateWithTimeIntervalSinceReferenceDate:flooredEventExpireDateInterval];
    return ceil([flooredEventExpireDate timeIntervalSinceDate:now] / 60);
}

- (int)minutesToGoUntilEventStarts
{
    NSDate *now = [NSDate date];
    NSTimeInterval flooredEventExpireDateInterval = floor([self.eventDate timeIntervalSinceReferenceDate] / 60) * 60;
    NSDate *flooredEventExpireDate = [NSDate dateWithTimeIntervalSinceReferenceDate:flooredEventExpireDateInterval];
    return ceil([flooredEventExpireDate timeIntervalSinceDate:now] / 60);
}

- (void)addVoteWithLocationId:(NSString *)locationId
{
    if (!self.updatedVotes) self.updatedVotes = [[NSArray alloc] init];
    BOOL isFound = NO;
    for (int i=0; i<[updatedVotes count]; i++) {
        if ([locationId isEqualToString:[updatedVotes objectAtIndex:i]]) {
            isFound = YES;
            NSMutableArray *mNewVotes = [[NSMutableArray alloc] initWithArray:self.updatedVotes];
            [mNewVotes removeObject:[updatedVotes objectAtIndex:i]];
            self.updatedVotes = mNewVotes;
            [mNewVotes release];
        }
    }
    if (!isFound) {
        NSMutableArray *mNewVotes = [[NSMutableArray alloc] initWithArray:self.updatedVotes];
        [mNewVotes addObject:locationId];
        self.updatedVotes = mNewVotes;
        [mNewVotes release];
    }
    
    isFound = NO;
    for (int i=0; i<[self.iVotedFor count]; i++) {
        if ([locationId isEqualToString:[self.iVotedFor objectAtIndex:i]]) {
            isFound = YES;
            NSMutableArray *mIVotedFor = [[NSMutableArray alloc] initWithArray:self.iVotedFor];
            [mIVotedFor removeObject:[self.iVotedFor objectAtIndex:i]];
            self.iVotedFor = mIVotedFor;
            [mIVotedFor release];
        }
    }
    if (!isFound) {
        NSMutableArray *mIVotedFor = [[NSMutableArray alloc] initWithArray:self.iVotedFor];
        [mIVotedFor addObject:locationId];
        self.iVotedFor = mIVotedFor;
        [mIVotedFor release];
    }
}

- (void)removeVoteFromLocationWithId:(NSString *)locationId
{
    NSMutableArray *mIVotedFor = [[NSMutableArray alloc] initWithArray:self.iVotedFor];
    [mIVotedFor removeObject:locationId];
    self.iVotedFor = mIVotedFor;
    [mIVotedFor release];
    
    NSMutableArray *mNewVotes = [[NSMutableArray alloc] initWithArray:self.updatedVotes];
    [mNewVotes removeObject:locationId];
    self.updatedVotes = mNewVotes;
    [mNewVotes release];
}

- (void)clearNewVotes
{
    self.updatedVotes = nil;
    [self.updatedVotes release];
}

- (void)setHasBeenRemoved:(BOOL)hbr
{
    self.isTemporary = true;
    NSArray *locations = [self getLocations];
    NSArray *participants = [self getParticipants];
    for (Location *loc in locations) loc.isTemporary = YES;
    for (Participant *par in participants) par.isTemporary = YES;
    Model *model = [Model sharedInstance];
    [model removeFeedMessagesForEventWithId:self.eventId];
    [model flushTempItems];
}


- (id)init {
	[super init];
	return self;
}

- (void)dealloc {
	
//	NSLog(@"Event destroyed");
	
	[self.eventId release];
	[self.eventTitle release];
	[self.eventDate release];
    [self.eventRead release];
	[self.eventDescription release];
    [self.creatorId release];
    [self.lastUpdatedTimestamp release];
    [self.lastReportedLocationsTimestamp release];
    [self.topLocationId release];
    [self.participantCount release];
    [self.unreadMessageCount release];
    [self.currentLocationOrder release];
    [self.iVotedFor release];
    if (self.updatedVotes) [self.updatedVotes release];
    [self.acceptedParticipantList release];
    [self.declinedParticipantList release];
    [super dealloc];
}


@end