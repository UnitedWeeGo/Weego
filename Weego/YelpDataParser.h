//
//  YelpDataParser.h
//  Weego
//
//  Created by Nicholas Velloff on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YelpDataParser : NSObject<DataFetcherDelegate> {
    
}
+ (YelpDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
