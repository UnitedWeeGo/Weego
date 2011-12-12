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
#import "OAuthConsumer.h"

#define GOOGLE_PLACE_URL @"https://maps.googleapis.com/maps/api/place/search/json"
#define GOOGLE_MAPS_API_V3 @"http://maps.google.com/maps/api/geocode/json"
#define YELP_API_V2 @"http://api.yelp.com/v2/search"
#define PUBLIC_HTTP_URL @"http://unitedweego.com/"

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
- (void)makeRequestRespectingCache:(NSString *)urlString;
- (void)makeYelpRequest:(NSString *)urlString;
- (void)handleError:(NSError *)error;
- (void)makeSynchronousRequest:(NSString *)urlString;
- (NSString*) stringWithUUID;
- (void)handleError:(NSError *)error;

@end

@implementation DataFetcher

@synthesize delegate;
@synthesize myData;
@synthesize dataFetcherFinished;
@synthesize client;
@synthesize requestId;

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
#if API_TYPE == 4
        apiURL = @"https://api.unitedweego.com/";
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        if (model.isInTrial) { // && model.currentViewState != ViewStateCreate) {
            [model printModel];
            NSMutableArray *trialEvents = [NSMutableArray arrayWithArray:[model.allEvents allValues]];
            if (model.currentViewState == ViewStateCreate) [trialEvents removeObject:model.currentEvent];
            NSString *xmlString = [[Model sharedInstance] getCreateEventXML:trialEvents];
            [postBody appendData:[[[[NSString alloc] initWithFormat:@"xml=%@&",[self urlencode:xmlString]] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
            if (model.currentViewState == ViewStateDetails && model.currentEvent) {
                [postBody appendData:[[[[NSString alloc] initWithFormat:@"requestId=%@&", model.currentEvent.eventId] autorelease] dataUsingEncoding:NSUTF8StringEncoding]];
            }
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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
        self.requestId = [self stringWithUUID];
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

- (id)initAndToggleVotesWithUserId:(NSString *)userId withEvent:(Event *)event withLocations:(NSArray *)locationIds delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
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

- (id)initAndAddParticipantWithUserId:(NSString *)userId toEventId:(NSString *)eventId withEmailAddress:(NSString *)emailAddress delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
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

- (id)initAndSuggestTimeWithUserId:(NSString *)userId toEventId:(NSString *)eventId withSuggestedTime:(NSString *)suggestedTime withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSuggestTime;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&suggestedTime=%@%@",
                                apiURL,
                                @"suggesttime.php",
                                userId,
                                eventId,
                                suggestedTime,
                                (!timestamp) ? @"" : [NSString stringWithFormat:@"&timestamp=%@", timestamp]] autorelease];
                                
		[self makeRequest:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	return self;
}

- (id)initAndCheckinWithUserId:(NSString *)userId toEventId:(NSString *)eventId intoLocationId:(NSString *)locationId overrideSynchronous:(BOOL)useSync delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
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

- (id)initAndReportNewLocationWithUserId:(NSString *)userId overrideSynchronous:(BOOL)useSync withLocation:(Location *)aLocation delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeReportNewLocationToEvent;
		self.delegate = myDelegate;
        NSString *locationReportingStatus = (aLocation.disableLocationReporting) ? @"&disableLocationReporting=true" : @"&disableLocationReporting=false";
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&latitude=%f&longitude=%f%@",
                                apiURL,
                                @"report.location.php",
                                userId,
                                aLocation.coordinate.latitude,
                                aLocation.coordinate.longitude,
                                locationReportingStatus] autorelease];
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
        self.requestId = [self stringWithUUID];
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

