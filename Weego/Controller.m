//
//  Controller.m
//  BigBaby
//
//  Created by Dave Prukop on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "Model.h"
#import "Event.h"
#import "Location.h"
#import "Participant.h"
#import "FeedMessage.h"
#import "DataParser.h"
#import "GoogleDataParser.h"
#import "SimpleGeoDataParser.h"
#import "InfoDataParser.h"
#import "HelpDataParser.h"
#import "TermsDataParser.h"
#import "PrivacyDataParser.h"
#import "DealsDataParser.h"

@interface Controller (Private)

- (NSString *)doRequestToggleVoteForLocationsWithId;

@end

@implementation Controller

static Controller *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (Controller *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[Controller alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton Controller.");
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
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"Controller dealloc");
//    if (simpleGeoFetcher) [simpleGeoFetcher release];
    [super dealloc];
}

#pragma mark -
#pragma mark Controller
- (NSString *)updateUserDeviceRecord
{
    Model *model = [Model sharedInstance];
    
    if(!model.deviceToken) return nil; // we dont want to add device record if user has not accepted push notifications
    
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
    
	// Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
	// true if those two notifications are on.  This is why the code is written this way
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
    
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
    
    BOOL isSandbox = NO;
#if !TOKEN_ENV_SANDBOX
//    NSLog(@"TOKEN_ENV==PRODUCTION");
#endif
    
#if TOKEN_ENV_SANDBOX
//    NSLog(@"TOKEN_ENV==SANDBOX");
    isSandbox = YES;
#endif
    
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndUpdateDeviceRecordWithUserId:model.userId andDeviceToken:model.deviceToken andDeviceUuid:deviceUuid andDeviceName:deviceName andDeviceModel:deviceModel andDeviceSystemVersion:deviceSystemVersion andPushBadge:pushBadge andPushAlert:pushAlert andPushSound:pushSound andIsSandbox:isSandbox delegate:[DataParser sharedInstance]] autorelease];
    
    return fetcher.requestId;
}

