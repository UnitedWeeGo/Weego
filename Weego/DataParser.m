//
//  DataParser.m
//  BigBaby
//
//  Created by Dave Prukop on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataParser.h"
#import "Model.h"
#import "GDataXMLNode.h"
#import "KeychainManager.h"
#import "Event.h"

#define RESPONSE_REGISTER 200
#define RESPONSE_LOGIN 201
//#define RESPONSE_CREATE_EVENT 210
#define RESPONSE_ADD_LOCATION 220
#define RESPONSE_ADD_PARTICIPANT 230
#define RESPONSE_ADD_REGISTERED_PARTICIPANT 231
#define RESPONSE_RECENT_PARTICIPANTS 234
#define RESPONSE_ADD_VOTE 240
#define RESPONSE_REMOVE_VOTE 241
#define RESPONSE_ALL_EVENTS 250
#define RESPONSE_SINGLE_EVENT 252
#define RESPONSE_CREATE_EVENT 251
#define RESPONSE_ADD_DEVICE 260
#define RESPONSE_DEVICE_BADGE_RESET 261
#define RESPONSE_CHECKIN 280
#define RESPONSE_REPORT_LOCATION 290
#define RESPONSE_EVENT_REPORTED_LOCATIONS 291

#define RESPONSE_GENERIC_ERROR 500
#define RESPONSE_FACEBOOK_LOGIN_ERROR 502
#define RESPONSE_MISSING_PARAM_ERROR 600
#define RESPONSE_RUID_ERROR 610
#define RESPONSE_INVALID_PARAM_ERROR 620
#define RESPONSE_INVALID_TIMESTAMP_ERROR 630
#define RESPONSE_INVALID_XML_ERROR 640
#define RESPONSE_SERVER_ERROR 650

@interface DataParser(Private)

- (void)parseResponseReportedLocation:(GDataXMLDocument *)doc;
- (void)parseResponseReportLocation:(GDataXMLDocument *)doc;
- (void)parseResponseCheckin:(GDataXMLDocument *)doc;
- (void)parseResponseRegister:(GDataXMLDocument *)doc;
- (void)parseResponseAddDevice:(GDataXMLDocument *)doc;
- (void)parseResponseLogin:(GDataXMLDocument *)doc;
- (void)parseResponseAllEvents:(GDataXMLDocument *)doc;
- (void)parseResponseSingleEvent:(GDataXMLDocument *)doc;
- (void)parseResponseCreateEvent:(GDataXMLDocument *)doc;
- (void)parseResponseAddLocation:(GDataXMLDocument *)doc;
- (void)parseResponseAddParticipant:(GDataXMLDocument *)doc;
- (void)parseResponseAddRegisteredParticipant:(GDataXMLDocument *)doc;
- (void)parseResponseRecentParticipants:(GDataXMLDocument *)doc;
- (void)parseResponseGenericError:(GDataXMLDocument *)doc;
- (void)parseResponseRUIDError:(GDataXMLDocument *)doc;
- (void)saveLoginInfo:(NSString *)ruid withFirstName:(NSString *)firstName andLastName:(NSString *)lastName andParticipantId:(NSString *)participantId andAvatarURL:(NSString *)avatarURL;
- (void)parseResponseAddRemoveVote:(GDataXMLDocument *)doc;
- (void)checkAppVersion:(NSString *)version withAppId:(NSString *)appId;
- (void)parseResponseFacebookLoginError:(GDataXMLDocument *)doc;

@end

@implementation DataParser

