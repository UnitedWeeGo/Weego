//
//  SubViewLabel.h
//  BigBaby
//
//  Created by Dave Prukop on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubViewLabel : UIView {
	UILabel *label;
}

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text;
- (id)initWithText:(NSString *)text;

@end
