//
//  YelpReviewDataParser.h
//  Weego
//
//  Created by Nicholas Velloff on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YelpReviewDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (YelpReviewDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end