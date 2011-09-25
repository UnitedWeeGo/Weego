//
//  Location.h
//  BigBaby
//
//  Created by Nicholas Velloff on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface Location : NSObject{
	
}
// use reference to get place detail, use id to check dupes
@property (nonatomic, copy) NSString *g_reference;
@property (nonatomic, copy) NSString *g_id;

@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *locationId;
@property (nonatomic, copy) NSString *addedById;
@property (nonatomic, copy) NSString *tempId;

// basic info
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *vicinity;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *location_type;

// detail call
@property (nonatomic, copy) NSString *formatted_phone_number;
@property (nonatomic, readonly) NSString *stripped_phone_number;
@property (nonatomic, copy) NSString *formatted_address;
@property (nonatomic, copy) NSString *rating;


@property (nonatomic, readonly) BOOL hasDeal;
@property (nonatomic, readonly) BOOL addedByMe;
@property (nonatomic) BOOL disableLocationReporting;


@property (nonatomic) BOOL isTemporary;
@property (nonatomic) BOOL hasBeenAddedToMapPreviously;
//@property (readonly) int numberOfVotes;

@property (nonatomic, readonly) BOOL hasPendingVoteRequest;

@property (nonatomic) BOOL hasBeenRemoved;

- (void)populateWithXml:(GDataXMLElement *)xml;
- (id)initWithSimpleGeoFeatureResult:(SGFeature *)feature;
- (id)initWithSimpleGeoAddressResult:(SGContext *)context;
- (id)initWithPlacesJsonResultDict:(NSDictionary *)jsonResultDict;
- (NSString*) stringWithUUID;

@end
