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
@synthesize streetAddress, city, state, zip, countryCode, addressLabel;

- (void)dealloc
{
    [self.contactName release];
    [self.emailAddress release];
    [self.emailLabel release];
    
    [self.streetAddress release];
    [self.city release];
    [self.state release];
    [self.zip release];
    [self.countryCode release];
    [self.addressLabel release];
    
    [super dealloc];
}

- (NSString *)contactName
{
    if (contactName == nil || [[contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        if (self.emailAddress) {
            contactName = [NSString stringWithString:self.emailAddress];
        } else {
            return nil;
        }
    }
    return [contactName copy];
}

- (BOOL)isValid
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 	
	return [emailTest evaluateWithObject:emailAddress];
}

- (NSString *)addressLine1
{
    if (streetAddress) {
        NSString *output = [streetAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            return output;
        }
    }
    return @"";
}

- (NSString *)addressLine2
{
    NSString *cityStr = (city) ? city : @"";
    NSString *stateStr = (state) ? [[[NSString alloc] initWithFormat:@", %@", state] autorelease] : @"";
    NSString *zipStr = (zip) ? [[[NSString alloc] initWithFormat:@" %@", zip] autorelease] : @"";
    NSString *ccStr = @""; //(countryCode) ? [[[NSString alloc] initWithFormat:@", %@", countryCode] autorelease] : @"";
    NSString *output = [[[NSString alloc] initWithFormat:@"%@%@%@%@", cityStr, stateStr, zipStr, ccStr] autorelease];
    if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return output;
    }
    return @"";
}

- (NSString *)addressSingleLine
{
    NSString *delimiter = (![self.addressLine1 isEqualToString:@""] && ![self.addressLine2 isEqualToString:@""]) ? @", " : @"";
    NSString *output = [[[NSString alloc] initWithFormat:@"%@%@%@", self.addressLine1, delimiter, self.addressLine2] autorelease];
    if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return output;
    }
    return @"";
}

@end
