//
//  ReportedLocationAnnotationView.m
//  BigBaby
//
//  Created by Nicholas Velloff on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportedLocationAnnotationView.h"
#import "UIImageViewAsyncLoader.h"

@interface ReportedLocationAnnotationView(Private) 

- (NSString *)getStringForSelectedState:(ReportedLocationAnnoSelectedState)state;

@end

@implementation ReportedLocationAnnotationView

- (void)setCurrentState:(ReportedLocationAnnoSelectedState)state andParticipantImageURL:(NSString *)url
{
    if (mySubView) [mySubView removeFromSuperview];
    mySubView = nil;
    
    // base bg
    NSString *imageName = [[[NSString alloc]initWithFormat:@"POIs_people_%@.png",[self getStringForSelectedState:state]] autorelease];
    UIImage *bg = [UIImage imageNamed:imageName];
    UIImageView *bgView = [[[UIImageView alloc] initWithImage:bg] autorelease];
    [bgView setTag:1];
    
    // holder
    UIView *holder = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bg.size.width, bg.size.height)] autorelease];
    [holder addSubview:bgView];
    
    // user avatar
    if (url)
    {
        UIImageViewAsyncLoader *avatarImage = [[[UIImageViewAsyncLoader alloc] initWithFrame:CGRectMake(2.75, 2, 28, 28)] autorelease];
        [avatarImage asyncLoadWithNSURL:[NSURL URLWithString:url] useCached:YES andBaseImage:BaseImageTypeNone useBorder:NO];
        [holder addSubview:avatarImage];
    }
    
    mySubView = holder;
    [self addSubview:mySubView];
    [self setFrame:mySubView.frame];
}

- (void)setCurrentState:(ReportedLocationAnnoSelectedState)state
{
    UIImageView *bgView = (UIImageView *)[mySubView viewWithTag:1];
    NSString *imageName = [[[NSString alloc]initWithFormat:@"POIs_people_%@.png",[self getStringForSelectedState:state]] autorelease];
    UIImage *bg = [UIImage imageNamed:imageName];
    bgView.image = bg;
}

#pragma mark -
#pragma mark Helpers
#pragma mark -

- (NSString *)getStringForSelectedState:(ReportedLocationAnnoSelectedState)state
{
    NSString *stateString;
    switch (state) {
        case ReportedLocationAnnoSelectedStateDefault:
            stateString = @"default";
            break;
        case ReportedLocationAnnoSelectedStateSelected:
            stateString = @"selected";
            break;
        case ReportedLocationAnnoSelectedStateDisabled:
            stateString = @"disabled";
            break;
        default:
            break;
    }
    return stateString;
}

@end