- (id)initAndGetWeegoCategoriesWithUserId:(NSString *)userId delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeGetWeegoCategories;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@",
                                apiURL,
                                @"categories.php",
                                userId] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetSimpleGeoCategoriesWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSearchSimpleGeoCategories;
        
        self.client = [SimpleGeo clientWithConsumerKey:SIMPLE_GEO_CONSUMER_KEY consumerSecret:SIMPLE_GEO_CONSUMER_SECRET];        
        self.delegate = myDelegate;
        
        [self.client getCategoriesWithCallback:[SGCallback callbackWithSuccessBlock:
                                                ^(id response) {
                                                    NSLog(@"SimpleGeo didLoadCategories");
                                                    dataFetcherFinished = YES;
                                                    if (delegate) [delegate processSimpleGeoCategoryResponse:response];
                                                    self.delegate = nil;
                                                    
                                                    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, nil];
                                                    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
                                                    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
                                                    
                                                    [[Controller sharedInstance] releaseSimpleGeoFetcherWithKey:self.requestId];
                                                } failureBlock: ^(NSError *error) {
                                                    [self handleError:error];
                                                }]];
    }
    return self;
}

- (id)initAndSearchSimpleGeoWithCategory:(SearchCategory *)category andEnvelope:(SGEnvelope *)envelope delegate:(id <DataFetcherDelegate>)myDelegate
{
    
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSearchSimpleGeo;
        
        // default to using this as the delegate for potentially helpful error logging
        self.client = [SimpleGeo clientWithConsumerKey:SIMPLE_GEO_CONSUMER_KEY consumerSecret:SIMPLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
                
        SGPlacesQuery *query = [[[SGPlacesQuery alloc] initWithEnvelope:envelope] autorelease];
        [query setLimit:SIMPLE_GEO_SEARCH_RESULTS_COUNT];
        [query setCategories:[NSArray arrayWithObjects:category.search_category, nil]];
        
        [client getPlacesForQuery:query callback:[SGCallback callbackWithSuccessBlock:
                                                  ^(id response) {
                                                      // you've got Places!
                                                      // to create an array of SGPlace objects...
                                                      NSArray *places = [NSArray arrayWithSGCollection:response
                                                                                                  type:SGCollectionTypePlaces];
                                                      
                                                      
                                                      NSLog(@"SimpleGeo didLoadPlaces");
                                                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                      dataFetcherFinished = YES;
                                                      
                                                      if (delegate) [delegate processSimpleGeoResponse:places];
                                                      self.delegate = nil;
                                                      
                                                      NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, nil];
                                                      NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
                                                      NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
                                                      
                                                      [[Controller sharedInstance] releaseSimpleGeoFetcherWithKey:self.requestId];
                                                      
                                                      
                                                  } failureBlock: ^(NSError *error) {
                                                      [self handleError:error];
                                                  }]];
        
    }
    return self;
}

- (id)initAndSearchSimpleGeoWithEnvelope:(SGEnvelope *)envelope andName:(NSString *)name delegate:(id <DataFetcherDelegate>)myDelegate
{
    
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSearchSimpleGeo;
        
        // default to using this as the delegate for potentially helpful error logging
        self.client = [SimpleGeo clientWithConsumerKey:SIMPLE_GEO_CONSUMER_KEY consumerSecret:SIMPLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
#warning may need to escape name data as such: [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
        SGPlacesQuery *query = [[[SGPlacesQuery alloc] initWithEnvelope:envelope] autorelease];
        [query setSearchString:name];
        [query setLimit:SIMPLE_GEO_SEARCH_RESULTS_COUNT];
        
        [client getPlacesForQuery:query callback:[SGCallback callbackWithSuccessBlock:
                                                  ^(id response) {
                                                      // you've got Places!
                                                      // to create an array of SGPlace objects...
                                                      NSArray *places = [NSArray arrayWithSGCollection:response
                                                                                                  type:SGCollectionTypePlaces];
                                                      
                                                      
                                                      NSLog(@"SimpleGeo didLoadPlaces");
                                                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                      dataFetcherFinished = YES;
                                                      
                                                      if (delegate) [delegate processSimpleGeoResponse:places];
                                                      self.delegate = nil;
                                                      
                                                      NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, nil];
                                                      NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
                                                      NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
                                                      
                                                      [[Controller sharedInstance] releaseSimpleGeoFetcherWithKey:self.requestId];
                                                      
                                                      
                                                  } failureBlock: ^(NSError *error) {
                                                      [self handleError:error];
                                                  }]];
        
    }
    return self;
}

