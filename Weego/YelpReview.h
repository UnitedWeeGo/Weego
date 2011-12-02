//
//  YelpReview.h
//  Weego
//
//  Created by Nicholas Velloff on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YelpReview : UIViewController <UIWebViewDelegate, MoreButtonActionSheetControllerDelegate, UIAlertViewDelegate> {
    UIWebView *wView;
    UIActivityIndicatorView *spinner;
}

@end
