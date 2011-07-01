//
//  CellPrefsLinks.h
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellPrefsLinksHeight 44.0

@interface CellPrefsLinks : BBTableViewCell {
    UILabel *fieldTitle;
}

- (void)setTitle:(NSString *)title;

@end
