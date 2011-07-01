//
//  HeaderViewEventDetail.h
//  BigBaby
//
//  Created by Dave Prukop on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "UIImageViewAsyncLoader.h"

@interface SubViewEventInfo : UIView {
	
    float leftMargin;
	float nextY;
    float fieldWidth;
    
    UIImageViewAsyncLoader *avatarImage;
//    UIImageView *disclosureIcon;
    UILabel *labelTitle;
    UILabel *labelDate;
    UILabel *labelCreator;
    UIImageView *feedIconView;
    UILabel *feedCountLabel;
    UILabel *labelNewIndicator;
    
    Event *event;

}

@property (nonatomic, retain) Event *event;

@end
