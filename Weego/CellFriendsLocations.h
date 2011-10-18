//
//  CellFriendsLocations.h
//  Weego
//
//  Created by Nicholas Velloff on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BBTableViewCell.h"
#import "Event.h"

#define CellFriendsLocationsHeight 140.0

@interface CellFriendsLocations : BBTableViewCell <MKMapViewDelegate> {
    
}

@property (nonatomic, retain) MKMapView *mapView;

- (void)refreshUserLocations;
- (void)checkWinningLocationAddition;

@end
