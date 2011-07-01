//
//  InfoDataParser.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (InfoDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