- (NSString *)loginWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password
{
	Model *model = [Model sharedInstance];
	[model createLoginParticipantWithUserName:emailAddress andRegisteredId:nil];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndLoginWithUserName:emailAddress andPassword:password delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)loginWithFacebookAccessToken:(NSString *)accessToken
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndLoginWithFacebookAccessToken:accessToken delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)registerWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName
{
	Model *model = [Model sharedInstance];
	[model assignLoginCredentialsWithUserName:emailAddress andPassword:password];
	DataFetcher *fetcher = [[[DataFetcher alloc] initAndRegisterWithUserName:emailAddress andPassword:password andFirstName:firstName andLastName:lastName delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)fetchEvents
{
	Model *model = [Model sharedInstance];
    if (model.userId) {        
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetDashboardEventsWithUserId:model.userId overrideSynchronous:NO withTimestamp:model.lastUpdateTimeStamp delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}

- (NSString *)fetchEventsSynchronous
{
	Model *model = [Model sharedInstance];
    if (model.userId) {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetDashboardEventsWithUserId:model.userId overrideSynchronous:YES withTimestamp:model.lastUpdateTimeStamp delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}

- (NSString *)fetchEventWithId:(NSString *)anId andTimestamp:(NSString *)aTimestamp
{
	Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetEventWithUserId:model.userId andEventId:anId withTimestamp:aTimestamp delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}


- (NSString *)addEvent:(Event *)anEvent
{
	Model *model = [Model sharedInstance];
	DataFetcher *fetcher = [[[DataFetcher alloc] initAndCreateNewEventWithUserId:model.userId withEvent:anEvent delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)updateEvent:(Event *)anEvent
{
	Model *model = [Model sharedInstance];
    if (!model.isInTrial) {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndUpdateEventWithUserId:model.userId withEvent:anEvent delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}

- (void)removeEvent
{
    Model *model = [Model sharedInstance];
    [model removeCurrentEvent];
}

- (NSString *)addOrUpdateLocations:(NSArray *)locations isAnUpdate:(BOOL)update
{
	Model *model = [Model sharedInstance];
	if (model.currentAppState != AppStateCreateEvent && !model.isInTrial) {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndAddOrUpdateLocationsWithUserId:model.userId withLocations:locations isAnUpdate:update withEvent:model.currentEvent delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    } else {
#warning Make a model method for this
        NSMutableArray *locs = [[NSMutableArray alloc] initWithArray:[model.currentEvent.currentLocationOrder componentsSeparatedByString:@","]];
        for (Location *loc in locations) {
            [locs insertObject:loc.locationId atIndex:0];
            [model addOrUpdateVotes:loc.locationId inEventWithId:model.currentEvent.eventId overwrite:NO];
        }
        model.currentEvent.currentLocationOrder = [locs componentsJoinedByString:@","];
        [locs release];
        [model determineLocationOrderForCreateOrTrial];
    }
    return nil;
}

- (NSString *)reportLocation:(Location *)aLocation forEvent:(Event *)anEvent
{
	Model *model = [Model sharedInstance];
	if (model.currentAppState != AppStateCreateEvent) {        
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndReportNewLocationToEventWithUserId:model.userId overrideSynchronous:NO withEventId:anEvent.eventId withLocation:aLocation delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}

- (NSString *)reportLocationSynchronous:(Location *)aLocation forEvent:(Event *)anEvent
{
	Model *model = [Model sharedInstance];
	if (model.currentAppState != AppStateCreateEvent) {        
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndReportNewLocationToEventWithUserId:model.userId overrideSynchronous:NO withEventId:anEvent.eventId withLocation:aLocation delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}


- (NSString *)addParticipants:(NSArray *)participants
{
	Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndUpdateParticipantsWithUserId:model.userId withParticipants:participants withEvent:model.currentEvent delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)toggleVoteForLocationsWithId:(NSString *)locationId
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	Model *model = [Model sharedInstance];
    [model.currentEvent addVoteWithLocationId:locationId];
//    Delay the following to account for many button presses
    if (model.currentAppState != AppStateCreateEvent && !model.isInTrial) {
        [self performSelector:@selector(doRequestToggleVoteForLocationsWithId) withObject:nil afterDelay:0.5];
    } else {
//        [model toggleVotesForLocations:model.currentEvent.updatedVotes inEventWithId:model.currentEvent.eventId];
        
        [model.currentEvent clearNewVotes];
        [model determineLocationOrderForCreateOrTrial];
    }
    return nil;
}

- (NSString *)doRequestToggleVoteForLocationsWithId
{
    Model *model = [Model sharedInstance];
    if ([model.currentEvent.updatedVotes count] > 0) {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndToggleVotesWithUserId:[model userId] withEvent:model.currentEvent withLocations:model.currentEvent.updatedVotes delegate:[DataParser sharedInstance]] autorelease];
        [model.currentEvent clearNewVotes];
        return fetcher.requestId;
    }
    return nil;
}

- (NSString *)voteForLocationWithId:(NSString *)locationId
{
	Model *model = [Model sharedInstance];
//	[model voteForLocationWithId:locationId inEventWithId:model.currentEvent.eventId fromUserWithId:model.userEmail];
    if (model.currentAppState != AppStateCreateEvent && !model.isInTrial) 
    {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndAddVoteToLocationWithUserId:[model userId] toEventId:model.currentEvent.eventId withLocationId:locationId delegate:[DataParser sharedInstance]] autorelease];
//        [model addPendingVoteRequestToLocationWithId:locationId withRequestId:fetcher.requestId];
        return fetcher.requestId;
    } else {
        [model addOrUpdateVotes:locationId inEventWithId:model.currentEvent.eventId overwrite:NO];
    }
    return nil;
}

- (NSString *)removeVoteForLocationWithId:(NSString *)locationId
{
	Model *model = [Model sharedInstance];
//	[model removeVoteForLocationWithId:locationId inEventWithId:model.currentEvent.eventId fromUserWithId:model.userEmail];
    if (model.currentAppState != AppStateCreateEvent && !model.isInTrial) 
    {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndRemoveVoteFromLocationWithUserId:[model userId] toEventId:model.currentEvent.eventId withLocationId:locationId delegate:[DataParser sharedInstance]] autorelease];
        [model addPendingVoteRequestToLocationWithId:locationId withRequestId:fetcher.requestId];
        return fetcher.requestId;
    } else {
        [model removeVote:locationId inEventWithId:model.currentEvent.eventId];
    }
    return nil;
}

- (NSString *)sendFeedMessage:(FeedMessage *)message
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndAddMessageWithUserId:model.userId 
                                                     andEventId:model.currentEvent.eventId 
                                               andMessageString:message.message 
                                                    andImageUrl:message.imageURL 
                                                   andTimestamp:(NSString *)model.currentEvent.lastUpdatedTimestamp
                                                       delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)markFeedMessagesRead
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndMarkFeedMessagesRead:model.userId andEventId:model.currentEvent.eventId  delegate:[DataParser sharedInstance]] autorelease];
    [model markLocalFeedMessageReadForEventWithId:model.currentEvent.eventId];
    return fetcher.requestId;
}

