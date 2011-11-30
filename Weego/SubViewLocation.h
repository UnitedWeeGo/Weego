//
//  SubViewLocation.h
//  BigBaby
//
//  Created by Dave Prukop on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "UIImageViewAsyncLoader.h"

@protocol SubViewLocationDelegate

- (void)likeButtonPressed:(id)sender;
- (void)unlikeButtonPressed:(id)sender;
- (void)mapButtonPressed:(id)sender;

@end

@interface SubViewLocation : UIView {
    float leftMargin;
	float nextY;
    float fieldWidth;
    float fieldEditingWidth;
    
    UIImageViewAsyncLoader *locationImage;
    UIImageView *annotationImage;
    UIButton *locationPOIIcon;
    UILabel *labelTitle;
    UILabel *labelSecondaryInfo;
    UILabel *labelTertiaryInfo;
//    UILabel *labelOwnerIndicator;
    UIImageView *imageOwnerIndicator;
    
    Location *location;
    
    UIButton *likeButton;
    UIButton *unlikeButton;
    UIView *loading;
    UIActivityIndicatorView *activityView;
    UIView *errorView;
    UIButton *dealButton;
    UIButton *mapBtn;
    UIButton *seeLocButton;
    CGRect actionBtnRect;
    CGRect dealBtnRect;
    
    UIImageView *ratingImage;
    UILabel *reviewCountLabel;
    
//    BOOL isLiked;
    int index;
    BOOL isDashboardMode;
    
    UIImageView *yelpLogo;
}

@property (nonatomic, assign) id <SubViewLocationDelegate> delegate;
@property (nonatomic, retain) Location *location;
//@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) EventState eventState;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL doShowReportingLocationIcon;

- (void)showLoading;
- (void)showError;

@end
