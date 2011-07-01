//
//  UIImageView+AsyncLoad.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AsyncLoad.h"
#import <SimpleGeo/ASIHTTPRequest.h>

@implementation UIImageView (AsyncLoad)

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    [self.image initWithData:data];
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error description]);
}
-(void)asyncLoadWithNSURL:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

@end
