//
//  CellFriendsLocations.m
//  Weego
//
//  Created by Nicholas Velloff on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CellFriendsLocations.h"
#import "ReportedLocation.h"
#import "ReportedLocationAnnotationView.h"

@interface CellFriendsLocations (Private)

- (void)setUpUI;
- (ReportedLocationAnnotation *)getReportedLocationAnnotationForUser:(Participant *)part;
- (void)addOrUpdateUserLocationAnnotations;
- (void)zoomToFitMapAnnotations;
- (void)setUpDataFetcherMessageListeners;
- (void)removeDataFetcherMessageListeners;
- (void)addWinningLocation;

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
							CellFriendsLocationsHeight-1);
    
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
    [self addWinningLocation];
}

- (void)handleDataFetcherSuccessMessage:(NSNotification *)aNotification
{
    NSDictionary *dict = [aNotification userInfo];
    DataFetchType fetchType = [[dict objectForKey:DataFetcherDidCompleteRequestKey] intValue];
    
    switch (fetchType) {
        case DataFetchTypeGetReportedLocations:
            if ([Model sharedInstance].currentViewState == ViewStateDetails) [self addOrUpdateUserLocationAnnotations];
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
        
        if ([p.email isEqualToString:model.userEmail]) continue; // skip the user if it is you
        
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
            double z_height = 1440;
            
            MKMapRect r = MKMapRectMake(annotationPoint.x - z_width, annotationPoint.y - z_height, z_width, z_height);
            
            zoomRect = r;
            
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    float origWidth = zoomRect.size.width;
    float paddedWidth = zoomRect.size.width *= 1.5;
    float origHeight = zoomRect.size.height;
    float paddedHeight = zoomRect.size.height *= 1.5;
        
    zoomRect.origin.x += (origWidth - paddedWidth) / 2;
    zoomRect.origin.y += (origHeight - paddedHeight) / 2;
    
    zoomRect.size.width = paddedWidth;
    zoomRect.size.height = paddedHeight;
    
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
    [[Controller sharedInstance] fetchReportedLocations];
}

- (void)addWinningLocation
{
    Event *detail = [Model sharedInstance].currentEvent;
    Location *loc = (Location *)[[detail getLocations] objectAtIndex:0];
    LocAnnoSelectedState state = LocAnnoSelectedStateDefault;
    LocAnnoStateType type = LocAnnoStateTypeDecided;
    LocAnnotation *mark = [[[LocAnnotation alloc] initWithLocation:loc withStateType:type andSelectedState:state] autorelease];
    [mapView addAnnotation:mark];
    [self zoomToFitMapAnnotations];
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self zoomToFitMapAnnotations];
}
- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
	
	if ([annotation isKindOfClass:[MKUserLocation class]]) 
    {
		return nil;
	}
    NSString* annotationIdentifier = nil;
	if ([annotation isKindOfClass:[LocAnnotation class]])
    {
        LocAnnotation *placeMark = (LocAnnotation *)annotation;
        // try to dequeue an existing pin view first
        annotationIdentifier = @"LocAnnotationIdentifier";
        MKAnnotationView* pinView = (MKAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];            
            pinView.canShowCallout = NO;
		}
        pinView.enabled = placeMark.isEnabled;
        pinView.image = [placeMark imageForCurrentState];
        pinView.centerOffset = [placeMark offsetForCurrentState];
        return pinView;
    } 
    else if ([annotation isKindOfClass:[ReportedLocationAnnotation class]])
    {
        ReportedLocationAnnotation *placeMark = (ReportedLocationAnnotation *)annotation;
        annotationIdentifier = @"ReportedLocationAnnotationIdentifier";
        ReportedLocationAnnotationView *pinView = (ReportedLocationAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[ReportedLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
            pinView.canShowCallout = NO;
            pinView.centerOffset = CGPointMake(7,-20);
		}
        //        [pinView setView:[placeMark imageViewForCurrentState:ReportedLocationAnnoSelectedStateDefault]];
        [pinView setCurrentState:ReportedLocationAnnoSelectedStateDefault andParticipantImageURL:placeMark.participant.avatarURL];
        return pinView;
    }
	return nil;
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
    [super dealloc];
}

@end
