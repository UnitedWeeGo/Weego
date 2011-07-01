//
//  UIImageViewAsyncLoader.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleGeo/ASIHTTPRequest.h>

typedef enum {
	BaseImageTypeAvatar = 0,
    BaseImageTypeMap,
    BaseImageTypeNone
} BaseImageType;

@interface UIImageViewAsyncLoader : UIImageView <ASIHTTPRequestDelegate> {
    @private ASIHTTPRequest *heldRequest;
    @private BOOL _useCached;
    UIImageView *loadedImage;
}

@property (nonatomic,retain) ASIHTTPRequest *heldRequest;

-(void)asyncLoadWithNSURL:(NSURL *)url useCached:(BOOL)useCached andBaseImage:(BaseImageType)type useBorder:(BOOL)useBorder;

@end
