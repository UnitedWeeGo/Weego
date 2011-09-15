//
//  Privacy.h
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface Privacy : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler>
{
    UIView *shader;
    UIActivityIndicatorView *spinner;
    UIWebView *webView;
}

@end
