//
//  HelpDataParser.h
//  BigBaby
//
//  Created by Dave Prukop on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (HelpDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
