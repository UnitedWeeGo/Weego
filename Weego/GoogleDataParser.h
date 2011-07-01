//
//  GoogleDataParser.h
//  BigBaby
//
//  Created by Nicholas Velloff on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (GoogleDataParser *)sharedInstance;
- (void)processServerResponse:(NSMutableData *)myData;

@end
