//
//  Help.h
//  BigBaby
//
//  Created by Dave Prukop on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface Help : UIViewController <EGORefreshTableHeaderDelegate, UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _saving;
    UIView *shader;
}

@end
