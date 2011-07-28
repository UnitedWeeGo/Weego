//
//  CreateEventTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewLocation.h"
#import "CellFormEntry.h"
#import "EGORefreshTableHeaderView.h"

@class Event;
@class DataFetcher;

@interface CreateEventTVC : UITableViewController <SubViewLocationDelegate, CellFormEntryDelegate, UIActionSheetDelegate, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate> {
	
	Event *detail;
    UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    int rowsForLocations;
    NSArray *oldSortedLocations;
    NSArray *currentSortedLocations;
}

@property (nonatomic, assign) BOOL isInDuplicate;
@property (nonatomic, assign) NSString *eventId;

@end
