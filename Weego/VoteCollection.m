//
//  VoteCollection.m
//  BigBaby
//
//  Created by Dave Prukop on 3/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VoteCollection.h"
#import "Vote.h"

@interface VoteCollection (Private)

- (Vote *)getVoteByEmail:(NSString *)email;

@end

@implementation VoteCollection

@synthesize locationId, votes, numberOfVotes;

- (id)init {
    self = [super init];
    if (self) {
        votes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (int)numberOfVotes
{
    int numVotes = 0;
    for (Vote *vote in votes) {
        if (!vote.removeVote) numVotes++;
    }
    return numVotes;
}

- (void)addVoteFromUserWithId:(NSString *)aUserId
{
    Vote *vote = [self getVoteByEmail:aUserId];
    if (vote == nil) {
        vote = [[[Vote alloc] init] autorelease];
        vote.userId = aUserId;
        [votes addObject:vote];
    }
    vote.removeVote = NO;
}

- (void)removeVoteFromUserWithId:(NSString *)aUserId
{
    for (Vote *vote in votes) {
        if ([vote.userId isEqualToString:aUserId]) {
            vote.removeVote = YES;
        }
    }
}

- (BOOL)containsVoteFromUserWithId:(NSString *)aUserId
{
    for (Vote *vote in votes) {
        if ([vote.userId isEqualToString:aUserId] && !vote.removeVote) return YES;
    }
    return NO;
}

- (Vote *)getVoteByEmail:(NSString *)email
{
    for (Vote *vote in votes) {
        if ([vote.userId isEqualToString:email]) return vote;
    }
    return nil;
}

- (void)updateVotesWithArray:(NSArray *)arrayOfVote
{
    for (Vote *vote in arrayOfVote) {
        [self addVoteFromUserWithId:vote.userId];
    }
}

- (void)logVotes:(NSString *)title
{
    for (Vote *vote in votes) {
        NSLog(@"locationId = %@ : vote = %@ : removed = %@ : title = %@", locationId, vote.userId, (vote.removeVote) ? @"TRUE" : @"FALSE", title);
    }
}

- (void)dealloc {
    [locationId release];
    [votes release];
    [super dealloc];
}

@end