static DataParser *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (DataParser *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[DataParser alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton DataParser.");
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
    NSLog(@"DataParser dealloc");
    [super dealloc];
}

- (void)processServerResponse:(NSMutableData *)myData
{
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:myData options:0 error:nil];
    myData = nil;
	int responseCode = [[[doc.rootElement attributeForName:@"code"] stringValue] intValue];
//	NSLog(@"%@",[doc rootElement]);
	switch (responseCode) {
		case RESPONSE_REGISTER:
//			NSLog(@"RESPONSE_REGISTER");
			[self parseResponseRegister:doc];
			break;
		case RESPONSE_LOGIN:
//			NSLog(@"RESPONSE_LOGIN");
			[self parseResponseLogin:doc];
			break;
        case RESPONSE_ADD_VOTE:
            [self parseResponseAddRemoveVote:doc];
            break;
        case RESPONSE_REMOVE_VOTE:
            [self parseResponseAddRemoveVote:doc];
            break;
		case RESPONSE_ALL_EVENTS:
//			NSLog(@"RESPONSE_ALL_EVENTS");
			[self parseResponseAllEvents:doc];
			break;
        case RESPONSE_SINGLE_EVENT:
//            NSLog(@"RESPONSE_SINGLE_EVENT");
			[self parseResponseSingleEvent:doc];
            break;
		case RESPONSE_CREATE_EVENT:
//			NSLog(@"RESPONSE_CREATE_EVENT");
			[self parseResponseSingleEvent:doc];
			break;
		case RESPONSE_ADD_LOCATION:
//			NSLog(@"RESPONSE_ADD_LOCATION");
			[self parseResponseAddLocation:doc];
			break;
		case RESPONSE_ADD_PARTICIPANT:
//			NSLog(@"RESPONSE_ADD_PARTICIPANT");
			[self parseResponseAddParticipant:doc];
			break;
		case RESPONSE_ADD_REGISTERED_PARTICIPANT:
//			NSLog(@"RESPONSE_ADD_REGISTERED_PARTICIPANT");
			[self parseResponseAddRegisteredParticipant:doc];
			break;
        case RESPONSE_RECENT_PARTICIPANTS:
//			NSLog(@"RESPONSE_RECENT_PARTICIPANTS");
			[self parseResponseRecentParticipants:doc];
			break;
		case RESPONSE_GENERIC_ERROR:
//			NSLog(@"RESPONSE_GENERIC_ERROR");
			[self parseResponseGenericError:doc];
			break;
		case RESPONSE_MISSING_PARAM_ERROR:
//			NSLog(@"RESPONSE_MISSING_PARAM_ERROR");
			[self parseResponseGenericError:doc];
			break;
        case RESPONSE_RUID_ERROR:
//			NSLog(@"RESPONSE_RUID_ERROR");
			[self parseResponseRUIDError:doc];
			break;
        case RESPONSE_INVALID_PARAM_ERROR:
//			NSLog(@"RESPONSE_INVALID_PARAM_ERROR");
			[self parseResponseGenericError:doc];
			break;
        case RESPONSE_INVALID_TIMESTAMP_ERROR:
//			NSLog(@"RESPONSE_INVALID_TIMESTAMP_ERROR");
			[self parseResponseGenericError:doc];
			break;
        case RESPONSE_INVALID_XML_ERROR:
//			NSLog(@"RESPONSE_INVALID_XML_ERROR");
			[self parseResponseGenericError:doc];
			break;
        case RESPONSE_SERVER_ERROR:
//			NSLog(@"RESPONSE_SERVER_ERROR");
			[self parseResponseGenericError:doc];
			break;
        case RESPONSE_ADD_DEVICE:
//			NSLog(@"RESPONSE_ADD_DEVICE");
			[self parseResponseAddDevice:doc];
			break;
        case RESPONSE_DEVICE_BADGE_RESET:
//            NSLog(@"RESPONSE_DEVICE_BADGE_RESET");
            break;
        case RESPONSE_CHECKIN:
//            NSLog(@"RESPONSE_CHECKIN");
            [self parseResponseCheckin:doc];
            break;
        case RESPONSE_REPORT_LOCATION:
//            NSLog(@"RESPONSE_REPORT_LOCATION");
            [self parseResponseReportLocation:doc];
            break;
        case RESPONSE_EVENT_REPORTED_LOCATIONS:
//            NSLog(@"RESPONSE_EVENT_REPORTED_LOCATIONS");
            [self parseResponseReportedLocation:doc];
            break;
        case RESPONSE_FACEBOOK_LOGIN_ERROR:
//            NSLog(@"RESPONSE_FACEBOOK_LOGIN_ERROR");
            [self parseResponseFacebookLoginError:doc];
            break;
		default:
			break;
	}
    [doc.rootElement releaseCachedValues];
	[doc release];
}

