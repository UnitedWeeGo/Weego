//
//  LocationService.m
//  Weego
//
//  Created by Nicholas Velloff on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationService.h"
#import "Event.h"
#import "ReportedLocation.h"

@interface LocationService(Private)

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)reportTenSecondTimerTick;
- (void)checkLocationReportingDisableRequest;
- (void)checkLocationManagerRunStatus;
- (void)checkSignificantLocationServiceStatus;
- (BOOL)userRequiresSomeLocationServices;
- (BOOL)anyEventRequiresLocationManagement;
- (int)minuteDistanceBetweenNowAndDate:(NSDate *)aDate;
- (void)checkForStaleDataInBackground;
- (void)checkForPendingCheckins;
- (void)checkinUserForEvent:(Event *)event;
- (void)updateCheckinStatusForEvents;
- (BOOL)hasAValidLocation;
- (void)reportUserLocation:(CLLocation *)location;
- (void)updateUserLocationForEvents;
- (void)checkUserLocationServiceStatus;

@end

@implementation LocationService

static LocationService *sharedInstance;

+ (LocationService *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[LocationService alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationService.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.purpose = @"Around the time of the event, we report your location and arrival only to the invited participants.";
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportOneSecondTimerTick) name:SYNCH_ONE_SECOND_TIMER_TICK object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportTenSecondTimerTick) name:SYNCH_TEN_SECOND_TIMER_TICK object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportThirtySecondTimerTick) name:SYNCH_THIRTY_SECOND_TIMER_TICK object:nil];
        [self checkUserLocationServiceStatus];
    }
    return self;
}

- (void)checkUserLocationServiceStatus
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager stopMonitoringSignificantLocationChanges];
    }
}

- (void)reportNow
{
    [self reportTenSecondTimerTick];
}

#pragma mark timer methods
- (void)reportOneSecondTimerTick
{
    [self checkLocationManagerRunStatus];               // check if location manager should be currently running
    [self checkSignificantLocationServiceStatus];       // check if significant location changes should be monitored
}

- (void)reportTenSecondTimerTick
{
    locationServicesEnabled = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized && [CLLocationManager locationServicesEnabled];
    locationTrackingUserEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_ALLOW_TRACKING];
    checkinUserEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_ALLOW_CHECKIN];
    [self checkLocationReportingDisableRequest];        // check if user has requested a location disable
    [self checkForStaleDataInBackground];               // check if data is stale, and should be updated (only in background)
    [self checkForPendingCheckins];                     // check events for pending checkin and attempt
    [self updateCheckinStatusForEvents];                // checks events if they are eligable for checkin, and if user is within range
}
- (void)reportThirtySecondTimerTick
{
    locationTrackingUserEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_ALLOW_TRACKING];
    [self updateUserLocationForEvents];
}

#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
    if (accuracy < CHECKIN_ACCURACY_THRESHOLD)
    {
        if (latestValidLocation) [latestValidLocation release];
        latestValidLocation = [newLocation copy];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", [error description]);
}

