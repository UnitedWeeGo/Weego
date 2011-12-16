//
//  UINavigationBar+CustomBackground.m
//  BigBaby
//
//  Created by Dave Prukop on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+CustomBackground.h"

@implementation UINavigationBar (UINavigationBar_CustomBackground)

- (void)drawRect:(CGRect)rect
{
    NSString *imagePath = @"topbar_home_default.png";
    if ([Model sharedInstance].currentAppState == AppStateCreateEvent) {
        imagePath = @"topbar_event_default.png";
    }
    if ([Model sharedInstance].currentViewState == ViewStateFeed) {
        imagePath = @"topbar_feed_default.png";
    }
    if ([Model sharedInstance].currentViewState == ViewStateReviews) {
        imagePath = @"topbar_yelp_default.png";
    }
    UIImage *image = [UIImage imageNamed: imagePath];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    NSLog(@"UINavigationBar+CustomBackground.h : %@", imagePath);
}

@end
