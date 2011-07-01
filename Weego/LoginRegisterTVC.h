//
//  LoginRegisterTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderViewLoginRegister.h"
#import "CellFormEntry.h"

@class DataFetcher;

@interface LoginRegisterTVC : UITableViewController <HeaderViewLoginRegisterDelegate, CellFormEntryDelegate, DataFetcherMessageHandler> {
    HeaderViewLoginRegister *tableHeaderView;
    NSMutableArray *cellFormDataHolder;
    UIView *tableFooterView;
    UIButton *loginButton;
    BOOL notMember;
}

@end
