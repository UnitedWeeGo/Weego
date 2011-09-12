//
//  DataDelegate.h
//  BigBaby
//
//  Created by Dave Prukop on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleGeo/SimpleGeo.h>
#import "SearchCategory.h"

#define DATA_FETCHER_FINISHED 1
#define DATA_FETCHER_ERROR @"DataFetcherError"
#define DATA_FETCHER_SUCCESS @"DataFetcherSuccess"
#define DataFetcherDidCompleteRequestKey @"DataFetcherDidCompleteRequestKey"
#define DataFetcherRequestUUIDKey @"DataFetcherRequestUUIDKey"
#define DataFetcherErrorKey @"DataFetcherErrorKey"

enum {
	DataFetchTypeUpdateDeviceRecord,
	DataFetchTypeAddMessage,
    DataFetchTypeMarkFeedMessagesRead,
	DataFetchTypeResetUserBadge,
    DataFetchTypeLoginWithUserName,
    DataFetchTypeLoginWithFacebookAccessToken,
    DataFetchTypeRegister,
    DataFetchTypeRecentParticipants,
    DataFetchTypeGetAllEvents,
    DataFetchTypeGetDashboardEvents,
    DataFetchTypeGetEvent,
    DataFetchTypeCreateNewEvent,
    DataFetchTypeUpdateEvent,
    DataFetchTypeUpdateParticipants,
    DataFetchTypeAddNewLocationToEvent,
    DataFetchTypeUpdateLocationToEvent,
    DataFetchTypeReportNewLocationToEvent,
    DataFetchTypeToggleVotesForEvent,
    DataFetchTypeAddVoteToLocation,
    DataFetchTypeRemoveVoteFromLocation,
    DataFetchTypeAddParticipant,
    DataFetchTypeSuggestTime,
    DataFetchTypeCheckin,
    DataFetchTypeGetReportedLocations,
    DataFetchTypeGooglePlaceSearch,
    DataFetchTypeGoogleAddressSearch,
    DataFetchTypeToggleEventAcceptance,
    DataFetchTypeInfo,
    DataFetchTypeHelp,
    DataFetchTypeTerms,
    DataFetchTypePrivacy,
    DataFetchTypeDeal,
    DataFetchTypeRemoveLocation,
    DataFetchTypeRemoveEvent,
    DataFetchTypeSearchSimpleGeo,
    DataFetchTypeSearchSimpleGeoCategories
};
typedef NSInteger DataFetchType;

@class Event;
@class Location;

@protocol DataFetcherDelegate <NSObject>

@optional
- (void)processServerResponse:(NSMutableData *)myData;
- (void)processSimpleGeoResponse:(NSArray *)places;
- (void)processSimpleGeoCategoryResponse:(NSArray *)categories;
@end

@protocol DataFetcherMessageHandler

- (void)setUpDataFetcherMessageListeners;
- (void)removeDataFetcherMessageListeners;
- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification;
- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification;

@end


//#pragma mark - DataFetcherMessageHandler
//
//- (void)setUpDataFetcherMessageListeners
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherSuccessMessage:) name:DATA_FETCHER_SUCCESS object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherErrorMessage:) name:DATA_FETCHER_ERROR object:nil];
//}
//
//- (void)removeDataFetcherMessageListeners
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_SUCCESS object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_FETCHER_ERROR object:nil];
//}
//
//- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
//{
//    NSDictionary *dict = [aNotification userInfo];
//    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
//    switch (fetchType) {
//        case <#constant#>
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
//{
//    NSDictionary *dict = [aNotification userInfo];
//    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
//    switch (fetchType) {
//        case <#constant#>
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }
//}

@interface DataFetcher : NSObject <NSXMLParserDelegate> {
	
	id <DataFetcherDelegate> delegate;
	NSURLConnection *myConnection;
    NSMutableData *myData;
    BOOL dataFetcherFinished;
	DataFetchType pendingRequestType;
    NSString *apiURL;
}

@property (nonatomic, assign) id <DataFetcherDelegate> delegate;
@property (readonly) BOOL dataFetcherFinished;
@property (nonatomic, retain) NSString *requestId;
@property (nonatomic, retain) SimpleGeo *client;

