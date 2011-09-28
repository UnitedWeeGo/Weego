//
//  CellToggle.h
//  Weego
//
//  Created by Nicholas Velloff on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellToggleHeight 44.0

@interface CellToggle : BBTableViewCell {
    UILabel *fieldTitle;
    UISwitch *uiSwitch;
}

- (void)setTitle:(NSString *)title andCurrentStatus:(BOOL)isOn;

@end
