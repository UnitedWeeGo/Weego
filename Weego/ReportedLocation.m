//
//  ReportedLocation.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "GDataXMLNode.h"

@interface ReportedLocation(Private)

- (NSDate *)getDateFromString:(NSString *)dateString;

@end

@implementation ReportedLocation

@synthesize ownerEventId, latitude, longitude, reportTime, userId, disableLocationReporting;

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uLatitude = [[xml attributeForName:@"latitude"] stringValue];
    NSString *uLongitude = [[xml attributeForName:@"longitude"] stringValue];
    NSString *uReportTimestamp = [[xml attributeForName:@"reportTime"] stringValue];
    NSString *uUserId = [[xml attributeForName:@"email"] stringValue];
    NSString *uDisabledLocationReporting = [[xml attributeForName:@"disableLocationReporting"] stringValue];
    
    if (uLatitude) self.latitude = uLatitude;
	if (uLongitude) self.longitude = uLongitude;
    if (uReportTimestamp) self.reportTime = uReportTimestamp;
	if (uUserId) self.userId = uUserId;
    if (uDisabledLocationReporting) self.disableLocationReporting = [uDisabledLocationReporting isEqualToString:@"true"];
}

- (CLLocationDistance)distanceFromCLLocation:(CLLocation *)loc
{
    CLLocation *cLoc = [[CLLocation alloc] initWithLatitude:[self coordinate].latitude longitude:[self coordinate].longitude];
    return [cLoc distanceFromLocation:loc];
}

- (CLLocationDistance)distanceFromReportedLocation:(ReportedLocation *)loc
{
    CLLocation *cLoc = [[CLLocation alloc] initWithLatitude:[self coordinate].latitude longitude:[self coordinate].longitude];
    CLLocation *nLoc = [[CLLocation alloc] initWithLatitude:[loc coordinate].latitude longitude:[loc coordinate].longitude];
    return [cLoc distanceFromLocation:nLoc];
}

- (CLLocationCoordinate2D)coordinate
{
    float lat = [latitude floatValue];
    float lon = [longitude floatValue];
    return CLLocationCoordinate2DMake(lat, lon);
}

- (int)minutesSinceLocationReported
{
    NSDate *now = [NSDate date];
    NSDate *reportedDate = [self getDateFromString:self.reportTime];
    NSTimeInterval time = [now timeIntervalSinceDate:reportedDate];
    NSLog(@"NSTimeInterval time: %f", time); 
    return ceil(time/60);
}

- (NSDate *)getDateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *aDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return aDate;
}

- (void)dealloc {
    [ownerEventId release];
    [latitude release];
    [longitude release];
    [reportTime release];
    [userId release];
    [super dealloc];
}
@end
