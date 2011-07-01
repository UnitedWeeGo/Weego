//
//  VoteCollection.h
//  BigBaby
//
//  Created by Dave Prukop on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VoteCollection : NSObject {
    NSString *locationId;
    NSMutableArray *votes;
}

@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSMutableArray *votes;
@property (readonly) int numberOfVotes;

- (void)addVoteFromUserWithId:(NSString *)aUserId;
- (void)removeVoteFromUserWithId:(NSString *)aUserId;
- (BOOL)containsVoteFromUserWithId:(NSString *)aUserId;
- (void)updateVotesWithArray:(NSArray *)arrayOfVote;
- (void)logVotes:(NSString *)title;

@end
