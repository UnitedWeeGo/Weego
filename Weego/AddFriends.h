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
#import "AddressBookTVC.h"

@class DataFetcher;

@interface AddFriends : UIViewController <SubViewContactEntryDelegate, UITableViewDelegate, UITableViewDataSource, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate, AddressBookTVCDataSource, AddressBookTVCDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    
    SubViewContactEntry *contactEntry;
    UITableView *contactsTableView;
    NSMutableArray *filteredContacts;
    BOOL foundResults;
    BOOL keyboardShowing;
    CGFloat tableTop;
    
    NSArray *recentParticipants;
        
    NSArray *allContacts;
    NSArray *allContactsWithEmail;
    
    NSThread *searchThread;
    BOOL searchThreadIsCancelled;
}

@property (nonatomic, retain) UITableView *contactsTableView;
@property (nonatomic, retain) NSMutableArray *filteredContacts;
@property (nonatomic) BOOL searchThreadIsCancelled;

@end
