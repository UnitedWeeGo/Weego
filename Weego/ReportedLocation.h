//
//  ReportedLocation.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface ReportedLocation : NSObject {
    NSString *ownerEventId;
    NSString *latitude;
    NSString *longitude;
    NSString *reportTime;
    NSString *userId;
}

@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *reportTime;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (void)populateWithXml:(GDataXMLElement *)xml;

@end
