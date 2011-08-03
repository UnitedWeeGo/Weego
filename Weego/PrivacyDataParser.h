//
//  PrivacyDataParser.h
//  Weego
//
//  Created by Dave Prukop on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivacyDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (PrivacyDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
