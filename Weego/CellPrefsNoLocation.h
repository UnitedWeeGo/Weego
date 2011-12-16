//
//  CellPrefsNoLocation.h
//  Weego
//
//  Created by Nicholas Velloff on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTableViewCell.h"

#define CellPrefsLoginParticipantHeight 68.0

@interface CellPrefsNoLocation : BBTableViewCell {
    float leftMargin;
	float nextY;
    float fieldWidth;
    
    UILabel *labelLine1;
    UILabel *labelLine2;
}

@end
