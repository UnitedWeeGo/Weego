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
    NSMutableDictionary *geoRequestHolder;
}

+ (Controller *)sharedInstance;
+ (void)destroy;

- (void)releaseSimpleGeoFetcherWithKey:(NSString *)key;
- (NSString *)loginWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password;
- (NSString *)loginWithFacebookAccessToken:(NSString *)accessToken;
- (NSString *)registerWithEmailAddress:(NSString *)emailAddress andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName;
- (NSString *)fetchEvents;
- (NSString *)fetchEventWithId:(NSString *)anId andTimestamp:(NSString *)aTimestamp;
- (NSString *)addEvent:(Event *)anEvent;
- (NSString *)updateEvent:(Event *)anEvent;
- (void)removeEvent;
- (NSString *)addOrUpdateLocations:(NSArray *)locations isAnUpdate:(BOOL)update;
- (NSString *)addParticipants:(NSArray *)participants;
- (NSString *)toggleVoteForLocationsWithId:(NSString *)locationId;
- (NSString *)updateUserDeviceRecord;
- (NSString *)sendFeedMessage:(FeedMessage *)message;
- (NSString *)markFeedMessagesRead;
- (NSString *)resetUserBadge;
- (NSString *)checkinUserForEvent:(Event *)anEvent;
- (NSString *)checkinUserForEventSynchronous:(Event *)anEvent;
- (NSString *)fetchEventsSynchronous;

// Location reporting
- (NSString *)fetchReportedLocations;
- (NSString *)reportLocation:(Location *)aLocation;
- (NSString *)reportLocationSynchronous:(Location *)aLocation;

// SimpleGeo lookups
- (NSString *)getSimpleGeoCategories;
- (id)searchSimpleGeoWithCategory:(SearchCategory *)category andEnvelope:(SGEnvelope *)envelope;
- (id)searchSimpleGeoWithEnvelope:(SGEnvelope *)envelope andName:(NSString *)name;
- (id)searchSimpleGeoForAddressWithCoordinate:(CLLocationCoordinate2D)coord;

// Google lookup
- (NSString *)searchGoogleGeoForAddress:(NSString *)address northEastBounds:(CLLocationCoordinate2D)northEast southWestBounds:(CLLocationCoordinate2D)southWest;

// Yelp lookup
- (id)searchYelpForName:(NSString *)name northEastBounds:(CLLocationCoordinate2D)northEast southWestBounds:(CLLocationCoordinate2D)southWest;
- (id)getYelpCategories;

- (NSString *)setEventAcceptanceForEvent:(Event *)anEvent didAccept:(BOOL)didAccept;
- (NSString *)getInfoHMTLData;
- (NSString *)getHelpHMTLData;
- (NSString *)getTermsHMTLData;
- (NSString *)getPrivacyHMTLData;
- (NSString *)getDealsHTMLDataWithSGID:(NSString *)sg_id;
- (NSString *)getRecentParticipants;
- (NSString *)removeLocationWithId:(NSString *)locationId;
- (NSString *)setRemovedForEvent:(Event *)anEvent doCountOut:(BOOL)countOut doCancel:(BOOL)cancel;
- (NSString *)suggestTimeForEvent:(Event *)anEvent withSuggestedTime:(NSString *)suggestedTime;

// Toggle event decided status
- (NSString *)toggleDecidedForCurrentEvent;

@end
