//
//  Privacy.h
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface Privacy : UIViewController <EGORefreshTableHeaderDelegate, UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    UIView *shader;
}

@end
