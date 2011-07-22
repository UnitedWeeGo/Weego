//
//  DataDelegate.m
//  BigBaby
//
//  Created by Dave Prukop on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataFetcher.h"
#import <CFNetwork/CFNetwork.h>
#import "Model.h"
#import "Event.h"
#import "Location.h"

#define GOOGLE_PLACE_URL @"https://maps.googleapis.com/maps/api/place/search/json"
#define GOOGLE_MAPS_API_V3 @"http://maps.google.com/maps/api/geocode/json"

/* depricated
 //#define apiURL @"http://api.bigbabyservice.com/public/"
 #define apiURL @"http://beta.weegoapp.com/public/"
 //#define apiURL @"http://stable.weegoapp.com/public/"
#define GOOGLE_GEOCODE_URL @"http://maps.googleapis.com/maps/api/geocode/json"
*/


@interface DataFetcher ()

@property (nonatomic, retain) NSMutableData *myData;

- (id)init;
- (NSString *)urlencode:(NSString *)aString;
- (NSString *)stringFromDate:(NSDate *)aDate;
- (void)makeRequest:(NSString *)urlString;
- (void)handleError:(NSError *)error;
- (void)makeSynchronousRequest:(NSString *)urlString;
- (NSString*) stringWithUUID;

@end

@implementation DataFetcher

@synthesize delegate;
@synthesize myData;
@synthesize dataFetcherFinished;

- (NSString *)requestId
{
    return requestId;
}

//apiURL
- (id)init
{
    self = [super init];
    if (self != nil) {
#if API_TYPE == 1
        apiURL = @"http://local.weegoapp.com/public/";
#endif
#if API_TYPE == 2
        apiURL = @"http://beta.weegoapp.com/public/";
#endif
#if API_TYPE == 3
        apiURL = @"http://stable.weegoapp.com/public/";
#endif
    }
    return self;
}

- (id)initAndUpdateDeviceRecordWithUserId:(NSString *)userId
                           andDeviceToken:(NSString *)deviceToken 
                            andDeviceUuid:(NSString *)deviceUuid 
                            andDeviceName:(NSString *)deviceName 
                           andDeviceModel:(NSString *)deviceModel 
                   andDeviceSystemVersion:(NSString *)deviceSystemVersion
                             andPushBadge:(NSString *)pushBadge
                             andPushAlert:(NSString *)pushAlert 
                             andPushSound:(NSString *)pushSound 
                             andIsSandbox:(BOOL)isSandbox
                                 delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeUpdateDeviceRecord;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&deviceToken=%@&deviceUuid=%@&deviceName=%@&deviceModel=%@&deviceSystemVersion=%@&pushBadge=%@&pushAlert=%@&pushSound=%@&isSandbox=%@",
                                apiURL,
                                @"mod.device.php",
                                userId,
                                deviceToken,
                                deviceUuid,
                                deviceName,
                                deviceModel,
                                deviceSystemVersion,
                                pushBadge,
                                pushAlert,
                                pushSound,
                                isSandbox ? @"true":@"false"] autorelease];
		[self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
	}
	return self;
}

- (id)initAndAddMessageWithUserId:(NSString *)userId andEventId:(NSString *)eventId andMessageString:(NSString *)messageString andImageUrl:(NSString *)imageUrlString andTimestamp:(NSString *)aTimestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeAddMessage;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&message=%@&imageURL=%@&timestamp=%@",
                                apiURL,
                                @"mod.feedmessage.php",
                                userId,
                                eventId,
                                [self urlencode:messageString],
                                imageUrlString,
                                [self urlencode:aTimestamp]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}
- (id)initAndMarkFeedMessagesRead:(NSString *)userId andEventId:(NSString *)eventId delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeMarkFeedMessagesRead;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@",
                                apiURL,
                                @"readall.feedmessages.php",
                                userId,
                                eventId] autorelease];
		[self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	return self;
}

- (id)initAndResetUserBadge:(NSString *)userId andDeviceUuid:(NSString *)deviceUuid delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeResetUserBadge;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&deviceUuid=%@",
                                apiURL,
                                @"mod.badge.reset.php",
                                userId,
                                deviceUuid] autorelease];
		[self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	return self;
}

