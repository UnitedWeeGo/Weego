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
    CLLocationManager *locationManager;
    BOOL locationServicesStarted;
    BOOL locationChangedSignificantly;
    BOOL locationTrackingEnabled;
    BOOL locationSignLocMonitoringStarted;
    int timerCount;
}

+ (LocationReporter *)sharedInstance;

@end
