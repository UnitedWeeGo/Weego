//
//  InfoDisplay.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageControl.h"

@protocol InfoDisplayDelegate <NSObject>

- (void)infoDisplayWillBeginLoading;
- (void)infoDisplayDidFinishLoading;

@end

@interface InfoDisplay : UIView <UIWebViewDelegate, UIScrollViewDelegate> {
    UIScrollView *infoScrollView;
    CGSize cardSize;
    int numPages;
    float pad;
    PageControl *pageControl;
    UIActivityIndicatorView* _spinner;
    UIView *shader;
}

@property (nonatomic, assign) id <InfoDisplayDelegate> delegate;

- (void)showContent;

@end
