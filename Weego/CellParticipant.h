//
//  CellParticipant.h
//  BigBaby
//
//  Created by Dave Prukop on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"
#import "SubViewParticipant.h"

#define CellParticipantHeight 44.0

@interface CellParticipant : BBTableViewCell {
    SubViewParticipant *cellView;
}

@property (nonatomic, retain) Participant *participant;
@property (nonatomic, assign) BOOL editing;

@end
