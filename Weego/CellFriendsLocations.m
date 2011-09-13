//
//  CellFriendsLocations.m
//  Weego
//
//  Created by Nicholas Velloff on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CellFriendsLocations.h"
#import "ReportedLocation.h"

@interface CellFriendsLocations (Private)

- (void)setUpUI;
- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part;
- (void)addOrUpdateUserLocationAnnotations;
- (void)zoomToFitMapAnnotations;
- (void)setUpDataFetcherMessageListeners;
- (void)removeDataFetcherMessageListeners;

@end

@implementation CellFriendsLocations

@synthesize mapView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
	self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    CGRect mapFrame = CGRectMake(0, 
							0, 
							300,
							CellFriendsLocationsHeight-2);
    
    mapView = [[[MKMapView alloc] initWithFrame:mapFrame] autorelease];
    mapView.userInteractionEnabled = NO;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    
    [self.contentView addSubview:mapView];
    
    self.frame = CGRectMake(self.frame.origin.x, 
							self.frame.origin.y, 
							self.frame.size.width, 
							CellFriendsLocationsHeight);
    
    [self setUpDataFetcherMessageListeners];
}

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    
    switch (fetchType) {
        case DataFetchTypeGetReportedLocations:
            [self addOrUpdateUserLocationAnnotations];
            break;
        default:
            break;
    }
}

- (void)handleDataFetcherErrorMessage:(NSNotification *)aNotification
{
    // do nothing
}

- (void)addOrUpdateUserLocationAnnotations
{
    Model *model = [Model sharedInstance];
    Event *detail = [Model sharedInstance].currentEvent;
    int searchResults = [[detail getReportedLocations] count];
    //    NSLog(@"ReportedLocations count: %d", searchResults);    
    for(int i = 0; i < searchResults; i++)
    {
        ReportedLocation *loc = (ReportedLocation *)[[detail getReportedLocations] objectAtIndex:i];
        Participant *p = [model getParticipantWithEmail:loc.userId fromEventWithId:detail.eventId];
        
        //if ([p.email isEqualToString:model.userEmail]) continue; // skip the user if it is you
        
        ReportedLocationAnnotation *addedAlready = [self getReportedLocationAnnotationForUser:p];
        
        if (addedAlready)
        {
            [addedAlready setCoordinate:loc.coordinate];
        }
        else
        {
            ReportedLocationAnnotation *placemark = [[[ReportedLocationAnnotation alloc] initWithCoordinate:loc.coordinate andParticipant:p] autorelease];
            [mapView addAnnotation:placemark];
        }
    }
    [self zoomToFitMapAnnotations];
}

- (void)zoomToFitMapAnnotations
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            
            double z_width = 3000;
            double z_height = 5000;
            
            MKMapRect r = MKMapRectMake(annotationPoint.x - z_width * 0.5, annotationPoint.y - z_height * 0.5, z_width, z_height);
            
            zoomRect = r;
            
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [mapView setVisibleMapRect:zoomRect animated:NO];
}

- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part
{
    for (id <MKAnnotation> annotation in mapView.annotations) 
    {
        if ([annotation isKindOfClass:[ReportedLocationAnnotation class]]) {
            ReportedLocationAnnotation *anno = annotation;
            if ([anno.participant.email isEqualToString:part.email]) return anno;
        }
    }
    return nil;
}

- (void)refreshUserLocations
{ 
    Event *detail = [Model sharedInstance].currentEvent;
    BOOL eventIsWithinTimeRange = detail.minutesToGoUntilEventStarts < (FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2) && detail.minutesToGoUntilEventStarts >  (-FETCH_REPORTED_LOCATIONS_TIME_RANGE_MINUTES/2);
    BOOL eventIsBeingCreated = detail.isTemporary;
    BOOL isRunningInForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    // grab any users reported locations if in the window
    if (eventIsWithinTimeRange && !eventIsBeingCreated && isRunningInForeground) [[Controller sharedInstance] fetchReportedLocations];
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomToFitMapAnnotations];
}


#pragma mark - DataFetcherMessageHandler

- (void)setUpDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherSuccessMessage:) name:DATA_FETCHER_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataFetcherErrorMessage:) name:DATA_FETCHER_ERROR object:nil];
}

- (void)removeDataFetcherMessageListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    NSLog(@"CellFriendsLocations dealloc");
    [self removeDataFetcherMessageListeners];
    mapView = nil;
}

@end
