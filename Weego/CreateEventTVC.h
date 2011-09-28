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
#import "CellToggle.h"

enum {
    AlertTypeForcedDecided,
	AlertTypeDateAdjusted
};
typedef NSInteger AlertType;

@class Event;
@class DataFetcher;

@interface CreateEventTVC : UITableViewController <SubViewLocationDelegate, CellFormEntryDelegate, UIActionSheetDelegate, DataFetcherMessageHandler, EGORefreshTableHeaderDelegate, UIAlertViewDelegate, CellToggleDelegate> {
	
	Event *detail;
    NSMutableString *placeholderText;
    UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    int rowsForLocations;
    NSArray *oldSortedLocations;
    NSArray *currentSortedLocations;
    BOOL eventDateAdjusted;
    BOOL multiLocationDecidedAccepted;
    AlertType alertType;
}

@property (nonatomic, assign) BOOL isInDuplicate;
@property (nonatomic, assign) NSString *eventId;

@end
