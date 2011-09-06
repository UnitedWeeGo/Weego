//
//  UIImageViewAsyncLoader.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageViewAsyncLoader.h"
#import <SimpleGeo/SGASIDownloadCache.h>

@interface UIImageViewAsyncLoader (Private)

-(void)setBorder;
-(void)displayImageWithData:(NSData *)data withAnimation:(BOOL)animate;

@end

@implementation UIImageViewAsyncLoader

@synthesize heldRequest;

-(void)setBorder
{
    UIColor *borderColor = HEXCOLOR(0xCCCCCCFF);
    [self.layer setBorderColor:[borderColor CGColor]];
    [self.layer setBorderWidth: 1.0];
}

-(void)requestFinished:(SGASIHTTPRequest *)request
{    
    NSData *response = [request responseData];
    BOOL animate = ![request didUseCachedResponse];
    [self displayImageWithData:response withAnimation:animate];
    
    // After a request has run, didUseCachedResponse will return YES if the response was returned from the cache
//    NSLog(@"did use cache: %d - %@", [request didUseCachedResponse], request.url);
}

-(void)displayImageWithData:(NSData *)data withAnimation:(BOOL)animate
{
    loadedImage = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
    loadedImage.frame = self.bounds;
    loadedImage.alpha = animate ? 0 : 1;
    [self addSubview:loadedImage];
    if (animate) {
        [UIImageView animateWithDuration:0.30f 
                                   delay:0 
                                 options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction) 
                              animations:^(void){
                                  loadedImage.alpha = 1;
                              }
                              completion:NULL];
    }
}
-(void)requestFailed:(SGASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error description]);
}
-(void)asyncLoadWithNSURL:(NSURL *)url useCached:(BOOL)useCached andBaseImage:(BaseImageType)type useBorder:(BOOL)useBorder
{
    if (useBorder) [self setBorder];
    
    if (loadedImage)
    {
        [loadedImage removeFromSuperview];
        loadedImage = nil;
    }
    switch (type) {
        case BaseImageTypeAvatar:
            self.image = [UIImage imageNamed:@"image_container_grey_50x50.png"];
            break;
        case BaseImageTypeMap:
            self.image = [UIImage imageNamed:@"petes_tavern.png"];
            break;
        case BaseImageTypeNone:
            self.image = nil;
            break;
        default:
            break;
    }
    if (self.heldRequest) {
        [self.heldRequest clearDelegatesAndCancel];
        [self.heldRequest release];
        self.heldRequest = nil;
    }
    
    if (!url) return;
    
    // check for cached response data
    NSData *response = [[SGASIDownloadCache sharedCache] cachedResponseDataForURL:url];
    if (response)
    {
//        NSLog(@"found cached version: %@", url);
        [self displayImageWithData:response withAnimation:NO];
        return;
    }
    
    self.heldRequest = [[SGASIHTTPRequest requestWithURL:url] copy];
    
    
    // Set secondsToCache on the request to override any expiry date for the content set by the server, and store 
    // this response in the cache until secondsToCache seconds have elapsed
    [self.heldRequest setSecondsToCache:60*60*24*30]; // Cache for 2 days
    
//    [self.heldRequest setDownloadCache:[ASIDownloadCache sharedCache]]; // I do this in app delegate so it is global not per request
    int cachePolicy = (_useCached)?(SGASIUseDefaultCachePolicy):(SGASIAskServerIfModifiedCachePolicy);
//    int cachePolicy = (_useCached)?(ASIAskServerIfModifiedCachePolicy):(ASIAskServerIfModifiedCachePolicy);
    [self.heldRequest setCacheStoragePolicy:cachePolicy];
    self.heldRequest.showAccurateProgress = NO;
    [self.heldRequest setDelegate:self];
    [self.heldRequest startAsynchronous];
    
    
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestRedirected:(SGASIHTTPRequest *)request
{
    
}

- (void)dealloc
{
    [self.heldRequest clearDelegatesAndCancel];
    [self.heldRequest release];
    self.heldRequest = nil;
    [super dealloc];
}

@end