- (NSString *)resetUserBadge
{
    UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndResetUserBadge:model.userId andDeviceUuid:deviceUuid delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)checkinUserForEvent:(Event *)anEvent
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndCheckinWithUserId:model.userId toEventId:anEvent.eventId intoLocationId:anEvent.topLocationId overrideSynchronous:NO delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)checkinUserForEventSynchronous:(Event *)anEvent
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndCheckinWithUserId:model.userId toEventId:anEvent.eventId intoLocationId:anEvent.topLocationId overrideSynchronous:YES delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)fetchReportedLocations
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetReportedLocationsWithUserId:model.userId andEventId:model.currentEvent.eventId withTimestamp:model.currentEvent.lastReportedLocationsTimestamp delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)searchSimpleGeoForLocation:(Location *)location withRadius:(int)radius
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSearchSimpleGeoWithRadius:radius andName:location.name withLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude delegate:[SimpleGeoDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)searchSimpleGeoForLocation:(Location *)location withRadius:(int)radius andCategory:(SearchCategory *)category
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSearchSimpleGeoWithCategory:category andRadius:radius withLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude delegate:[SimpleGeoDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getSimpleGeoCategories
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetSimpleGeoCategoriesWithDelegate:[SimpleGeoDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)searchGooglePlacesForLocation:(Location *)location withRadius:(int)radius
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSearchGooglePlacesWithRadius:radius andName:location.name withLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude delegate:[GoogleDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)searchGoogleGeoForAddress:(NSString *)address northEastBounds:(CLLocationCoordinate2D)northEast southWestBounds:(CLLocationCoordinate2D)southWest
{
    //bounds=34.172684,-118.604794|34.236144,-118.500938
    NSString *bounds = [NSString stringWithFormat:@"%f,%f|%f,%f", southWest.latitude, southWest.longitude, northEast.latitude, northEast.longitude];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSearchGoogleGeoWithAddress:address andBoundsString:bounds delegate:[GoogleDataParser sharedInstance]] autorelease];
    
    return fetcher.requestId;
}

- (NSString *)setEventAcceptanceForEvent:(Event *)anEvent didAccept:(BOOL)didAccept
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSetEventAcceptanceWithUserId:model.userId withEvent:anEvent didAccept:didAccept delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)setRemovedForEvent:(Event *)anEvent doCountOut:(BOOL)countOut doCancel:(BOOL)cancel
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndRemoveEventWithUserId:model.userId andEventId:anEvent.eventId doCountOut:countOut doCancel:cancel withTimestamp:(NSString *)anEvent.lastUpdatedTimestamp delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)removeLocationWithId:(NSString *)locationId
{
	Model *model = [Model sharedInstance];
    if (model.currentAppState != AppStateCreateEvent && !model.isInTrial) 
    {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndRemoveLocationWithUserId:[model userId] andEventId:model.currentEvent.eventId andLocationId:locationId withTimestamp:(NSString *)model.currentEvent.lastUpdatedTimestamp delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    } else {
        // remove LOCATION from model
        [model removeLocationWithId:locationId fromEventWithId:model.currentEvent.eventId];
    }
    return nil;
}

- (NSString *)getInfoHMTLData
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetInfoHMTLDataWithDelegate:[InfoDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getHelpHMTLData
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetHelpHMTLDataWithDelegate:[HelpDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getTermsHMTLData
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetTermsHMTLDataWithDelegate:[TermsDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getPrivacyHMTLData
{
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetPrivacyHMTLDataWithDelegate:[PrivacyDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getDealsHTMLDataWithSGID:(NSString *)sg_id
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetDealsHMTLDataWithUserId:model.userId withSGID:sg_id withTimestamp:[model.currentEvent getTimestampDateString] withDelegate:[DealsDataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

- (NSString *)getRecentParticipants
{
    if ([Model sharedInstance].userId) {
        DataFetcher *fetcher = [[[DataFetcher alloc] initAndGetRecentParticipantsWithUserId:[Model sharedInstance].userId delegate:[DataParser sharedInstance]] autorelease];
        return fetcher.requestId;
    }
    return nil;
}

- (NSString *)suggestTimeForEvent:(Event *)anEvent withSuggestedTime:(NSString *)suggestedTime
{
    Model *model = [Model sharedInstance];
    DataFetcher *fetcher = [[[DataFetcher alloc] initAndSuggestTimeWithUserId:model.userId toEventId:anEvent.eventId withSuggestedTime:suggestedTime withTimestamp:(NSString *)model.currentEvent.lastUpdatedTimestamp delegate:[DataParser sharedInstance]] autorelease];
    return fetcher.requestId;
}

@end