- (id)initAndSearchSimpleGeoForAddressWithCoordinate:(CLLocationCoordinate2D)coord delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSearchSimpleGeoCurrentLocation;
        
        // default to using this as the delegate for potentially helpful error logging
        self.client = [SimpleGeo clientWithConsumerKey:SIMPLE_GEO_CONSUMER_KEY consumerSecret:SIMPLE_GEO_CONSUMER_SECRET];
        self.delegate = myDelegate;
        
        SGPoint *point = [SGPoint pointWithLat:coord.latitude lon:coord.longitude];
        
        SGContextQuery *query = [SGContextQuery queryWithPoint:point];
        [query setFilters:[NSArray arrayWithObject:SGContextFilterAddress]];
                
        [client getContextForQuery:query callback:[SGCallback callbackWithSuccessBlock:
                                                  ^(id response) {
                                                      // you've got Places!
                                                      // to create an array of SGPlace objects...
                                                      
                                                      SGContext *context = [SGContext contextWithDictionary:response];
                                                      
                                                      NSLog(@"SimpleGeo didLoadContext");
                                                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                      dataFetcherFinished = YES;
                                                      
                                                      if (delegate) [delegate processSimpleGeoContextResponse:context];
                                                      self.delegate = nil;
                                                      
                                                      NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, nil];
                                                      NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
                                                      NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
                                                      
                                                      [[Controller sharedInstance] releaseSimpleGeoFetcherWithKey:self.requestId];
                                                      
                                                      
                                                  } failureBlock: ^(NSError *error) {
                                                      [self handleError:error];
                                                  }]];
        
    }
    return self;
}

- (id)initAndSearchYelpWithName:(NSString *)name andBoundsString:(NSString *)bounds delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeSearchYelp;
        self.delegate = myDelegate;
        
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@?term=%@&bounds=%@&sort=0",
                                YELP_API_V2,
                                [self urlencode:name],
                                [self urlencode:bounds]] autorelease];
        
        [self makeYelpRequest:urlString];
    }
    return self;
}

- (id)initAndSearchGoogleGeoWithAddress:(NSString *)address andBoundsString:(NSString *)bounds delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeGoogleAddressSearch;
        self.delegate = myDelegate;
        NSString *urlString = [[[NSString alloc] initWithFormat:@"%@?address=%@&bounds=%@&sensor=true",
                                GOOGLE_MAPS_API_V3,
                                [self urlencode:address],
                                [self urlencode:bounds]] autorelease];
        [self makeRequest:urlString];
    }
    return self;
}

- (id)initAndSetEventAcceptanceWithUserId:(NSString *)userId withEvent:(Event *)event didAccept:(BOOL)didAccept delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
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

- (id)initAndGetReviewHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate andURLString:(NSString *)urlString
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeReviewHTML;
		self.delegate = myDelegate;
        [self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetInfoHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeInfo;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                               PUBLIC_HTTP_URL,
                               @"info.html"] autorelease];
        [self makeRequest:urlString];
//		[self makeRequestRespectingCache:urlString];
	}
	return self;
}

- (id)initAndGetHelpHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeHelp;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                               PUBLIC_HTTP_URL,
                               @"help.html"] autorelease];
        [self makeRequest:urlString];
//		[self makeRequestRespectingCache:urlString];
	}
	return self;
}

- (id)initAndGetTermsHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeTerms;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                                PUBLIC_HTTP_URL,
                                @"terms.html"] autorelease];
        [self makeRequest:urlString];
//		[self makeRequestRespectingCache:urlString];
	}
	return self;
}

- (id)initAndGetPrivacyHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypePrivacy;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@",
                                PUBLIC_HTTP_URL,
                                @"privacy.html"] autorelease];
        [self makeRequest:urlString];
//		[self makeRequestRespectingCache:urlString];
	}
	return self;
}

