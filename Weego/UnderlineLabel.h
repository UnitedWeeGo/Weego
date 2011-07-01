//
//  UnderlineLabel.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UnderlineLabel : UILabel {
    UIColor *underlineColor;
}
- (id) initWithFrame:(CGRect)frame andColor:(UIColor *)color;
@end
