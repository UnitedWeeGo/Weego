//
//  UIImageView+AsyncLoad.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+AsyncLoad.h"
#import <SimpleGeo/SGASIHTTPRequest.h>

@implementation UIImageView (AsyncLoad)

-(void)requestFinished:(SGASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    [self.image initWithData:data];
}
-(void)requestFailed:(SGASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error: %@", [error description]);
}
-(void)asyncLoadWithNSURL:(NSURL *)url
{
    SGASIHTTPRequest *request = [SGASIHTTPRequest requestWithURL:url];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

@end
