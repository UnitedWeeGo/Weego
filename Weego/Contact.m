//
//  Contact.m
//  BigBaby
//
//  Created by Dave Prukop on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@synthesize contactName, emailAddress, emailLabel;

- (void)dealloc
{
    [self.contactName release];
    [self.emailAddress release];
    [self.emailLabel release];
    [super dealloc];
}

- (BOOL)isValid
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 	
	return [emailTest evaluateWithObject:emailAddress];
}

@end
