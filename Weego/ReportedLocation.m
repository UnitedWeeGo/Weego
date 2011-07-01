//
//  ReportedLocation.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportedLocation.h"


@implementation ReportedLocation

@synthesize ownerEventId, latitude, longitude, reportTime, userId;

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uLatitude = [[xml attributeForName:@"latitude"] stringValue];
    NSString *uLongitude = [[xml attributeForName:@"longitude"] stringValue];
    NSString *uReportTimestamp = [[xml attributeForName:@"reportTime"] stringValue];
    NSString *uUserId = [[xml attributeForName:@"email"] stringValue];
    
    if (uLatitude) self.latitude = uLatitude;
	if (uLongitude) self.longitude = uLongitude;
    if (uReportTimestamp) self.reportTime = uReportTimestamp;
	if (uUserId) self.userId = uUserId;
}

-(CLLocationCoordinate2D)coordinate
{
    float lat = [latitude floatValue];
    float lon = [longitude floatValue];
    return CLLocationCoordinate2DMake(lat, lon);
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