#pragma mark CLLocationManager methods
- (void)checkSignificantLocationServiceStatus
{
    if (![self userRequiresSomeLocationServices])
    {
        if (significantLoctionMonitoringEnabled)
        {
            significantLoctionMonitoringEnabled = NO;
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [locationManager stopMonitoringSignificantLocationChanges];
        }
    }
    else
    {
        if (!significantLoctionMonitoringEnabled)
        {
            significantLoctionMonitoringEnabled = YES;
            if ([CLLocationManager significantLocationChangeMonitoringAvailable]) [locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)checkLocationManagerRunStatus
{
    Model *model = [Model sharedInstance];
    BOOL locationServicesShouldStart = NO;
    NSArray *allEvents = [model.allEvents allValues];
    for ( Event *e in allEvents )
    {
        if (e.shouldReportUserLocation && [self userRequiresSomeLocationServices]) locationServicesShouldStart = YES;
    }
    if (locationServicesShouldStart)
    {
        [self startUpdatingLocation];
    }
    else if (!locationServicesShouldStart)
    {
        if (latestValidLocation) [latestValidLocation release];
        latestValidLocation = nil;
        [self stopUpdatingLocation];
    }
}

- (void)checkForStaleDataInBackground
{
    Model *model = [Model sharedInstance];
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
    {
        int numMinutesSinceLastFetchAttempt = [self minuteDistanceBetweenNowAndDate:model.lastFetchAttempt];
        if (numMinutesSinceLastFetchAttempt > STALE_DATA_FETCH_MINUTES_THRESHOLD) 
        {
            NSLog(@"checkForStaleDataInBackground : numMinutesSinceLastFetchAttempt: %d, fetchEvents", numMinutesSinceLastFetchAttempt);
            //[[Controller sharedInstance] fetchEventsSynchronous];
            [[Controller sharedInstance] fetchEvents];
        }
    }
}

- (void)updateCheckinStatusForEvents
{
    if (!checkinUserEnabled) return;        // do not mark any new events for checkin, user has disabled
    if (![self hasAValidLocation]) return;  // no current location detected to check
    Model *model = [Model sharedInstance];
    NSArray *allEvents = [model.allEvents allValues];
    for ( Event *e in allEvents )
    {
        if (e.shouldAttemptCheckin)
        {
            Location *loc = [e getLocationByLocationId:e.topLocationId];
            CLLocation *centerLoc = [[[CLLocation alloc] initWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude] autorelease];
            CLLocationDistance distance = [centerLoc distanceFromLocation:latestValidLocation];
            //NSLog(@"checkEventsForCheckin - distance: %f, accuracy: %f", distance, accuracy);
            
            if (distance < CHECKIN_RADIUS_THRESHOLD) {
                e.hasPendingCheckin = YES;
            }
        }
    }
}

- (void)updateUserLocationForEvents
{
    if (!locationTrackingUserEnabled) return;           // do not report any location data, user has disabled
    if (![self hasAValidLocation]) return;              // no current location detected to check
    
    Model *model = [Model sharedInstance];
    //REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD
    //REPORTING_LOCATION_MINUTES_UNTIL_STALE_THRESHOLD
    BOOL locationChangedSignificantly = true;
    BOOL lastReportedLocationStale = true;
    
    ReportedLocation *repLocation = model.lastReportedLocation;
    
    if (repLocation != nil)
    {
        CLLocationDistance dist = [repLocation distanceFromCLLocation:latestValidLocation];
        int time = [repLocation minutesSinceLocationReported];
        
        locationChangedSignificantly = dist > REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD;
        lastReportedLocationStale = time > REPORTING_LOCATION_MINUTES_UNTIL_STALE_THRESHOLD;
        
        NSLog(@"Distance from last reported location: %f", dist);
        NSLog(@"Minutes from last reported location: %i", time);
    }
    /*  Do not report user location if:
     1. user has not travelled a distance of REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD
        -OR-
     2. users last location reported is stale
     */
    if (!locationChangedSignificantly && !lastReportedLocationStale) return;
    
    NSArray *allEvents = [model.allEvents allValues];
    for ( Event *e in allEvents )
    {
        if (e.shouldReportUserLocation)
        {
            //latestValidLocation
            [self reportUserLocation:latestValidLocation];
            return; // only fire it once and exit
        }
    }
}

- (void)checkForPendingCheckins
{
    Model *model = [Model sharedInstance];
    NSArray *allEvents = [model.allEvents allValues];
    for ( Event *e in allEvents )
    {
        if (e.hasPendingCheckin) [self checkinUserForEvent:e];
    }
}

- (void)startUpdatingLocation
{
    [locationManager startUpdatingLocation];
    WeegoAppDelegate *appDelegate = (WeegoAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showDebugLocationServicesIcon:YES];
}

- (void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
    WeegoAppDelegate *appDelegate = (WeegoAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showDebugLocationServicesIcon:NO];
}

#pragma reporting methods
- (void)checkLocationReportingDisableRequest
{
    if ([Model sharedInstance].locationReportingDisabledRequested) {
        Location *loc = [[Location alloc] init];
        loc.latitude = @"0";
        loc.longitude = @"0";
        loc.disableLocationReporting = YES;
        UIApplication *app = [UIApplication sharedApplication];
        if (app.applicationState == UIApplicationStateBackground) {
            NSLog(@"Reporting user location disabled in background");
            //[[Controller sharedInstance] reportLocationSynchronous:loc];
            [[Controller sharedInstance] reportLocation:loc];
        } else {
            NSLog(@"Reporting user location disabled");
            [[Controller sharedInstance] reportLocation:loc];
        }
    }
}
- (void)checkinUserForEvent:(Event *)event
{
    Model *model = [Model sharedInstance];
    UIApplication *app = [UIApplication sharedApplication];
    NSLog(@"checking in user %@ for event %@ in background:%@", model.userEmail, event.eventTitle, app.applicationState == UIApplicationStateBackground ? @"YES" : @"NO");
    
    if (app.applicationState == UIApplicationStateBackground) {
        //[[Controller sharedInstance] checkinUserForEventSynchronous:event];
        [[Controller sharedInstance] checkinUserForEvent:event];
    } else {
        [[Controller sharedInstance] checkinUserForEvent:event];
    }
}
- (void)reportUserLocation:(CLLocation *)location
{
    NSLog(@"Reporting location: %@", [location description]);
    UIApplication *app = [UIApplication sharedApplication];
    Location *loc = [[[Location alloc] init] autorelease];
    [loc setLatitude:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
    [loc setLongitude:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
    
    if (app.applicationState == UIApplicationStateBackground) {
        NSLog(@"Reporting location in background");
        //[[Controller sharedInstance] reportLocationSynchronous:loc];
        [[Controller sharedInstance] reportLocation:loc];
    } else {
        NSLog(@"Reporting location");
        [[Controller sharedInstance] reportLocation:loc];
    }
}

//[repLoc distanceFromReportedLocation:[Model sharedInstance].lastReportedLocation]

#pragma helper methods
- (BOOL)userRequiresSomeLocationServices
{
    return (locationTrackingUserEnabled || checkinUserEnabled) && locationServicesEnabled && [self anyEventRequiresLocationManagement];
}
- (BOOL)anyEventRequiresLocationManagement
{
    BOOL needed = NO;
    Model *model = [Model sharedInstance];
    NSArray *allEvents = [model.allEvents allValues];
    for ( Event *e in allEvents )
    {
        if (e.requiresLocationManagement) needed = YES;
    }
    return needed;
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
- (BOOL)hasAValidLocation
{
    return latestValidLocation != nil;
}

@end
