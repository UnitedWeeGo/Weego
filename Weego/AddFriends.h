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
#import "SubViewSearchBar.h"

@class DataFetcher;

@interface AddFriends : UIViewController <UITableViewDelegate, UITableViewDataSource, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate, AddressBookTVCDataSource, AddressBookTVCDelegate, SubViewSearchBarDelegate> {
    Event *detail;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    
//    UISearchBar *searchEntryBar;
    SubViewSearchBar *contactsSearchBar;
    UITableView *contactsTableView;
    NSMutableArray *filteredContacts;
    BOOL hasFoundResults;
    BOOL hasAddedContacts;
    BOOL hasRecents;
    BOOL hasFacebookFriends;
    BOOL keyboardShowing;
    CGFloat tableTop;
    
    NSMutableArray *addedContacts;
    NSMutableArray *recentParticipants;
    NSMutableArray *facebookFriends;
        
//    NSArray *allContacts;
    NSArray *allContactsWithEmail;
    
    NSString *currentSearchTerm;
    
    NSThread *searchThread;
    BOOL searchThreadIsCancelled;
}

@property (nonatomic, retain) UITableView *contactsTableView;
@property (nonatomic, retain) NSMutableArray *filteredContacts;
@property (nonatomic) BOOL searchThreadIsCancelled;

@end
