//
//  CellPrefsControls.h
//  BigBaby
//
//  Created by Dave Prukop on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellPrefsControlsHeight 44.0

@interface CellPrefsControls : BBTableViewCell {
    UILabel *fieldTitle;
    NSString *prefsKey;
    UISwitch *uiSwitch;
}

- (void)setTitle:(NSString *)title;
- (void)setPrefsKey:(NSString *)key;

@end
