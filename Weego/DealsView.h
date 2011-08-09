//
//  DealsView.h
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "Event.h"

typedef enum {
	TimeActionSheetStateEventOwner = 0,
    TimeActionSheetStateEventParticipant
} TimeActionSheetState;

@interface DealsView : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler, UIActionSheetDelegate>
{
    UIView *shader;
    UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
    TimeActionSheetState actionSheetState;
    UIActivityIndicatorView *spinner;
}

@property (nonatomic, copy) NSString *SGID;

@end
