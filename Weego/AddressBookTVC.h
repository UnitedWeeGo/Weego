//
//  AdressBookTVC.h
//  Weego
//
//  Created by Dave Prukop on 7/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol AddressBookTVCDataSource <NSObject>

- (NSArray *)dataForAddressBookTVC;
- (NSArray *)enteredContactsForAddressBookTVC;
- (NSArray *)addedParticipantsForAddressBookTVC;

@end

@protocol AddressBookTVCDelegate <NSObject>

- (void)addressBookTVCDidAddContact:(Contact *)aContact;

@end

@interface AddressBookTVC : UITableViewController

@property (nonatomic, assign) id <AddressBookTVCDataSource> dataSource;
@property (nonatomic, assign) id <AddressBookTVCDelegate> delegate;

@end
