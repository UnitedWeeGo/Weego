//
//  LocationReporter.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationReporter.h"
#import "Event.h"
#import "Location.h"

@interface LocationReporter(Private)

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)checkEventsForCheckin;
- (void)checkinUserForEvent:(Event *)event;
- (int)minuteDistanceBetweenNowAndDate:(NSDate *)aDate;
- (void)reportUserLocation:(CLLocation *)location andEvent:(Event *)event;

@end

@implementation LocationReporter

static LocationReporter *sharedInstance;

+ (LocationReporter *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[LocationReporter alloc] init];       
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationReporter.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

-(id) init {
    if (self == [super init]) {
        timerCount = 0;
        locationServicesStarted = NO;
        locationChangedSignificantly = NO;
        locationSignLocMonitoringStarted = NO;
        locationServicesEnabled = [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
        if(locationServicesEnabled) 
        {
//            client = [[SimpleGeo alloc] initWithDelegate:self consumerKey:@"bcRryckAyj5YT3ZrSGraENdxqdLJRz9Q" consumerSecret:@"q2AMUDLyHpcPuaKkETchSqxQaPrY2fD9"];
//            client.delegate = self;
            
            locationManager = [[CLLocationManager alloc] init];
            locationManager.purpose = @"Around the time of the event, we report your location and arrival only to the invited participants.";
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            // should wake up the app periodically            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportTimerTick) name:SYNCH_MINUTE_TIMER_TICK object:nil];
        }
    }
    return self;
}

- (void)startUpdatingLocation
{
    locationServicesStarted = YES;
    [locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    locationServicesStarted = NO;
    [locationManager stopUpdatingLocation];
}

- (void)reportTimerTick
{    
    locationTrackingUserEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_ALLOW_TRACKING];
    checkinUserEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_ALLOW_CHECKIN];
    if (!locationTrackingUserEnabled && !checkinUserEnabled)
    {
        if (locationServicesStarted) [self stopUpdatingLocation];
        if (locationSignLocMonitoringStarted)
        {
            locationSignLocMonitoringStarted = NO;
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [locationManager stopMonitoringSignificantLocationChanges];
        }
        return; // we dont want to interate over anything if user is not allowing tracking
    }
    else
    {
        if (!locationSignLocMonitoringStarted)
        {
            locationSignLocMonitoringStarted = YES;
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [locationManager startMonitoringSignificantLocationChanges];
        }
    }
    
    Model *model = [Model sharedInstance];
    BOOL locationServicesShouldStart = NO;
//    NSLog(@"LocationReporter::reportTimerTick :: model.allEvents count: %d", [model.allEvents count]);
    
    NSArray *allEvents = [model.allEvents allValues];
    
    for ( Event *e in allEvents )
    {
        BOOL eventIsWithinTimeRange = e.minutesToGoUntilEventStarts < (CHECKIN_TIME_RANGE_MINUTES/2) && e.minutesToGoUntilEventStarts > (-CHECKIN_TIME_RANGE_MINUTES/2);
//        NSLog(@"eventIsWithinTimeRange: %d", eventIsWithinTimeRange);
        
        BOOL eventHasBeenCheckedIn = e.hasBeenCheckedIn;
//        NSLog(@"eventHasBeenCheckedIn: %d", eventHasBeenCheckedIn);
        
//        NSLog(@"topLocationId: %@", e.topLocationId);
        
        Location *loc = [e getLocationByLocationId:e.topLocationId];
        BOOL hasADecidedLocation = (loc != nil);
//        NSLog(@"hasADecidedLocation: %d", hasADecidedLocation);
        
        BOOL eventIsBeingCreated = e.isTemporary;
//        NSLog(@"eventIsBeingCreated: %d", eventIsBeingCreated);
        
        BOOL userAcceptedEvent = e.acceptanceStatus ==  AcceptanceTypeAccepted;
        
        if (eventIsWithinTimeRange && !eventHasBeenCheckedIn && hasADecidedLocation && !eventIsBeingCreated && userAcceptedEvent && (locationTrackingUserEnabled || checkinUserEnabled)) 
        {
            locationServicesShouldStart = YES;
        }
        
        BOOL eventEligibleForLocationReporting = (userAcceptedEvent && eventIsWithinTimeRange && !eventHasBeenCheckedIn && hasADecidedLocation && !eventIsBeingCreated && locationChangedSignificantly && locationTrackingUserEnabled);
        if (eventEligibleForLocationReporting) 
        {
            [self reportUserLocation:lastLocation andEvent:e];
            locationChangedSignificantly = NO;
        }
        
    }
    
    // start and stop location services
    if (locationServicesShouldStart && !locationServicesStarted)
    {
        NSLog(@"LocationReporter::startUpdatingLocation");
        if (lastLocation != nil) [lastLocation release];
        lastLocation = nil;
        [self startUpdatingLocation];
    }
    else if (!locationServicesShouldStart && locationServicesStarted)
    {
        NSLog(@"LocationReporter::stopUpdatingLocation");
        [self stopUpdatingLocation];
    }
    
    // check for stale data if in the background, fetch if needed
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        int numMinutesSinceLastFetchAttempt = [self minuteDistanceBetweenNowAndDate:model.lastFetchAttempt];
        if (numMinutesSinceLastFetchAttempt > STALE_DATA_FETCH_MINUTES_THRESHOLD) 
        {
            NSLog(@"numMinutesSinceLastFetchAttempt: %d, fetchEventsSynchronous", numMinutesSinceLastFetchAttempt);
            [[Controller sharedInstance] fetchEventsSynchronous];
        }
    }
    
    if (lastLocation != nil) [self checkEventsForCheckin];
}

