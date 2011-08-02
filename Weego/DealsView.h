//
//  DealsView.h
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface DealsView : UIViewController <EGORefreshTableHeaderDelegate, UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    UIView *shader;
}

@property (nonatomic, copy) NSString *SGID;

@end
