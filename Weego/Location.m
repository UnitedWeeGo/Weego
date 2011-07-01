//
//  Location.m
//  BigBaby
//
//  Created by Nicholas Velloff on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "GDataXMLNode.h"

@interface Location(Private)

- (NSString*) stringWithUUID;

@end

@implementation Location

@synthesize ownerEventId, locationId, addedById, uuid, tempId;
@synthesize latitude, longitude, coordinate, name, vicinity, icon, location_type;
@synthesize g_id, rating, g_reference, formatted_address, formatted_phone_number, stripped_phone_number;
@synthesize isTemporary, addedByMe;
//@synthesize numberOfVotes;
@synthesize hasDeal;
@synthesize hasBeenRemoved;

- (id)initWithPlacesJsonResultDict:(NSDictionary *)jsonResultDict
{
    self = [super init];
	if (!self)
		return nil;
    NSString *uIcon = [jsonResultDict objectForKey:@"icon"];
    NSString *uId = [jsonResultDict objectForKey:@"id"];
    NSString *uName = [jsonResultDict objectForKey:@"name"];
    NSString *uRefernnce = [jsonResultDict objectForKey:@"reference"];
    NSString *uVicinity = [jsonResultDict objectForKey:@"vicinity"];
    NSString *uFormatted_address = [jsonResultDict objectForKey:@"formatted_address"]; // only returned from geo search
    NSDecimalNumber *uLat = [[[jsonResultDict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
    NSDecimalNumber *uLng = [[[jsonResultDict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
    if (uIcon != nil) self.icon = uIcon;
    if (uId != nil) self.g_id = uId;
    self.name = (uId != nil) ? uName : @"Name me!";
    if (uRefernnce != nil) self.g_reference = uRefernnce;
    if (uVicinity != nil) self.vicinity = uVicinity;
    if (uFormatted_address != nil) self.formatted_address = uFormatted_address;
    self.latitude = [uLat stringValue];
    self.longitude = [uLng stringValue];
    self.location_type = (uId != nil) ? @"place" : @"address";
    return self;
}

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uLocationId = [[xml attributeForName:@"id"] stringValue];
    NSString *uAddedById = [[xml attributeForName:@"addedById"] stringValue];
    NSString *uLatitude = [[xml attributeForName:@"latitude"] stringValue];
    NSString *uLongitude = [[xml attributeForName:@"longitude"] stringValue];
    NSString *uName = ((GDataXMLElement *) [[xml elementsForName:@"name"] objectAtIndex:0]).stringValue;
    NSString *uVicinity = ((GDataXMLElement *) [[xml elementsForName:@"vicinity"] objectAtIndex:0]).stringValue;
    NSString *uG_id = ((GDataXMLElement *) [[xml elementsForName:@"g_id"] objectAtIndex:0]).stringValue;
    NSString *uFormatted_address = ((GDataXMLElement *) [[xml elementsForName:@"formatted_address"] objectAtIndex:0]).stringValue;
    // strip ", United Stated" if it exists for better UI
    NSRange toStripRange = [uFormatted_address rangeOfString:@", United States"];
    if (toStripRange.location != NSNotFound)
    {
        uFormatted_address = [uFormatted_address substringWithRange:NSMakeRange(0, toStripRange.location)];
    }
    // strip ", USA" if it exists for better UI
    NSRange toStripRange2 = [uFormatted_address rangeOfString:@", USA"];
    if (toStripRange2.location != NSNotFound)
    {
        uFormatted_address = [uFormatted_address substringWithRange:NSMakeRange(0, toStripRange2.location)];
    }
    NSString *uFormatted_phone_number = ((GDataXMLElement *) [[xml elementsForName:@"formatted_phone_number"] objectAtIndex:0]).stringValue;
    NSString *uRating = ((GDataXMLElement *) [[xml elementsForName:@"rating"] objectAtIndex:0]).stringValue;
    NSString *uLocationType = ((GDataXMLElement *) [[xml elementsForName:@"location_type"] objectAtIndex:0]).stringValue;
    
    NSString *uHasBeenRemoved = [[xml attributeForName:@"hasBeenRemoved"] stringValue];
    //    BOOL removeLocation = [[removeLocStr lowercaseString] isEqualToString:@"true"];
    
    if (uLocationId != nil) self.locationId = uLocationId;
    if (uAddedById != nil) self.addedById = uAddedById;
    if (uLatitude != nil) self.latitude = uLatitude;
    if (uLongitude != nil) self.longitude = uLongitude;
    if (uName != nil) self.name = uName;
    if (uVicinity != nil) self.vicinity = uVicinity;
    if (uG_id != nil) self.g_id = uG_id;
    if (uFormatted_address != nil) self.formatted_address = uFormatted_address;
    if (uFormatted_phone_number != nil) self.formatted_phone_number = uFormatted_phone_number;
    if (uRating != nil) self.rating = uRating;
    if (uLocationType != nil) self.location_type = uLocationType;
    if (uHasBeenRemoved != nil) self.hasBeenRemoved = [[uHasBeenRemoved lowercaseString] isEqualToString:@"true"];
}

- (NSString *)stripped_phone_number
{
    NSString *mobileNumber = [NSString stringWithString:self.formatted_phone_number];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return mobileNumber;
}

- (BOOL)hasDeal
{
    NSString *lastNumber = [longitude substringFromIndex:[longitude length] - 1];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *myNumber = [f numberFromString:lastNumber];
    [f release];
    int isOdd = [myNumber intValue] % 2;
    return (isOdd == 1 && [self.location_type isEqualToString:@"place"]);
}

- (BOOL)addedByMe
{
    return [self.addedById isEqualToString:[Model sharedInstance].userEmail];
}

//- (int)numberOfVotes
//{
//    return [[Model sharedInstance] numberOfVotesForLocationWithId:locationId inEventWithId:ownerEventId];
//}

-(CLLocationCoordinate2D)coordinate
{
    float lat = [latitude floatValue];
    float lon = [longitude floatValue];
    return CLLocationCoordinate2DMake(lat, lon);
}

- (BOOL)hasPendingVoteRequest{
    return [[Model sharedInstance] locationWithIdHasPendingVoteRequest:locationId];
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

- (void)dealloc {
	
//	NSLog(@"Location destroyed");
	
	[ownerEventId release];
	[locationId release];
    [addedById release];
	[uuid release];
    
	[name release];
	[vicinity release];
	[latitude release];
	[longitude release];
    
    [super dealloc];
}

@end