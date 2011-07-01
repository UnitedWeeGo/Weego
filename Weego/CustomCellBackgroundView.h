//
//  CellBgRoundedCorner.h
//  BigBaby
//
//  Created by Dave Prukop on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    CustomCellBackgroundViewPositionTop, 
    CustomCellBackgroundViewPositionMiddle, 
    CustomCellBackgroundViewPositionBottom,
    CustomCellBackgroundViewPositionSingle
} CustomCellBackgroundViewPosition;

typedef enum {
    CustomCellBackgroundViewColorSchemeDark,
    CustomCellBackgroundViewColorSchemeLight,
    CustomCellBackgroundViewColorSchemeNoBorder,
    CustomCellBackgroundViewColorSchemeSelected
} CustomCellBackgroundViewColorScheme;

@interface CustomCellBackgroundView : UIView {
    CustomCellBackgroundViewPosition position;
    CustomCellBackgroundViewColorScheme colorScheme;
}

@property(nonatomic) CustomCellBackgroundViewPosition position;
@property(nonatomic) CustomCellBackgroundViewColorScheme colorScheme;

@end