#pragma mark -
#pragma mark RESPONSE_EVENT_REPORTED_LOCATIONS
- (void)parseResponseReportedLocation:(GDataXMLDocument *)doc
{
    Model *model = [Model sharedInstance];
    NSString *timestamp = [[doc.rootElement attributeForName:@"timestamp"] stringValue];
    NSString *eventId = [[doc.rootElement attributeForName:@"eventId"] stringValue];
    model.currentEvent.lastReportedLocationsTimestamp = timestamp;
    [model updateReportedLocationsTimestamp:timestamp inEventWithId:eventId];
    
    NSArray *reportedLocations = [doc.rootElement elementsForName:@"reportLocation"];
    for (GDataXMLElement *reportedLocation in reportedLocations) {
        [model addOrUpdateReportedLocationWithXml:reportedLocation inEventWithId:eventId];
    }
}


#pragma mark -
#pragma mark RESPONSE_REPORT_LOCATION

- (void)parseResponseReportLocation:(GDataXMLDocument *)doc
{
    [Model sharedInstance].lastReportLocationAttempt = [NSDate date];
}

#pragma mark -
#pragma mark RESPONSE_CHECKIN

- (void)parseResponseCheckin:(GDataXMLDocument *)doc
{
//    NSLog(@"parseResponseCheckin");
    GDataXMLElement *successNode = (GDataXMLElement *) [[doc.rootElement elementsForName:@"success"] objectAtIndex:0];
    NSString *eventId = [[successNode attributeForName:@"id"] stringValue];
    [[Model sharedInstance] markCheckedInEventWithId:eventId];
}

#pragma mark -
#pragma mark RESPONSE_REGISTER

- (void)parseResponseRegister:(GDataXMLDocument *)doc
{
//	NSLog(@"%@",[doc rootElement]);
//	GDataXMLElement *successNode = (GDataXMLElement *) [[doc.rootElement elementsForName:@"success"] objectAtIndex:0];
//	[[Model sharedInstance] assignRegisteredId:[ [successNode attributeForName:@"id"] stringValue] ];
    
    [self parseResponseLogin:doc];
}

#pragma mark -
#pragma mark RESPONSE_ADD_DEVICE

- (void)parseResponseAddDevice:(GDataXMLDocument *)doc
{
//    NSLog(@"parseResponseAddDevice");
}

#pragma mark -
#pragma mark RESPONSE_LOGIN

- (void)parseResponseLogin:(GDataXMLDocument *)doc
{
//	NSLog(@"%@",[doc rootElement]);
	GDataXMLElement *participant = (GDataXMLElement *) [[doc.rootElement elementsForName:@"participant"] objectAtIndex:0];
	NSString *ruId = ((GDataXMLElement *) [[participant elementsForName:@"ruid"] objectAtIndex:0]).stringValue;
	NSString *email = [[participant attributeForName:@"email"] stringValue];
	NSString *firstName = ((GDataXMLElement *) [[participant elementsForName:@"firstName"] objectAtIndex:0]).stringValue;
	NSString *lastName = ((GDataXMLElement *) [[participant elementsForName:@"lastName"] objectAtIndex:0]).stringValue;
    NSString *avatarURL = ((GDataXMLElement *) [[participant elementsForName:@"avatarURL"] objectAtIndex:0]).stringValue;
	[[Model sharedInstance] assignInfoToLoginParticipant:ruId andFirstName:firstName andLastName:lastName andParticipantId:email andAvatarURL:avatarURL];
    
    // save the ruid to the keychain
    [self saveLoginInfo:ruId withFirstName:firstName andLastName:lastName andParticipantId:email andAvatarURL:avatarURL];
    
    // update the user device record
    [[Controller sharedInstance] updateUserDeviceRecord];
    
    NSArray *events = [doc.rootElement elementsForName:@"event"];
    if (events && [events count] > 0) {
        [self parseResponseSingleEvent:doc];
        GDataXMLElement *event = [events objectAtIndex:0];
        NSString *eventId = [[event attributeForName:@"id"] stringValue];
        [[Model sharedInstance] setCurrentEventById:eventId];
    }
}

#pragma mark -
#pragma mark RESPONSE_ALL_EVENTS

