//
//  TempDealPopup.m
//  BigBaby
//
//  Created by Dave Prukop on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TempDealPopup.h"


@implementation TempDealPopup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float addedY = 0.0;
        if ([Model sharedInstance].currentViewState == ViewStateMap) addedY = 40.0;
        
        UIView *bgView = [[UIView alloc] initWithFrame:frame];
        bgView.backgroundColor = HEXCOLOR(0x00000099);
        [self addSubview:bgView];
        [bgView release];
        
        UIImageView *mainImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deal_01.png"]];
        mainImage.frame = CGRectMake((frame.size.width - mainImage.image.size.width)/2 , 
                                     ((frame.size.height - mainImage.image.size.height)/2) + addedY, 
                                     mainImage.image.size.width, 
                                     mainImage.image.size.height);
        [self addSubview:mainImage];
        [mainImage release];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(mainImage.frame.origin.x + mainImage.frame.size.width - 44,
                                       mainImage.frame.origin.y + 16, 
                                       32, 
                                       32);
        closeButton.backgroundColor = HEXCOLOR(0x00FF0000);
        [closeButton addTarget:self action:@selector(hideMe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

- (void)hideMe
{
    [[ViewController sharedInstance] hideDeal];
}

- (void)dealloc
{
    [super dealloc];
}

@end
