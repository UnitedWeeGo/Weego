//
//  Info.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoDisplay.h"
#import "EGORefreshTableHeaderView.h"

@interface Info : UIViewController <EGORefreshTableHeaderDelegate, InfoDisplayDelegate> {
    InfoDisplay *infoDisplay;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
}

@end
