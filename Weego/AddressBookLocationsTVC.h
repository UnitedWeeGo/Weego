//
//  AddressBookLocationsTVC.h
//  Weego
//
//  Created by Dave Prukop on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@protocol AddressBookLocationsTVCDataSource <NSObject>

- (NSArray *)dataForAddressBookLocationsTVC;

@end

@protocol AddressBookLocationsTVCDelegate <NSObject>

- (void)addressBookLocationsTVCDidSelectAddress:(NSString *)anAddress withFriendlyName:(NSString *)friendlyName;

@end

@interface AddressBookLocationsTVC : UITableViewController {
    
    NSMutableArray *indexes;
	NSMutableArray *indexedContacts;
    NSArray *contacts;
    
}

@property (nonatomic, assign) id <AddressBookLocationsTVCDataSource> dataSource;
@property (nonatomic, assign) id <AddressBookLocationsTVCDelegate> delegate;

@end
