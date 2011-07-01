//
//  ReportedLocationAnnotation.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Participant.h"

@interface ReportedLocationAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString * _title;
	NSString * _subtitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) Participant *participant;
@property (readonly, assign) Boolean isEnabled;
@property (readonly, assign) Boolean isSavedLocation;

- (ReportedLocationAnnotation *) initWithCoordinate:(CLLocationCoordinate2D)coordinate andParticipant:(Participant *)participant;

@end
