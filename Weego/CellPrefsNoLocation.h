//
//  CellPrefsNoLocation.h
//  Weego
//
//  Created by Nicholas Velloff on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellPrefsNoLocationHeight 65.0

@interface CellPrefsNoLocation : BBTableViewCell {
    UILabel *primaryInfoLabel;
    UILabel *primaryInfoLabel2;
    UILabel *secondaryInfoLabel;
    UILabel *tertiaryInfoLabel;
}

@end
