//
//  SubViewFeedMessage.h
//  BigBaby
//
//  Created by Nicholas Velloff on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedMessage.h"
#import "UIImageViewAsyncLoader.h"

@interface SubViewFeedMessage : UIView {
    
    FeedMessage *feedMessage;
    
    UIImageViewAsyncLoader *avatarImage;
    UILabel *labelName;
    UILabel *labelDetail;
    UILabel *labelElapsedTime;
    UIImageView *newIconView;
    UIImageView *checkIconView;
    UIImageView *locationIconView;
    UIImageView *peopleIconView;
}

@property (nonatomic, retain) FeedMessage *feedMessage;

+ (int)calulateMyHeightWithMessageString:(NSString *)message;
+ (int)calulateMyHeightWithFeedMessage:(FeedMessage *)message;

@end
