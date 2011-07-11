//
//  SimpleGeoDataParser.h
//  Weego
//
//  Created by Nicholas Velloff on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimpleGeo/SimpleGeo.h>

@interface SimpleGeoDataParser : NSObject<DataFetcherDelegate> {
    
}

+ (SimpleGeoDataParser *)sharedInstance;
- (void)processSimpleGeoResponse:(SGFeatureCollection *)places;

@end
