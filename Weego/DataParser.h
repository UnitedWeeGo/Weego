//
//  DataParser.h
//  BigBaby
//
//  Created by Dave Prukop on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataParser : NSObject<DataFetcherDelegate> {

}

+ (DataParser *)sharedInstance;
+ (void)destroy;

- (void)processServerResponse:(NSMutableData *)myData;

@end
