//
//  LocAnnotation.h
//  BigBaby
//
//  Created by Nicholas Velloff on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Location.h"

typedef enum {
    LocAnnoStateTypeSearch = 0,
    LocAnnoStateTypeDecided,
    LocAnnoStateTypeLiked,
    LocAnnoStateTypePlace
}LocAnnoStateType;
typedef enum {
    LocAnnoSelectedStateDefault,
    LocAnnoSelectedStateSelected,
    LocAnnoSelectedStateDisabled,
    LocAnnoSelectedStateRemove
}LocAnnoSelectedState;

@interface LocAnnotation : NSObject<MKAnnotation> {
    LocAnnoStateType stateType;
    LocAnnoSelectedState selectedState;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readwrite) int dataLocationIndex;
@property (readonly, assign) Boolean isSavedLocation;
@property (readonly, assign) Boolean isEnabled;
@property (nonatomic) Boolean isNewlyAdded;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, assign) BOOL hasDeal;
@property (nonatomic, assign) BOOL iAddedLocation;
@property (nonatomic, readonly) BOOL isAddress;
@property (nonatomic, readwrite) BOOL scheduledForZoom;

- (LocAnnotation *)initWithLocation:(Location *)loc withStateType:(LocAnnoStateType)theStateType andSelectedState:(LocAnnoSelectedState)theSelectedState;

- (void)setStateType:(LocAnnoStateType)type;
- (void)setSelectedState:(LocAnnoSelectedState)state;
- (LocAnnoStateType)getStateType;
- (LocAnnoSelectedState)getSelectedState;

- (UIImage *)imageForCurrentState;

@end