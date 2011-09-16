//
//  LocationReporter.h
//  BigBaby
//
//  Created by Nicholas Velloff on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleGeo/SimpleGeo+Storage.h>

@interface LocationReporter : NSObject <CLLocationManagerDelegate> {
    BOOL locationServicesEnabled;
//    SimpleGeo *client;
    CLLocation *lastLocation;
    CLLocation *lastReportedLocation;
    CLLocationManager *locationManager;
    BOOL locationServicesStarted;
    BOOL locationChangedSignificantly;
    BOOL locationTrackingUserEnabled;
    BOOL checkinUserEnabled;
    BOOL locationSignLocMonitoringStarted;
    int timerCount;
}

+ (LocationReporter *)sharedInstance;

- (void)reportNow;

@end
