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

@interface Controller : NSObject {
//    DataFetcher *fetcher;
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
/* DEPRICATED
- (NSString *)addLocation:(Location *)aLocation;
 */
- (NSString *)addOrUpdateLocations:(NSArray *)locations isAnUpdate:(BOOL)update;
- (NSString *)reportLocation:(Location *)aLocation forEvent:(Event *)anEvent;
- (NSString *)reportLocationSynchronous:(Location *)aLocation forEvent:(Event *)anEvent;
- (NSString *)addParticipants:(NSArray *)participants;
- (NSString *)toggleVoteForLocationsWithId:(NSString *)locationId;

- (NSString *)voteForLocationWithId:(NSString *)locationId;
- (NSString *)removeVoteForLocationWithId:(NSString *)locationId;

- (NSString *)updateUserDeviceRecord;
- (NSString *)sendFeedMessage:(FeedMessage *)message;
- (NSString *)markFeedMessagesRead;
- (NSString *)resetUserBadge;
- (NSString *)writeStringToLog:(NSString *)logMessage;
- (NSString *)clearLog;
- (NSString *)checkinUserForEvent:(Event *)anEvent;
- (NSString *)checkinUserForEventSynchronous:(Event *)anEvent;
- (NSString *)fetchEventsSynchronous;
- (NSString *)fetchReportedLocations;
- (NSString *)searchGooglePlacesForLocation:(Location *)location withRadius:(int)radius;
- (NSString *)searchGoogleGeoForAddress:(NSString *)address northEastBounds:(CLLocationCoordinate2D)northEast southWestBounds:(CLLocationCoordinate2D)southWest;
- (NSString *)setEventAcceptanceForEvent:(Event *)anEvent didAccept:(BOOL)didAccept;
- (NSString *)getInfoHMTLData;
- (NSString *)getHelpHMTLData;
- (NSString *)removeLocationWithId:(NSString *)locationId;

@end