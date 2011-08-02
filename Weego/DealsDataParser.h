//
//  DealsDataParser.h
//  Weego
//
//  Created by Dave Prukop on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DealsDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (DealsDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
