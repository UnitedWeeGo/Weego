//
//  GetDirectionsActionSheetController.m
//  Weego
//
//  Created by Nicholas Velloff on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GetDirectionsActionSheetController.h"

@interface GetDirectionsActionSheetController (Private)

- (void)getDirectionsForLocation:(Location *)loc;
- (void)callLocation:(Location *)loc;

@end

@implementation GetDirectionsActionSheetController

static GetDirectionsActionSheetController *sharedInstance;

#pragma mark -
#pragma mark Object Lifecycle
+ (GetDirectionsActionSheetController *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[GetDirectionsActionSheetController alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton GetDirectionsActionSheetController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}

- (void)presentDirectionsActionSheetForLocation:(Location *)loc
{
    location = loc;
    
    //BOOL hasPhoneCapability = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:123"]];
    NSString *phoneButtonCopy = ([location.formatted_phone_number length] > 0) ? [NSString stringWithFormat:@"Call %@", location.formatted_phone_number] : nil;
    
    UIActionSheet *userOptions;
    if (phoneButtonCopy != nil)
    {
        getDirectionsActionSheetState = GetDirectionsActionSheetStateWithPhone;
        userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:phoneButtonCopy, @"Get Directions", nil];
    }
    else
    {
        getDirectionsActionSheetState = GetDirectionsActionSheetStateWithoutPhone;
        userOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get Directions", nil];
    }
    
    userOptions.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [userOptions showInView:[UIApplication sharedApplication].keyWindow];
    [userOptions release];
}

- (void)getDirectionsForLocation:(Location *)loc
{
    NSLog(@"directions %@", loc.formatted_address);
    NSString* addr = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=Current Location",loc.formatted_address];
    addr = [addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[NSURL alloc] initWithString:addr];
    [[UIApplication sharedApplication] openURL:url];
    
    [url release];
}

- (void)callLocation:(Location *)loc
{
    NSLog(@"call %@", loc.formatted_phone_number);
    NSString *phoneLinkString = [NSString stringWithFormat:@"tel:%@", loc.stripped_phone_number];
    NSURL *phoneLinkURL = [NSURL URLWithString:phoneLinkString];
    [[UIApplication sharedApplication] openURL:phoneLinkURL];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if (getDirectionsActionSheetState == GetDirectionsActionSheetStateWithPhone)
            {
                [self callLocation:location];
            }
            else if (getDirectionsActionSheetState == GetDirectionsActionSheetStateWithoutPhone)
            {
                [self getDirectionsForLocation:location];
            }
            break;
        case 1:
            if (getDirectionsActionSheetState == GetDirectionsActionSheetStateWithPhone)
            {
                [self getDirectionsForLocation:location];
            }
            else if (getDirectionsActionSheetState == GetDirectionsActionSheetStateWithoutPhone)
            {
                // cancel, do nothing
            }
            break;
        default:
            break;
    }
}

@end
