//
//  CellCategory.h
//  Weego
//
//  Created by Nicholas Velloff on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCategory.h"

@interface CellCategory : UITableViewCell {
    UILabel *labelCategoryName;
    UIView *separator;
}

@property (nonatomic, assign) SearchCategory *category;

@end
