//
//  SuggestedTime.m
//  Weego
//
//  Created by Nicholas Velloff on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SuggestedTime.h"


@implementation SuggestedTime

@synthesize email,ownerEventId,suggestedTime,suggestedTimeId;


- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uId = [[xml attributeForName:@"id"] stringValue];
    NSString *uSuggestedTime = [[xml attributeForName:@"suggestedTime"] stringValue];
    NSString *uEmail = [[xml attributeForName:@"email"] stringValue];
    
    if (uId) self.suggestedTimeId = uId;
    if (uSuggestedTime) self.suggestedTime = uSuggestedTime;
    if (uEmail) self.email = uEmail;
}

- (void)dealloc
{
    [self.email release];
    [self.ownerEventId release];
    [self.suggestedTime release];
    [self.suggestedTimeId release];
    [super dealloc];
}

@end

//<suggestedTime id="61" email="nick@unitedweego.com" suggestedTime="2011-07-26 23:30:00" />