- (id)initAndLoginWithUserName:(NSString *)emailAddress andPassword:(NSString *)password delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeLoginWithUserName;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?email=%@&password=%@",
                                apiURL,
                                @"login.php",
                                emailAddress,
                                password] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndLoginWithFacebookAccessToken:(NSString *)accessToken delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeLoginWithFacebookAccessToken;
		self.delegate = myDelegate;
        
        Model *model = [Model sharedInstance];
        
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.facebook.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
        if (model.isInTrial && model.currentViewState != ViewStateCreate) {
            NSString *xmlString = [[Model sharedInstance] getCreateEventXML:[model.allEvents allValues]];
            [postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@&",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
        }
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"access_token=%@",accessToken] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[theRequest setHTTPBody:postBody];
		
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

- (id)initAndRegisterWithUserName:(NSString *)emailAddress andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeRegister;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?email=%@&password=%@&firstName=%@&lastName=%@",
                                apiURL,
                                @"register.php",
                                emailAddress,
                                password,
                                [self urlencode:firstName],
                                [self urlencode:lastName]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetAllEventsWithUserId:(NSString *)userId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGetAllEvents;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@%@",
							   apiURL,
							   @"get.event.php",
							   userId,
							   (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetDashboardEventsWithUserId:(NSString *)userId overrideSynchronous:(BOOL)useSync withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGetDashboardEvents;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@%@",
                                apiURL,
                                @"get.event.dashboard.php",
                                userId,
                                (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease]] autorelease];
        if (useSync)
        {
            [self makeSynchronousRequest:urlString];
        }
        else
        {
            [self makeRequest:urlString];
        }
	}
	return self;
}

- (id)initAndGetEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGetEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@%@%@",
							   apiURL,
							   @"get.event.php",
							   userId,
							   (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease],
                               (!eventId) ? @"" : [[[NSString alloc] initWithFormat:@"&eventId=%@", eventId] autorelease]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndCreateNewEventWithUserId:(NSString *)userId withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeCreateNewEvent;
		self.delegate = myDelegate;		
		NSString *xmlString = [[Model sharedInstance] getCreateEventXML:[NSArray arrayWithObjects:event, nil]];

		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.post.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&registeredId=%@",userId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		if ([Model sharedInstance].lastUpdateTimeStamp != nil) [postBody appendData:[[[[NSString alloc] initWithFormat:@"&timestamp=%@",[Model sharedInstance].lastUpdateTimeStamp != nil ? [self urlencode:[Model sharedInstance].lastUpdateTimeStamp] : @""] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[theRequest setHTTPBody:postBody];
		
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

- (id)initAndUpdateEventWithUserId:(NSString *)userId withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeUpdateEvent;
		self.delegate = myDelegate;		
		NSString *xmlString = [[Model sharedInstance] getUpdateEventXML:event];
		
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.post.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&registeredId=%@",userId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&timestamp=%@",[Model sharedInstance].lastUpdateTimeStamp != nil ? [self urlencode:[Model sharedInstance].lastUpdateTimeStamp] : @""] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[theRequest setHTTPBody:postBody];
		
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

- (id)initAndUpdateParticipantsWithUserId:(NSString *)userId withParticipants:(NSArray *)participants withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeUpdateParticipants;
		self.delegate = myDelegate;		
		NSString *xmlString = [[Model sharedInstance] getUpdateParticipantsXML:participants withEventId:event.eventId];
		
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.invite.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&registeredId=%@",userId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&timestamp=%@",event.lastUpdatedTimestamp != nil ? [self urlencode:event.lastUpdatedTimestamp] : @""] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[theRequest setHTTPBody:postBody];
		
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

