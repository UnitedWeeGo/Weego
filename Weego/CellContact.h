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
    UILabel *labelSecondary;
    UILabel *labelTertiary;
    UIView *separator;
    UIImageViewAsyncLoader *avatarImage;
    NSString *contactId;
}

@property (nonatomic, assign) Contact *contact;
@property (nonatomic, assign) Participant *participant;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, getter=isEditing) BOOL editing;

- (void)setContactForLocations:(Contact *)aContact;
- (void)showAdded:(BOOL)hasBeenAdded;
- (void)showDisabled:(BOOL)hasBeenDisabled;
- (void)showChecked:(BOOL)hasBeenChecked;
- (void)toggleChecked;

@end
