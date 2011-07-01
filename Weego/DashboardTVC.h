//
//  DashboardTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "CellDashboardFeaturedEvent.h"
#import "InfoDisplay.h"

@class DataFetcher;

@interface DashboardTVC : UITableViewController <EGORefreshTableHeaderDelegate, CellDashboardFeaturedEventDelegate, DataFetcherMessageHandler, InfoDisplayDelegate> {
    NSMutableArray *dataSources;
    BOOL futureShowing;
    BOOL pastShowing;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL initialLoadFinished;
    NSMutableIndexSet *decidedSections;
    NSTimer *refreshTimer;
    InfoDisplay *infoDisplay;
    BOOL showingInfoDisplay;
}

@end
