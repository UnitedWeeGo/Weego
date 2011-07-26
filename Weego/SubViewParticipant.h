//
//  SubViewParticipant.h
//  BigBaby
//
//  Created by Dave Prukop on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Participant.h"
#import "UIImageViewAsyncLoader.h"

@interface SubViewParticipant : UIView {    
    Participant *participant;
    
    UIImageViewAsyncLoader *avatarImage;
    UILabel *labelName;
    UILabel *labelSuggestedTime;
    UILabel *labelStatus;
}

@property (nonatomic, retain) Participant *participant;

@end
