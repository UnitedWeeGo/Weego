//
//  Vote.h
//  BigBaby
//
//  Created by Dave Prukop on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Vote : NSObject {
    NSString *ownerEventId;
    NSString *locationId;
    NSString *userId;
    BOOL removeVote;
    BOOL isTemporary;
}

@property (nonatomic, copy) NSString *ownerEventId;
@property (nonatomic, copy) NSString *locationId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL removeVote;
@property (nonatomic, assign) BOOL isTemporary;

@end
