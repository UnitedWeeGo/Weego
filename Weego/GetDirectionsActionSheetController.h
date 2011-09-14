//
//  GetDirectionsActionSheetController.h
//  Weego
//
//  Created by Nicholas Velloff on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

typedef enum {
	GetDirectionsActionSheetStateWithPhone = 0,
    GetDirectionsActionSheetStateWithoutPhone,
} GetDirectionsActionSheetState;

@interface GetDirectionsActionSheetController : NSObject <UIActionSheetDelegate> {
    GetDirectionsActionSheetState getDirectionsActionSheetState;
    Location *location;
}

+ (GetDirectionsActionSheetController *)sharedInstance;
+ (void)destroy;

- (void)presentDirectionsActionSheetForLocation:(Location *)loc;

@end