- (id)initAndAddOrUpdateLocationsWithUserId:(NSString *)userId withLocations:(NSArray *)locations isAnUpdate:(BOOL)update withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = update ? DataFetchTypeUpdateLocationToEvent : DataFetchTypeAddNewLocationToEvent;
		self.delegate = myDelegate;		
		NSString *xmlString = [[Model sharedInstance] getAddOrUpdateLocationXMLForLocations:locations withEventId:event.eventId];
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.location.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&registeredId=%@",userId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&timestamp=%@",event.lastUpdatedTimestamp != nil ? [self urlencode:event.lastUpdatedTimestamp] : @""] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[theRequest setHTTPBody:postBody];
		
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

/* DEPRICATED
- (id)initAndAddNewLocationToEventWithUserId:(NSString *)userId withEventId:(NSString *)eventId withLocation:(Location *)aLocation delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeAddNewLocationToEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&latitude=%f&longitude=%f&name=%@&vicinity=%@&g_id=%@&g_reference=%@&location_type=%@%@%@",
							   apiURL,
							   @"mod.location.php",
							   userId,
							   eventId,
							   aLocation.coordinate.latitude,
							   aLocation.coordinate.longitude,
							   [self urlencode:aLocation.name],
                                aLocation.vicinity != nil ? [self urlencode:aLocation.vicinity] : @"",
                                aLocation.g_id != nil ? aLocation.g_id : @"",
                                aLocation.g_reference != nil ?  aLocation.g_reference : @"",
                                aLocation.location_type,
                                (aLocation.isTemporary && aLocation.locationId) ? [NSString stringWithFormat:@"&requestId=%@", aLocation.locationId] : @"",
                                ([aLocation.location_type isEqualToString:@"address"]) ? [NSString stringWithFormat:@"&formatted_address=%@", [self urlencode:aLocation.formatted_address]] : @""
                                ] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}
 */

- (id)initAndToggleVotesWithUserId:(NSString *)userId withEvent:(Event *)event withLocations:(NSArray *)locationIds delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeToggleVotesForEvent;
		self.delegate = myDelegate;		
		NSString *xmlString = [[Model sharedInstance] getToggleVotesXML:locationIds withEventId:event.eventId];
		
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",apiURL,@"xml.vote.php"] autorelease];
		NSMutableURLRequest* theRequest= [[[NSMutableURLRequest alloc] init] autorelease];
		[theRequest setURL:[NSURL URLWithString: urlString]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [theRequest setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&registeredId=%@",userId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[[[NSString alloc] initWithFormat:@"&timestamp=%@",event.lastUpdatedTimestamp != nil ? [self urlencode:event.lastUpdatedTimestamp] : @""] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
		[theRequest setHTTPBody:postBody];

//		NSLog(@"I turned the connection off for this call");
		myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	}
	return self;
}

- (id)initAndAddVoteToLocationWithUserId:(NSString *)userId toEventId:(NSString *)eventId withLocationId:(NSString *)locationId delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeAddVoteToLocation;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&locationId=%@",
							   apiURL,
							   @"mod.vote.php",
							   userId,
							   eventId,
							   locationId ] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndRemoveVoteFromLocationWithUserId:(NSString *)userId toEventId:(NSString *)eventId withLocationId:(NSString *)locationId delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeRemoveVoteFromLocation;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&locationId=%@&removeVote=true",
                                apiURL,
                                @"mod.vote.php",
                                userId,
                                eventId,
                                locationId ] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndAddParticipantWithUserId:(NSString *)userId toEventId:(NSString *)eventId withEmailAddress:(NSString *)emailAddress delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeAddParticipant;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&email=%@",
							   apiURL,
							   @"mod.participant.php",
							   userId,
							   eventId,
							   emailAddress ] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}
- (id)initAndWriteStringToLog:(NSString *)logMessage
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?logMessage=%@",
                                apiURL,
                                @"log.php",
                                logMessage] autorelease];
		[self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}
- (id)initAndClearLog
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?clearLog=true",
                                apiURL,
                                @"log.php"] autorelease];
        [self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}
- (id)initAndCheckinWithUserId:(NSString *)userId toEventId:(NSString *)eventId intoLocationId:(NSString *)locationId overrideSynchronous:(BOOL)useSync delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeCheckin;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&locationId=%@",
                                apiURL,
                                @"checkin.php",
                                userId,
                                eventId,
                                locationId] autorelease];
		if (useSync)
        {
            [self makeSynchronousRequest:urlString];
        }
        else
        {
            [self makeRequest:urlString];
        }
	}
	return self;
}

