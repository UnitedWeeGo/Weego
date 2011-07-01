//
//  ImageUtil.m
//  BigBaby
//
//  Created by Nicholas Velloff on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageUtil.h"


@implementation ImageUtil

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
