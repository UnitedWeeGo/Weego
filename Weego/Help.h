//
//  Help.h
//  BigBaby
//
//  Created by Dave Prukop on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface Help : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, DataFetcherMessageHandler>
{
    UIView *shader;
    UIActivityIndicatorView *spinner;
}

@end
