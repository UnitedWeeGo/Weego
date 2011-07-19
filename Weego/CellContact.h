//
//  CellContact.h
//  BigBaby
//
//  Created by Dave Prukop on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "Participant.h"
#import "UIImageViewAsyncLoader.h"

@interface CellContact : UITableViewCell {
    UILabel *labelName;
    UILabel *labelLabel;
    UILabel *labelEmail;
    UIView *separator;
    UIImageViewAsyncLoader *avatarImage;
    NSString *contactId;
}

@property (nonatomic, assign) Contact *contact;
@property (nonatomic, assign) Participant *participant;

- (void)showAdded:(BOOL)hasBeenAdded;

@end
