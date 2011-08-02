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

@interface DealsView : UIViewController <EGORefreshTableHeaderDelegate, UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler, UIActionSheetDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    UIView *shader;
    UIActionSheet *dateActionSheet;
	UIDatePicker *datePicker;
    TimeActionSheetState actionSheetState;
}

@property (nonatomic, copy) NSString *SGID;

@end