- (id)initAndReportNewLocationToEventWithUserId:(NSString *)userId overrideSynchronous:(BOOL)useSync withEventId:(NSString *)eventId withLocation:(Location *)aLocation delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeReportNewLocationToEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&latitude=%f&longitude=%f",
                                apiURL,
                                @"report.location.php",
                                userId,
                                eventId,
                                aLocation.coordinate.latitude,
                                aLocation.coordinate.longitude] autorelease];
		if (useSync)
        {
            [self makeSynchronousRequest:urlString];
        }
        else
        {
            [self makeRequest:urlString];
        }
	}
	return self;
}

- (id)initAndGetReportedLocationsWithUserId:(NSString *)userId andEventId:(NSString *)eventId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGetReportedLocations;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@%@",
                                apiURL,
                                @"get.report.location.php",
                                userId,
                                eventId,
                                (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetSimpleGeoCategoriesWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeSearchSimpleGeoCategories;
        
        // default to using this as the delegate for potentially helpful error logging
        [self retain];
        client = [[SimpleGeo alloc] initWithDelegate:self consumerKey:SIMLE_GEO_CONSUMER_KEY consumerSecret:SIMLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
        [client getCategories];
    }
    return self;
}

- (id)initAndSearchSimpleGeoWithCategory:(SearchCategory *)category andRadius:(int)radiusKilo withLatitude:(float)latitude andLongitude:(float)longitude delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeSearchSimpleGeo;
        
        // default to using this as the delegate for potentially helpful error logging
        [self retain];
        client = [[SimpleGeo alloc] initWithDelegate:self consumerKey:SIMLE_GEO_CONSUMER_KEY consumerSecret:SIMLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
        
        SGPoint *point = [SGPoint pointWithLatitude:latitude longitude:longitude];        
        [client getPlacesNear:point matching:nil inCategory:category.search_category within:radiusKilo];
    }
    return self;
}

- (id)initAndSearchSimpleGeoWithRadius:(int)radiusKilo andName:(NSString *)name withLatitude:(float)latitude andLongitude:(float)longitude delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeSearchSimpleGeo;
        
        // default to using this as the delegate for potentially helpful error logging
        [self retain];
        client = [[SimpleGeo alloc] initWithDelegate:self consumerKey:SIMLE_GEO_CONSUMER_KEY consumerSecret:SIMLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
        
        SGPoint *point = [SGPoint pointWithLatitude:latitude longitude:longitude];
        [client getPlacesNear:point matching:name within:radiusKilo count:SIMLE_GEO_SEARCH_RESULTS_COUNT];
    }
    return self;
}

- (id)initAndSearchGooglePlacesWithRadius:(int)radius andName:(NSString *)name withLatitude:(float)latitude andLongitude:(float)longitude delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGooglePlaceSearch;
        self.delegate = myDelegate;
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@?location=%f,%f&radius=%d&name=%@&sensor=true&key=%@",
                                GOOGLE_PLACE_URL,
                                latitude,
                                longitude,
                                radius,
                                name,
                                GOOGLE_API_KEY] autorelease];
        [self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

- (id)initAndSearchGoogleGeoWithAddress:(NSString *)address andBoundsString:(NSString *)bounds delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeGoogleAddressSearch;
        self.delegate = myDelegate;
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@?address=%@&bounds=%@&sensor=true",
                               GOOGLE_MAPS_API_V3,
                               address,
                               bounds] autorelease];
        [self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

- (id)initAndSetEventAcceptanceWithUserId:(NSString *)userId withEvent:(Event *)event didAccept:(BOOL)didAccept delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeToggleEventAcceptance;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&didAccept=%@",
                               apiURL,
                               @"mod.acceptevent.php",
                               userId,
                               event.eventId,
                               didAccept ? @"true" : @"false"] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetInfoHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeInfo;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                               apiURL,
                               @"info.html"] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetHelpHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeHelp;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                               apiURL,
                               @"help.html"] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndRemoveLocationWithUserId:(NSString *)userId andEventId:(NSString *)eventId andLocationId:(NSString *)locationId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeRemoveLocation;
		self.delegate = myDelegate;
		NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&locationId=%@%@",
                               apiURL,
                               @"deletelocation.php",
                               userId,
                               eventId,
                               locationId,
                               (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease]];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndRemoveEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId doCountOut:(BOOL)countMeOut delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeRemoveEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@%@",
                               apiURL,
                               @"remove.event.php",
                               userId,
                               eventId,
                                countMeOut ? @"&countMeOut=true" : @""] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetRecentParticipantsWithUserId:(NSString *)userId delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        requestId = [[self stringWithUUID] retain];
        pendingRequestType = DataFetchTypeRemoveEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@",
                                apiURL,
                                @"get.participantinfo.php",
                                userId] autorelease];
        NSLog(@"req: %@", urlString);
		[self makeRequest:urlString];
	}
	return self;
}