- (void)parseResponseAllEvents:(GDataXMLDocument *)doc
{
    // check the users installed app version
    GDataXMLElement *appinfo = (GDataXMLElement *) [[doc.rootElement elementsForName:@"appinfo"] objectAtIndex:0];
    NSString *app_store_id = [[appinfo attributeForName:@"app_store_id"] stringValue];
    NSString *app_store_version = [[appinfo attributeForName:@"app_store_version"] stringValue];
    [self checkAppVersion:app_store_version withAppId:app_store_id];
    
    
	NSArray *events = [doc.rootElement elementsForName:@"event"];

    NSString *timestamp = nil;
    Model *model = [Model sharedInstance];
    if ([doc.rootElement attributeForName:@"timestamp"]) {
        timestamp = [[doc.rootElement attributeForName:@"timestamp"] stringValue];
        [Model sharedInstance].lastUpdateTimeStamp = timestamp;
    }
    for (GDataXMLElement *event in events) {
        NSString *eventId = [[event attributeForName:@"id"] stringValue];
        GDataXMLElement *eventInfo = (GDataXMLElement *) [[event elementsForName:@"eventInfo"] objectAtIndex:0];
        [[Model sharedInstance] addOrUpdateEventWithXml:eventInfo inEventWithId:eventId withTimestamp:nil];
        NSArray *locations = [(GDataXMLElement *) [[event elementsForName:@"locations"] objectAtIndex:0] elementsForName:@"location"];
        for (GDataXMLElement *location in locations) {
            NSString *locationId = [[location attributeForName:@"id"] stringValue];
            NSString *iVotedFor = [[location attributeForName:@"iVotedFor"] stringValue];
            if ([iVotedFor isEqualToString:@"true"]) [[Model sharedInstance] addOrUpdateVotes:locationId inEventWithId:eventId overwrite:NO];
            [[Model sharedInstance] addOrUpdateLocationWithXml:location inEventWithId:eventId];
        }
        NSArray *participants = [(GDataXMLElement *) [[event elementsForName:@"participants"] objectAtIndex:0] elementsForName:@"participant"];
        for (GDataXMLElement *participant in participants) {
            [[Model sharedInstance] addOrUpdateParticipantWithXml:participant inEventWithId:eventId];
        }
        GDataXMLElement *feedMessageNode = (GDataXMLElement *) [[event elementsForName:@"feedMessages"] objectAtIndex:0];
        NSString *unreadMessageCount = [[feedMessageNode attributeForName:@"unreadMessageCount"] stringValue];
        NSArray *feedMessages = [(GDataXMLElement *) [[event elementsForName:@"feedMessages"] objectAtIndex:0] elementsForName:@"feedMessage"];
        if (unreadMessageCount != nil) [[Model sharedInstance] updateUnreadMessageCount:unreadMessageCount inEventWithId:eventId];
        for (GDataXMLElement *message in feedMessages) {
            [[Model sharedInstance] addFeedMessageWithXml:message inEventWithId:eventId];
        }
    }
    if (![Model sharedInstance].currentAppState == AppStateCreateEvent) [[Model sharedInstance] flushTempItems];
        
    NSLog(@"User %@ :: parseResponseAllEvents success", model.userEmail);
    model.lastFetchAttempt = [NSDate date];
}

#pragma mark -
#pragma mark RESPONSE_SINGLE_EVENT

