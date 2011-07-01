//
//  CellPrefsLoginParticipant.h
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"
#import "Participant.h"

#define CellPrefsLoginParticipantHeight 68.0

@interface CellPrefsLoginParticipant : BBTableViewCell {
    float leftMargin;
	float nextY;
    float fieldWidth;
    
    UIImageViewAsyncLoader *avatarImage;
    UILabel *labelName;
    UILabel *labelEmail;
    UILabel *labelPhone;
}

@property (nonatomic, retain) Participant *participant;

@end
