//
//  WildcardGestureRecognizer.h
//  Weego
//
//  Created by Nicholas Velloff on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer {
    TouchesEventBlock touchesBeganCallback;
}
@property(copy) TouchesEventBlock touchesBeganCallback;
@property(copy) TouchesEventBlock touchesMovedCallback;

@end