- (void)parseResponseSingleEvent:(GDataXMLDocument *)doc
{
	NSArray *events = [doc.rootElement elementsForName:@"event"];
//    NSLog(@"%@",events);
//    if (events) {
        NSString *timestamp = nil;
        if ([doc.rootElement attributeForName:@"timestamp"]) {
            timestamp = [[doc.rootElement attributeForName:@"timestamp"] stringValue];
    //		[Model sharedInstance].lastUpdateTimeStamp = timestamp;
        }
        for (GDataXMLElement *event in events) {
            NSString *eventId = [[event attributeForName:@"id"] stringValue];
            GDataXMLElement *eventInfo = (GDataXMLElement *) [[event elementsForName:@"eventInfo"] objectAtIndex:0];
            [[Model sharedInstance] addOrUpdateEventWithXml:eventInfo inEventWithId:eventId withTimestamp:timestamp];
            NSArray *locations = [(GDataXMLElement *) [[event elementsForName:@"locations"] objectAtIndex:0] elementsForName:@"location"];
            for (GDataXMLElement *location in locations) {
                [[Model sharedInstance] addOrUpdateLocationWithXml:location inEventWithId:eventId];
            }
            NSArray *participants = [(GDataXMLElement *) [[event elementsForName:@"participants"] objectAtIndex:0] elementsForName:@"participant"];
            for (GDataXMLElement *participant in participants) {
                [[Model sharedInstance] addOrUpdateParticipantWithXml:participant inEventWithId:eventId];
            }
            GDataXMLElement *feedMessageNode = (GDataXMLElement *) [[event elementsForName:@"feedMessages"] objectAtIndex:0];
            NSString *unreadMessageCount = [[feedMessageNode attributeForName:@"unreadMessageCount"] stringValue];
            NSArray *feedMessages = [(GDataXMLElement *) [[event elementsForName:@"feedMessages"] objectAtIndex:0] elementsForName:@"feedMessage"];
            if (unreadMessageCount != nil) [[Model sharedInstance] updateUnreadMessageCount:unreadMessageCount inEventWithId:eventId];
            for (GDataXMLElement *message in feedMessages) {
                [[Model sharedInstance] addFeedMessageWithXml:message inEventWithId:eventId];
            }
            
            NSArray *suggestedTimes = [(GDataXMLElement *) [[event elementsForName:@"suggestedTimes"] objectAtIndex:0] elementsForName:@"suggestedTime"];
            for (GDataXMLElement *suggestedTime in suggestedTimes) {
                [[Model sharedInstance] addSuggestedTimeWithXml:suggestedTime inEventWithId:eventId]; ///////
            }

            GDataXMLElement *locationOrderElement = (GDataXMLElement *) [[event elementsForName:@"locationOrder"] objectAtIndex:0];
            NSString *locationOrder = [[locationOrderElement attributeForName:@"order"] stringValue];
            if (locationOrder != nil) [[Model sharedInstance] addOrUpdateLocationOrder:locationOrder inEventWithId:eventId];
            GDataXMLElement *iVotedForElement = (GDataXMLElement *) [[event elementsForName:@"iVotedFor"] objectAtIndex:0];
            NSString *iVotedFor = [[iVotedForElement attributeForName:@"locations"] stringValue];
            if (iVotedFor != nil) [[Model sharedInstance] addOrUpdateVotes:iVotedFor inEventWithId:eventId overwrite:YES];
        }
        if (![Model sharedInstance].currentAppState == AppStateCreateEvent) [[Model sharedInstance] flushTempItems]; // may have to make this specific to the event
//        [[Model sharedInstance] sortEvents];
//    } else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MODEL_EVENT_ALL_EVENTS_UPDATED_NULL object:nil];
//    }
}

#pragma mark -
#pragma mark RESPONSE_CREATE_EVENT

- (void)parseResponseCreateEvent:(GDataXMLDocument *)doc
{
	GDataXMLElement *successNode = (GDataXMLElement *) [[doc.rootElement elementsForName:@"success"] objectAtIndex:0];
    NSString *officialId = [[successNode attributeForName:@"id"] stringValue];
    NSString *localId = [[successNode attributeForName:@"requestId"] stringValue];
	[[Model sharedInstance] assignOfficialId:officialId toEventWithLocalId:localId];
}

#pragma mark -
#pragma mark RESPONSE_ADD_LOCATION

- (void)parseResponseAddLocation:(GDataXMLDocument *)doc
{
	GDataXMLElement *successNode = (GDataXMLElement *) [[doc.rootElement elementsForName:@"success"] objectAtIndex:0];
    BOOL hasDeal = ([[[successNode attributeForName:@"hasDeal"] stringValue] isEqualToString:@"true"]) ? YES : NO;
	[[Model sharedInstance] assignOfficialId:[[successNode attributeForName:@"id"] stringValue] toLocationWithLocalId:[[successNode attributeForName:@"requestId"] stringValue] andHasDeal:hasDeal];
}

#pragma mark -
#pragma mark RESPONSE_ADD_PARTICIPANT

- (void)parseResponseAddParticipant:(GDataXMLDocument *)doc
{
    
}

- (void)parseResponseAddRegisteredParticipant:(GDataXMLDocument *)doc
{
	GDataXMLElement *participant = (GDataXMLElement *) [[doc.rootElement elementsForName:@"participant"] objectAtIndex:0];
    NSString *eventId = [[participant attributeForName:@"eventId"] stringValue];
    [[Model sharedInstance] addOrUpdateParticipantWithXml:participant inEventWithId:eventId];
}

