//
//  SuggestedTime.h
//  Weego
//
//  Created by Nicholas Velloff on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface SuggestedTime : NSObject {
    
}

@property (nonatomic, copy) NSString *suggestedTimeId;
@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *suggestedTime;
@property (nonatomic, copy) NSString *email;

- (void)populateWithXml:(GDataXMLElement *)xml;

@end
