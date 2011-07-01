//
//  ReportedLocationAnnotationView.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    ReportedLocationAnnoSelectedStateDefault,
    ReportedLocationAnnoSelectedStateSelected,
    ReportedLocationAnnoSelectedStateDisabled
}ReportedLocationAnnoSelectedState;

@interface ReportedLocationAnnotationView : MKAnnotationView {
    UIView *mySubView;
}

- (void)setCurrentState:(ReportedLocationAnnoSelectedState)state andParticipantImageURL:(NSString *)url;
- (void)setCurrentState:(ReportedLocationAnnoSelectedState)state;

@end