#pragma mark -
#pragma mark RESPONSE_RECENT_PARTICIPANTS

- (void)parseResponseRecentParticipants:(GDataXMLDocument *)doc
{
    NSArray *participants = [doc.rootElement elementsForName:@"participant"];
    for (GDataXMLElement *participant in participants) {
        [[Model sharedInstance] addOrUpdateParticipantWithXml:participant];
    }
}

#pragma mark -
#pragma mark RESPONSE_ADD_REMOVE_VOTE

- (void)parseResponseAddRemoveVote:(GDataXMLDocument *)doc
{
    GDataXMLElement *iVotedForElement = (GDataXMLElement *) [[doc.rootElement elementsForName:@"success"] objectAtIndex:0];
    NSString *iVotedFor = [[iVotedForElement attributeForName:@"responseData"] stringValue];
    NSString *eventId = [[iVotedForElement attributeForName:@"eventId"] stringValue];
    [[Model sharedInstance] addOrUpdateVotes:iVotedFor inEventWithId:eventId overwrite:YES];
}

#pragma mark -
#pragma mark RESPONSE_GENERIC_ERROR

- (void)parseResponseGenericError:(GDataXMLDocument *)doc
{
	NSString *title = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"title"] objectAtIndex:0]).stringValue;
	NSString *moreInfo = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"moreInfo"] objectAtIndex:0]).stringValue;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:moreInfo delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
    }
    else
    {
        NSLog(@"parseResponseGenericError: %@, %@", title, moreInfo);
    }
	
    [[NSNotificationCenter defaultCenter] postNotificationName:MODEL_EVENT_GENERIC_ERROR object:nil];
}

#pragma mark -
#pragma mark RESPONSE_FACEBOOK_LOGIN_ERROR

- (void)parseResponseFacebookLoginError:(GDataXMLDocument *)doc
{
	NSString *title = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"title"] objectAtIndex:0]).stringValue;
	NSString *moreInfo = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"moreInfo"] objectAtIndex:0]).stringValue;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:moreInfo delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
        
        [Model sharedInstance].loginDidFail = YES;
    }
    else
    {
        NSLog(@"parseResponseGenericError: %@, %@", title, moreInfo);
    }
}

#pragma mark -
#pragma mark RESPONSE_RUID_ERROR

- (void)parseResponseRUIDError:(GDataXMLDocument *)doc
{
    /* Show no error, just push user to start screen
	NSString *title = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"title"] objectAtIndex:0]).stringValue;
	NSString *moreInfo = ((GDataXMLElement *) [[doc.rootElement elementsForName:@"moreInfo"] objectAtIndex:0]).stringValue;
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title message:moreInfo delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
	[alert show];
     */
    
//    [[ViewController sharedInstance] enterOnEntryScreen];
    
//    This needs to be reworked
    
    NSLog(@"No RUID!!"); // Doing nothing about it for now.");
    
    [[KeychainManager sharedInstance] resetKeychain];
    
    WeegoAppDelegate *appDelegate = (WeegoAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.loggingInFacebook && !kickedBackToEntryMissingRUID) {
        kickedBackToEntryMissingRUID = YES;
        [[ViewController sharedInstance] enterOnEntryScreen];
        [appDelegate hideLoadView];
    }
}

#pragma mark -
#pragma mark check app version
- (void)checkAppVersion:(NSString *)version withAppId:(NSString *)appId
{
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setValue:version forKey:APP_STORE_VERSION];
    [userPreferences setValue:appId forKey:APP_STORE_ID];
    WeegoAppDelegate *appDelegate = (WeegoAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate checkForUpdateWithServerReportedVerion];
}


#pragma mark -
#pragma mark Save Login Info

- (void)saveLoginInfo:(NSString *)ruid withFirstName:(NSString *)firstName andLastName:(NSString *)lastName andParticipantId:(NSString *)participantId andAvatarURL:(NSString *)avatarURL
{
    [[KeychainManager sharedInstance] addKeychainItemsWithFirstName:firstName andLastName:lastName andRuid:ruid andEmailAddress:participantId andAvatarURL:avatarURL];
}

@end
