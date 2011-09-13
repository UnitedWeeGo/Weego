//
//  CellParticipantsSummary.h
//  BigBaby
//
//  Created by Dave Prukop on 6/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellParticipantsSummaryHeight 44.0

@interface CellParticipantsSummary : BBTableViewCell {
    UIImageView *icon;
    UILabel *labelNumParticipants;
    UIImageView *expandDisclosure;
    NSMutableArray *avatarImages;
}

@property (nonatomic, assign) NSString *numParticipants;

- (void)setParticipants:(NSArray *)participants;

@end
