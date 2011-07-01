//
//  AddFriends.h
//  BigBaby
//
//  Created by Dave Prukop on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "SubViewContactEntry.h"
#import "EGORefreshTableHeaderView.h"

@class DataFetcher;

@interface AddFriends : UIViewController <SubViewContactEntryDelegate, UITableViewDelegate, UITableViewDataSource, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    
    SubViewContactEntry *contactEntry;
    UITableView *contactsTableView;
    NSMutableArray *filteredContacts;
    
    NSArray *allContacts;
    NSArray *allContactsWithEmail;
    
    NSThread *searchThread;
    BOOL searchThreadIsCancelled;
}

@property (nonatomic, retain) UITableView *contactsTableView;
@property (nonatomic, retain) NSMutableArray *filteredContacts;
@property (nonatomic) BOOL searchThreadIsCancelled;

//@property (nonatomic, retain) NSMutableArray *matchedContacts;

@end
