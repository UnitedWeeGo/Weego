//
//  main.m
//  Weego
//
//  Created by Nicholas Velloff on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeegoAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([WeegoAppDelegate class]));
    }
    return retVal;
}
