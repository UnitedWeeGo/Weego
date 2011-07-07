//
//  Participant.m
//  BigBaby
//
//  Created by Nicholas Velloff on 11/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Participant.h"
#import "GDataXMLNode.h"

@interface Participant(Private)

- (NSString*) stringWithUUID;

@end

@implementation Participant

@synthesize ownerEventId, firstName, lastName, email, avatarURL;
@synthesize isTemporary;
@synthesize isTrialParticipant;

- (id) init
{
	self = [super init];
	if (self != nil) {
        
	}
	return self;
}

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uEmail = [[xml attributeForName:@"email"] stringValue];
    NSString *uFirstName = ((GDataXMLElement *) [[xml elementsForName:@"firstName"] objectAtIndex:0]).stringValue;
    NSString *uLastName = ((GDataXMLElement *) [[xml elementsForName:@"lastName"] objectAtIndex:0]).stringValue;
    NSString *uAvatarURL = ((GDataXMLElement *) [[xml elementsForName:@"avatarURL"] objectAtIndex:0]).stringValue;
    
    if (uEmail) self.email = uEmail;
    if (uFirstName) self.firstName = uFirstName;
    if (uLastName) self.lastName = uLastName;
    if (uAvatarURL) self.avatarURL = uAvatarURL;
    
    self.isTemporary = NO;
}

- (NSString *)fullName
{
	NSString *output = [NSString stringWithFormat:@"%@ %@", (!firstName) ? @"" : firstName, (!lastName) ? @"" : lastName];
	if ([[output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) output = email;
	return output;
}

#pragma mark -
#pragma mark Unique ID Generator

- (NSString*) stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

- (void)dealloc {
	
//	NSLog(@"Participant destroyed");
	
	[ownerEventId release];
	[firstName release];
	[lastName release];
	[email release];
    [avatarURL release];
	
	[super dealloc];
}

@end
