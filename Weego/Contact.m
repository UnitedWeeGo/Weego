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
@synthesize streetAddress, city, state, zip, addressLabel;

- (void)dealloc
{
    [contactName release];
    [emailAddress release];
    [emailLabel release];
    
    [streetAddress release];
    [city release];
    [state release];
    [zip release];
    [addressLabel release];
    
    [super dealloc];
}

//- (NSString *)contactName
//{
//    if (contactName == nil || [[contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
//        if (emailAddress) {
//            return [emailAddress copy];
//        }
//    }
//    return [contactName copy];
//}

- (BOOL)isValid
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 	
	return [emailTest evaluateWithObject:emailAddress];
}

- (BOOL)isValidAddress
{
    return ![[self addressLine1] isEqualToString:@""] && [self addressLine1] != nil;
}

- (NSString *)addressLine1
{
    //[NSString stringWithFormat:@"%@", [streetAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "]]
    NSString *output = self.streetAddress; //(self.streetAddress) ? [streetAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "]] : @"";
    return output;
    
//    if (streetAddress) {
//        NSString *output = [streetAddress stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
//        if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
//            return output;
//        }
//    }
//    return @"";
}

- (NSString *)addressLine2
{
    NSString *cityStr = (city) ? city : @"";
    NSString *stateStr = (state) ? [NSString stringWithFormat:@", %@", state] : @"";
    NSString *zipStr = (zip) ? [NSString stringWithFormat:@" %@", zip] : @"";
    NSString *output = [NSString stringWithFormat:@"%@%@%@", cityStr, stateStr, zipStr];
    return output;
    
//    if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
//        return output;
//    }
//    return @"";
}

- (NSString *)addressSingleLine
{
    NSString *line1 = [self addressLine1];
    NSString *line2 = [self addressLine2];
    NSString *delimiter = (![line1 isEqualToString:@""] && ![line2 isEqualToString:@""]) ? @", " : @"";
    NSString *output = [[NSString alloc] initWithFormat:@"%@%@%@", line1, delimiter, line2];
    //NSLog(@"%@", output);
//    if (![[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
//        return output;
//    }
    return [output autorelease];
}

@end