- (int)minuteDistanceBetweenNowAndDate:(NSDate *)aDate
{
    if (aDate == nil) return INT_MAX;
    NSDate *now = [NSDate date];
    NSTimeInterval flooredEventDateInterval = floor([aDate timeIntervalSinceReferenceDate] / 60) * 60;
    NSDate *flooredEventDate = [NSDate dateWithTimeIntervalSinceReferenceDate:flooredEventDateInterval];
//    NSLog(@"event = %@ : now = %@", flooredEventDate, now);
    return ceil([now timeIntervalSinceDate:flooredEventDate] / 60);
}

- (void)checkEventsForCheckin
{
    if (!checkinUserEnabled) return;
    
    Model *model = [Model sharedInstance];
    NSArray *allEvents = [model.allEvents allValues];
    
    for ( Event *e in allEvents )
    {
        BOOL eventIsWithinTimeRange = e.minutesToGoUntilEventStarts < (CHECKIN_TIME_RANGE_MINUTES/2) && e.minutesToGoUntilEventStarts >  (-CHECKIN_TIME_RANGE_MINUTES/2);
        BOOL eventHasBeenCheckedIn = e.hasBeenCheckedIn;
        BOOL eventIsBeingCreated = e.isTemporary;
        BOOL eventIsDecided = e.currentEventState >= EventStateDecided;
        
        if (eventIsWithinTimeRange && !eventHasBeenCheckedIn && !eventIsBeingCreated && eventIsDecided)
        {
            Location *loc = [e getLocationByLocationId:e.topLocationId];
            if (loc == nil) continue;
            // location is within range to test location CHECKIN_RADIUS_THRESHHOLD, CHECKIN_ACCURACY_THRESHHOLD
            CLLocation *centerLoc = [[[CLLocation alloc] initWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude] autorelease];
            CLLocationDistance distance = [centerLoc distanceFromLocation:lastLocation];
            CLLocationAccuracy accuracy = lastLocation.horizontalAccuracy;
//            NSLog(@"checkEventsForCheckin - distance: %f, accuracy: %f", distance, accuracy);
            
//            CLLocationAccuracy accuracy =  0; // not testing accuracy for now, as it's generally pretty bad
            if (distance < CHECKIN_RADIUS_THRESHOLD && accuracy < CHECKIN_ACCURACY_THRESHOLD) [self checkinUserForEvent:e];
        }
    }
}

- (void)checkinUserForEvent:(Event *)event
{
    Model *model = [Model sharedInstance];
    UIApplication *app = [UIApplication sharedApplication];
    NSLog(@"checking in user %@ for event %@ in background:%@", model.userEmail, event.eventTitle, app.applicationState == UIApplicationStateBackground ? @"YES" : @"NO");    
    if (app.applicationState == UIApplicationStateBackground) {
        [[Controller sharedInstance] checkinUserForEventSynchronous:event];
    } else {
        [[Controller sharedInstance] checkinUserForEvent:event];
    }
}

- (void)reportUserLocation:(CLLocation *)location andEvent:(Event *)event
{
    NSLog(@"Reporting location: %@", [location description]);
    UIApplication *app = [UIApplication sharedApplication];
    Location *loc = [[[Location alloc] init] autorelease];
    [loc setLatitude:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
    [loc setLongitude:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
    
    if (app.applicationState == UIApplicationStateBackground) {
        NSLog(@"Reporting location for event: %@ in background", event.eventTitle);
        [[Controller sharedInstance] reportLocationSynchronous:loc forEvent:event];
    } else {
        NSLog(@"Reporting location for event: %@", event.eventTitle);
        [[Controller sharedInstance] reportLocation:loc forEvent:event];
    }
}

#pragma mark SimpleGeoDelegate methods

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    NSLog(@"Request failed: %@: %i", [request responseStatusMessage], [request responseStatusCode]);
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    NSLog(@"Request finished: %@", [request responseString]);
}

#pragma mark SimpleGeoDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"Location: %@", [newLocation description]);
    
    if (lastLocation == nil)
    {
        locationChangedSignificantly = YES;
    }
    else
    {
        CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
        
        if (lastReportedLocation == nil) lastReportedLocation  = [newLocation copy];
        /*
        NSLog(@"accuracy: %f", accuracy);
        NSLog(@"locationChangedSignificantly: %d", locationChangedSignificantly);
        NSLog(@"lastReportedLocation distanceFromLocation:newLocation: %f", [lastReportedLocation distanceFromLocation:newLocation]);
        NSLog(@"REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD: %d", REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD);
        NSLog(@"CHECKIN_ACCURACY_THRESHOLD: %d", CHECKIN_ACCURACY_THRESHOLD);
        */
        if (!locationChangedSignificantly) locationChangedSignificantly = [lastReportedLocation distanceFromLocation:newLocation] > REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD && accuracy < CHECKIN_ACCURACY_THRESHOLD;
        if (locationChangedSignificantly) {
            [lastReportedLocation release];
            lastReportedLocation = [newLocation copy];
        }
    }
    
    if (lastLocation != nil) [lastLocation release];
    lastLocation = [newLocation copy];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", [error description]);
}

- (void)dealloc
{
    NSLog(@"LocationReporter dealloc"); 
//    [client dealloc];
    [lastLocation release];
    [locationManager release];
    [super dealloc];
}

@end
