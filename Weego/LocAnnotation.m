//
//  LocAnnotation.m
//  BigBaby
//
//  Created by Nicholas Velloff on 11/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocAnnotation.h"

@interface LocAnnotation (Private)
- (NSString *)getStringForSelectedType:(LocAnnoStateType)type;
- (NSString *)getStringForSelectedState:(LocAnnoSelectedState)state;
@end

@implementation LocAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize dataLocationIndex;
@synthesize isSavedLocation, isEnabled, isNewlyAdded, uuid, iAddedLocation, scheduledForZoom;
@synthesize hasDeal;
@synthesize isAddress;
@synthesize featureId;
@synthesize rating, mobileYelpUrl, reviewCount, isYelp;

#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	[self.title release];
	[self.subtitle release];
    [self.uuid release];
    [self.featureId release];
    [self.rating release];
    [self.reviewCount release];
    [self.mobileYelpUrl release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initializers
#pragma mark -

- (LocAnnotation *)initWithLocation:(Location *)loc withStateType:(LocAnnoStateType)theStateType andSelectedState:(LocAnnoSelectedState)theSelectedState
{
    self = [super init];
    if (self) {
        self.coordinate = loc.coordinate;
        self.title = loc.name;
        self.subtitle = loc.formatted_address == nil ? loc.vicinity: loc.formatted_address; 
        self.hasDeal = loc.hasDeal;
        self.featureId = loc.g_id;
        isAddress = [loc.location_type isEqualToString:@"address"];
        stateType = theStateType;
        selectedState = theSelectedState;
        isSavedLocation = stateType != LocAnnoStateTypeSearch;
        isEnabled = selectedState != LocAnnoSelectedStateDisabled;
        if ([loc.location_type isEqualToString:@"yelp"])
        {
            isYelp = YES;
            self.rating = loc.rating;
            self.reviewCount = loc.reviewCount;
            self.mobileYelpUrl = loc.mobileYelpUrl;
        }
        
    }
    return self;
}

#pragma mark -
#pragma mark State setters/getters
#pragma mark -
- (void)setStateType:(LocAnnoStateType)type;
{
    isSavedLocation = type != LocAnnoStateTypeSearch;
    stateType = type;
}
- (LocAnnoStateType)getStateType
{
    return stateType;
}
- (void)setSelectedState:(LocAnnoSelectedState)state
{
    isEnabled = state != LocAnnoSelectedStateDisabled;
    selectedState = state;
}
- (LocAnnoSelectedState)getSelectedState
{
    return selectedState;
}

- (UIImage *)imageForCurrentState
{
    NSString *imageName = [[[NSString alloc]initWithFormat:@"%@%@.png",[self getStringForSelectedType:stateType],[self getStringForSelectedState:selectedState]] autorelease];
    
    return [UIImage imageNamed:imageName];
}

- (CGPoint)offsetForCurrentState
{
    CGPoint pt = CGPointMake(stateType > LocAnnoStateTypeSearch ? 0 : 7, -15);
    return pt;
}

#pragma mark -
#pragma mark Helpers
#pragma mark -
- (NSString *)getStringForSelectedType:(LocAnnoStateType)type
{
    NSString *typeString;
    switch (type) {
        case LocAnnoStateTypeSearch:
            typeString = self.hasDeal ? @"POIs_deal_" : @"POIs_search_";
            break;
        case LocAnnoStateTypePlace:
            typeString = @"POIs_place_";
            break;
        case LocAnnoStateTypeDecided:
            typeString = @"POIs_decided_";
            break;
        case LocAnnoStateTypeLiked:
            typeString = @"POIs_liked_";
            break;
        default:
            break;
    }
    return typeString;
}

- (NSString *)getStringForSelectedState:(LocAnnoSelectedState)state
{
    NSString *stateString;
    switch (state) {
        case LocAnnoSelectedStateDefault:
            stateString = @"default";
            break;
        case LocAnnoSelectedStateSelected:
            stateString = @"selected";
            break;
        case LocAnnoSelectedStateDisabled:
            stateString = @"disabled";
            break;
        case LocAnnoSelectedStateRemove:
            stateString = @"remove";
            break;
        default:
            break;
    }
    return stateString;
}

@end
