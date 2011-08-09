//
//  EditEventTVC.h
//  BigBaby
//
//  Created by Dave Prukop on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellFormEntry.h"
#import "NSDate+Helper.h"

@class DataFetcher;

@interface EditEventTVC : UITableViewController <CellFormEntryDelegate, UIActionSheetDelegate, DataFetcherMessageHandler> {
	Event *detail;
    UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
    
    NSString *originalTitle;
    NSDate *originalDate;
    
}

@property (nonatomic, retain) NSString *anotherTitle;
@property (nonatomic, retain) NSDate *anotherDate;

@end
