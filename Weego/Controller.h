//
//  Controller.h
//  BigBaby
//
//  Created by Dave Prukop on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataFetcher.h"
#import <MapKit/MapKit.h>

@class Event;
@class Location;
@class Participant;
@class FeedMessage;
@class SearchCategory;

@interface Controller : NSObject {
    DataFetcher *simpleGeoFetcher;
}

+ (Controller *)sharedInstance;
+ (void)destroy;

- (NSString *)loginWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password;
- (NSString *)loginWithFacebookAccessToken:(NSString *)accessToken;
- (NSString *)registerWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName;
- (NSString *)fetchEvents;
- (NSString *)fetchEventWithId:(NSString *)anId andTimestamp:(NSString *)aTimestamp;
- (NSString *)addEvent:(Event *)anEvent;
- (NSString *)updateEvent:(Event *)anEvent;
- (void)removeEvent;
- (NSString *)addOrUpdateLocations:(NSArray *)locations isAnUpdate:(BOOL)update;
- (NSString *)reportLocation:(Location *)aLocation forEvent:(Event *)anEvent;
- (NSString *)reportLocationSynchronous:(Location *)aLocation forEvent:(Event *)anEvent;
- (NSString *)addParticipants:(NSArray *)participants;
- (NSString *)toggleVoteForLocationsWithId:(NSString *)locationId;

//- (NSString *)voteForLocationWithId:(NSString *)locationId;
//- (NSString *)removeVoteForLocationWithId:(NSString *)locationId;

- (NSString *)updateUserDeviceRecord;
- (NSString *)sendFeedMessage:(FeedMessage *)message;
- (NSString *)markFeedMessagesRead;
- (NSString *)resetUserBadge;
- (NSString *)checkinUserForEvent:(Event *)anEvent;
- (NSString *)checkinUserForEventSynchronous:(Event *)anEvent;
- (NSString *)fetchEventsSynchronous;
- (NSString *)fetchReportedLocations;
- (NSString *)searchSimpleGeoForLocation:(Location *)location withRadius:(int)radius;
- (NSString *)searchSimpleGeoForLocation:(Location *)location withRadius:(int)radius andCategory:(SearchCategory *)category;
- (NSString *)searchGooglePlacesForLocation:(Location *)location withRadius:(int)radius;
- (NSString *)searchGoogleGeoForAddress:(NSString *)address northEastBounds:(CLLocationCoordinate2D)northEast southWestBounds:(CLLocationCoordinate2D)southWest;
- (NSString *)setEventAcceptanceForEvent:(Event *)anEvent didAccept:(BOOL)didAccept;
- (NSString *)getInfoHMTLData;
- (NSString *)getHelpHMTLData;
- (NSString *)getDealsHTMLDataWithCode:(NSString *)dealCode;
- (NSString *)getRecentParticipants;
- (NSString *)removeLocationWithId:(NSString *)locationId;
- (NSString *)getSimpleGeoCategories;
- (NSString *)setRemovedForEvent:(Event *)anEvent doCountOut:(BOOL)countOut;
- (NSString *)suggestTimeForEvent:(Event *)anEvent withSuggestedTime:(NSString *)suggestedTime;

@end
