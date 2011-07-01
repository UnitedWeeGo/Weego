//
//  HeaderViewLocations.h
//  BigBaby
//
//  Created by Dave Prukop on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewLocationsDelegate

- (void)seeLocationsClicked;

@end


@interface HeaderViewLocations : UIView {
	
	id <HeaderViewLocationsDelegate> delegate;
	UIButton *seeMap;
	
}

@property (nonatomic, assign) id <HeaderViewLocationsDelegate> delegate;
//@property (nonatomic, retain) UIButton *seeMap;

@end
