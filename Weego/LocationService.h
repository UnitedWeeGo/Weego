//
//  LocationService.h
//  Weego
//
//  Created by Nicholas Velloff on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationService : NSObject <CLLocationManagerDelegate> 
{
    // location manager
    CLLocationManager *locationManager;
    CLLocation *latestValidLocation;
    
    CLLocation *pendingReportedLocation;
    CLLocation *lastSuccessfulReportedLocation;
    
    // in app user preferences
    BOOL locationTrackingUserEnabled;
    BOOL checkinUserEnabled;
    
    // significant location monitoring status
    BOOL significantLoctionMonitoringEnabled;
    
    // location services enabled from iphone settings
    BOOL locationServicesEnabled;
}

+ (LocationService *)sharedInstance;
- (void)reportNow;

@end