- (id)initAndGetDealsHMTLDataWithUserId:(NSString *)userId withSGID:(NSString *)sg_id withTimestamp:(NSString *)timestamp withDelegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeDeal;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&sg_id=%@&timestamp=%@",
                                apiURL,
                                @"deal.php",
                                userId,
                                [self urlencode:sg_id],
                                [self urlencode:timestamp]] autorelease];
        [self makeRequest:urlString];
	}
	return self;
}

- (id)initAndRemoveLocationWithUserId:(NSString *)userId andEventId:(NSString *)eventId andLocationId:(NSString *)locationId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
	self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeRemoveLocation;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@&locationId=%@%@",
                               apiURL,
                               @"deletelocation.php",
                               userId,
                               eventId,
                               locationId,
                               (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease]] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndRemoveEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId doCountOut:(BOOL)countMeOut doCancel:(BOOL)cancel withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeRemoveEvent;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@%@%@%@",
                               apiURL,
                               @"remove.event.php",
                               userId,
                               eventId,
                               cancel ? @"&cancel=true" : @"",
                                (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease],
                               countMeOut ? @"&countMeOut=true" : @""] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndToggleDecidedStatusForEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeToggleEventDecidedStatus;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@&eventId=%@%@",
                                apiURL,
                                @"toggle.decided.php",
                                userId,
                                eventId,
                                (!timestamp) ? @"" : [[[NSString alloc] initWithFormat:@"&timestamp=%@", [self urlencode:timestamp]] autorelease] ] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

- (id)initAndGetRecentParticipantsWithUserId:(NSString *)userId delegate:(id <DataFetcherDelegate>)myDelegate
{
    self = [self init];
	if (self != nil) {
        self.requestId = [self stringWithUUID];
        pendingRequestType = DataFetchTypeRecentParticipants;
		self.delegate = myDelegate;
		NSString *urlString = [[[NSString alloc] initWithFormat:@"%@%@?registeredId=%@",
                                apiURL,
                                @"get.participantinfo.php",
                                userId] autorelease];
		[self makeRequest:urlString];
	}
	return self;
}

#pragma mark -
#pragma mark helper methods

- (NSString *)urlencode:(NSString *)aString
{
    NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)aString,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]", //The characters you want to replace go here
                                                                                   kCFStringEncodingUTF8 );
    return encodedString;
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

- (void)makeRequestRespectingCache:(NSString *)urlString
{
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] 
											  cachePolicy:NSURLRequestReturnCacheDataElseLoad
										  timeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
	myConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	NSLog(@"http request: %@", urlString);
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

// Yelp requires OAuth request signing
- (void)makeYelpRequest:(NSString *)urlString
{
    NSURL *URL = [NSURL URLWithString:urlString];
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"MRgCPmRplDC1JJEmPnTykg" secret:@"1zZPJCuqmCqBOdCboPEGwLMMICQ="] autorelease];
    OAToken *token = [[[OAToken alloc] initWithKey:@"DRVA5JDqUagRLV8wmnV7vpIm5qMjwz0q" secret:@"wueZ5gAPHSCUjOqdYy-6AdC9U-g"] autorelease];  
    
    id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
    NSString *realm = nil;  
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request setTimeoutInterval:DATA_FETCH_TIMEOUT_SECONDS_INTERVAL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request prepare];
    
    myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	NSLog(@"http request: %@", urlString);
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
    
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_SUCCESS object:nil userInfo:dict];
}


- (void)handleError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    dataFetcherFinished = YES;
	self.delegate = nil;
    [[Controller sharedInstance] releaseSimpleGeoFetcherWithKey:self.requestId]; // will only release if this is a SimpleGeo error
        
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"DataFetcherDelegate - handleError: %@", errorMessage);
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInteger:pendingRequestType], self.requestId, [NSNumber numberWithInteger:error.code], nil];
    NSArray *keys = [NSArray arrayWithObjects:DataFetcherDidCompleteRequestKey, DataFetcherRequestUUIDKey, DataFetcherErrorKey, nil];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_FETCHER_ERROR object:nil userInfo:dict];
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
    //[client release];
    //client = nil;
    [self.requestId release];
	self.delegate = nil;
    myConnection = nil;
	[super dealloc];
}


@end
