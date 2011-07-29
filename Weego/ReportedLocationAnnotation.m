//
//  ReportedLocationAnnotation.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportedLocationAnnotation.h"

@implementation ReportedLocationAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize participant;
@synthesize isEnabled;
@synthesize isSavedLocation;

- (ReportedLocationAnnotation *) initWithCoordinate:(CLLocationCoordinate2D)coordinate andParticipant:(Participant *)myPart
{
    self = [super init];
    if (self) {
		self.coordinate = coordinate;
        participant = [myPart retain];
        self.title = myPart.fullName;
        self.subtitle = myPart.email;
	}
	return self;
}

- (Boolean)isSavedLocation
{
    return NO;
}

-(void) dealloc
{
    [_title release];
	[_subtitle release];
    [participant release];
    [super dealloc];
}

@end