#pragma mark -
#pragma mark helper methods

- (NSString *)urlencode:(NSString *)aString
{
	aString = [aString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"%26"];
    aString = [aString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	return [aString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

- (NSString *)stringFromDate:(NSDate *)aDate
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *output = [dateFormatter stringFromDate:aDate];
    [dateFormatter release];
	return output;
}

- (void)makeRequest:(NSString *)urlString
{
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
											  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										  timeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
	myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	NSLog(@"http request: %@", urlString);
//	NSLog(@"%@", myConnection);
}

- (void)makeSynchronousRequest:(NSString *)urlString
{
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
											  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										  timeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
    NSError        *error = nil;
    NSURLResponse  *response = nil;
    
    NSLog(@"http request (synchronous): %@", urlString);
    
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    if (error)
    {
       [self handleError:error]; 
    }
    else
    {
        if (!myData) myData = [[NSMutableData alloc] initWithData:data];
        if (delegate) [delegate processServerResponse:myData];
        [myData release];
    }
    self.delegate = nil;
    //	NSLog(@"%@", myConnection);
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2)) {
        // all good, do nothing - didReceiveData will collect response data
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!myData) myData = [[NSMutableData alloc] initWithData:data];
    else [myData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"You seem to have a connection error. Please try again.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    dataFetcherFinished = YES;
    if (myConnection) [myConnection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dataFetcherFinished = YES;
	if (delegate) [delegate processServerResponse:myData];
	self.delegate = nil;
    [myData release];
	[myConnection release];
    
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
}


- (void)handleError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    dataFetcherFinished = YES;
	self.delegate = nil;
    
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"DataFetcherDelegate - handleError: %@", errorMessage);
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_ERROR object:nil userInfo:dict];
}

#pragma mark -
#pragma mark SimpleGeoDelegate methods

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"Request failed: %@: %i", [request responseStatusMessage], [request responseStatusCode]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dataFetcherFinished = YES;
    if (client) [client release];
    self.delegate = nil;
    
    NSString *errorMessage = [request.error localizedDescription];
    NSLog(@"DataFetcherDelegate - handleError: %@", errorMessage);
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_ERROR object:nil userInfo:dict];
    [self release];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    //NSLog(@"Request finished: %@", [request responseString]);
    
}

- (void)didLoadCategories:(NSArray *)categories
{
    NSLog(@"SimpleGeo didLoadCategories");
    dataFetcherFinished = YES;
    if (delegate) [delegate processSimpleGeoCategoryResponse:categories];
	self.delegate = nil;
    if (client) [client release];
    
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
    [self release];
}
- (void)didLoadPlaces:(SGFeatureCollection *)places
             forQuery:(NSDictionary *)query
{
    NSLog(@"SimpleGeo didLoadPlaces");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    dataFetcherFinished = YES;
    
    if (delegate) [delegate processSimpleGeoResponse:places];
	self.delegate = nil;
    if (client) [client release];
    
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
    [self release];
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

- (void) dealloc
{
    [requestId release];
	self.delegate = nil;
    myConnection = nil;
	[super dealloc];
}


@end
