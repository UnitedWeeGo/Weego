//
//  FeedMessage.m
//  BigBaby
//
//  Created by Nicholas Velloff on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedMessage.h"

@interface FeedMessage(Private)

- (NSDate *)getDateFromString:(NSString *)dateString;
- (int)minutesSinceMessageSentTimestamp;

@end

@implementation FeedMessage

@synthesize imageURL,type,messageId,message,senderId,messageRead,ownerEventId,messageSentTimestamp;

- (void)populateWithXml:(GDataXMLElement *)xml
{
    NSString *uImageURL = ((GDataXMLElement *) [[xml elementsForName:@"imageURL"] objectAtIndex:0]).stringValue;
    NSString *uType = [[xml attributeForName:@"type"] stringValue];
    NSString *uId = [[xml attributeForName:@"id"] stringValue];
    NSString *uMessage = ((GDataXMLElement *) [[xml elementsForName:@"message"] objectAtIndex:0]).stringValue;
    NSString *uSenderId = [[xml attributeForName:@"senderId"] stringValue];
    NSString *uMessageRead = [[xml attributeForName:@"messageRead"] stringValue];
    NSString *uMessageSentTimestamp = [[xml attributeForName:@"timestamp"] stringValue];
    
    if (uImageURL) self.imageURL = uImageURL;
	if (uType) self.type = uType;
    if (uId) self.messageId = uId;
	if (uMessage) self.message = uMessage;
	if (uSenderId) self.senderId = uSenderId;
    if (uMessageRead) self.messageRead = uMessageRead;
    if (uMessageSentTimestamp) self.messageSentTimestamp = uMessageSentTimestamp;
}

- (NSString *)friendlyTimestamp
{
    int minutes = [self minutesSinceMessageSentTimestamp];
    if (minutes < 2) return @"Just Now";
    
    int hours = floor(minutes/60);
    int days = 0;
    if (hours > 0) days = floor(hours/24);
    NSString *returnVal = @"";
    if (days > 0) {
        returnVal = [NSString stringWithFormat:@"%d day%@", days, days==1 ? @"" : @"s"];
    } else if (hours > 0) {
        returnVal = [NSString stringWithFormat:@"%d hour%@", hours, hours==1 ? @"" : @"s"];
    } else {
        returnVal = [NSString stringWithFormat:@"%d minute%@", minutes, minutes==1 ? @"" : @"s"];
    }
    return returnVal;
}

- (int)minutesSinceMessageSentTimestamp
{
    NSDate *now = [NSDate date];
    NSDate *messageDate = [self getDateFromString:self.messageSentTimestamp];
    NSTimeInterval flooredInterval = floor([messageDate timeIntervalSinceReferenceDate] / 60) * 60;
    NSDate *flooredDate = [NSDate dateWithTimeIntervalSinceReferenceDate:flooredInterval];
    return ceil([now timeIntervalSinceDate:flooredDate] / 60);
}

- (NSDate *)getDateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *aDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return aDate;
}

- (BOOL)userReadMessage
{
    return [self.messageRead isEqualToString:@"true"];
}

- (void)setUserReadMessage:(BOOL)userReadMessage
{
    self.messageRead = userReadMessage ? @"true" : @"false";
}

- (void)dealloc
{
    [self.imageURL release];
    [self.type release];
    [self.message release];
    [self.senderId release];
    [self.messageRead release];
    [self.ownerEventId release];
    [self.messageSentTimestamp release];
    [self.messageId release];
    [super dealloc];
}

@end