//
//  FeedMessage.h
//  BigBaby
//
//  Created by Nicholas Velloff on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface FeedMessage : NSObject {
    
}
@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, copy) NSString *messageRead;
@property (nonatomic, copy) NSString *messageSentTimestamp;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, readonly) NSString *friendlyTimestamp;
@property (nonatomic, readwrite) BOOL userReadMessage;

- (void)populateWithXml:(GDataXMLElement *)xml;

@end

/*
 <message id="345" type="user" senderId="nick@velloff.com" messageRead="true" timestamp="2011-05-12 16:05:17">
 <message>Hello this is a message again!</message>
 </message>
*/