- (id)initAndLoginWithUserName:(NSString *)emailAddress andPassword:(NSString *)password delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndLoginWithFacebookAccessToken:(NSString *)accessToken delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndRegisterWithUserName:(NSString *)emailAddress andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetAllEventsWithUserId:(NSString *)userId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetDashboardEventsWithUserId:(NSString *)userId overrideSynchronous:(BOOL)useSync withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndCreateNewEventWithUserId:(NSString *)userId withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndUpdateEventWithUserId:(NSString *)userId withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndUpdateParticipantsWithUserId:(NSString *)userId withParticipants:(NSArray *)participants withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndAddOrUpdateLocationsWithUserId:(NSString *)userId withLocations:(NSArray *)locations isAnUpdate:(BOOL)update withEvent:(Event *)event delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndToggleVotesWithUserId:(NSString *)userId withEvent:(Event *)event withLocations:(NSArray *)locationIds delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndAddVoteToLocationWithUserId:(NSString *)userId toEventId:(NSString *)eventId withLocationId:(NSString *)locationId delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndRemoveVoteFromLocationWithUserId:(NSString *)userId toEventId:(NSString *)eventId withLocationId:(NSString *)locationId delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndAddParticipantWithUserId:(NSString *)userId toEventId:(NSString *)eventId withEmailAddress:(NSString *)emailAddress delegate:(id <DataFetcherDelegate>)myDelegate;
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
                                 delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndAddMessageWithUserId:(NSString *)userId andEventId:(NSString *)eventId andMessageString:(NSString *)messageString andImageUrl:(NSString *)imageUrlString andTimestamp:(NSString *)aTimestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndMarkFeedMessagesRead:(NSString *)userId andEventId:(NSString *)eventId delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndResetUserBadge:(NSString *)userId andDeviceUuid:(NSString *)deviceUuid delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndCheckinWithUserId:(NSString *)userId toEventId:(NSString *)eventId intoLocationId:(NSString *)locationId overrideSynchronous:(BOOL)useSync delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndReportNewLocationToEventWithUserId:(NSString *)userId overrideSynchronous:(BOOL)useSync withEventId:(NSString *)eventId withLocation:(Location *)aLocation delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetReportedLocationsWithUserId:(NSString *)userId andEventId:(NSString *)eventId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndSetEventAcceptanceWithUserId:(NSString *)userId withEvent:(Event *)event didAccept:(BOOL)didAccept delegate:(id <DataFetcherDelegate>)myDelegate;

- (id)initAndGetDealsHMTLDataWithUserId:(NSString *)userId withSGID:(NSString *)sg_id withTimestamp:(NSString *)timestamp withDelegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndRemoveLocationWithUserId:(NSString *)userId andEventId:(NSString *)eventId andLocationId:(NSString *)locationId withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;

// HTML views - terms, privacy, help, info
- (id)initAndGetInfoHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetHelpHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetTermsHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndGetPrivacyHMTLDataWithDelegate:(id <DataFetcherDelegate>)myDelegate;

// SimpleGeo
- (id)initAndGetSimpleGeoCategoriesWithDelegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndSearchSimpleGeoWithCategory:(SearchCategory *)category andEnvelope:(SGEnvelope *)envelope delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndSearchSimpleGeoWithEnvelope:(SGEnvelope *)envelope andName:(NSString *)name delegate:(id <DataFetcherDelegate>)myDelegate;

// Google geo
- (id)initAndSearchGoogleGeoWithAddress:(NSString *)address andBoundsString:(NSString *)bounds delegate:(id <DataFetcherDelegate>)myDelegate;


// suggest and remove
- (id)initAndRemoveEventWithUserId:(NSString *)userId andEventId:(NSString *)eventId doCountOut:(BOOL)countMeOut doCancel:(BOOL)cancel withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;
- (id)initAndSuggestTimeWithUserId:(NSString *)userId toEventId:(NSString *)eventId withSuggestedTime:(NSString *)suggestedDate withTimestamp:(NSString *)timestamp delegate:(id <DataFetcherDelegate>)myDelegate;

- (id)initAndGetRecentParticipantsWithUserId:(NSString *)userId delegate:(id <DataFetcherDelegate>)myDelegate;

@end
