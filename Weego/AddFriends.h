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

@interface AddFriends : UIViewController <UITableViewDelegate, UITableViewDataSource, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate, AddressBookTVCDataSource, AddressBookTVCDelegate, UISearchBarDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    
//    SubViewContactEntry *contactEntry;
    UISearchBar *searchEntryBar;
    UIView *searchBarButton;
    UITableView *contactsTableView;
    NSMutableArray *filteredContacts;
    BOOL hasFoundResults;
    BOOL hasAddedContacts;
    BOOL hasRecents;
    BOOL keyboardShowing;
    CGFloat tableTop;
    
    NSMutableArray *addedContacts;
    NSMutableArray *recentParticipants;
        
    NSArray *allContacts;
    NSArray *allContactsWithEmail;
    
    NSString *currentSearchTerm;
    
    NSThread *searchThread;
    BOOL searchThreadIsCancelled;
}

@property (nonatomic, retain) UITableView *contactsTableView;
@property (nonatomic, retain) NSMutableArray *filteredContacts;
@property (nonatomic) BOOL searchThreadIsCancelled;

@end
