//
//  CellFeedMessage.h
//  BigBaby
//
//  Created by Nicholas Velloff on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubViewFeedMessage.h"
#import "FeedMessage.h"

@interface CellFeedMessage : UITableViewCell {
    SubViewFeedMessage *cellView;
    UIView *separator;
}

@property (nonatomic, retain) FeedMessage *feedMessage;


@end
