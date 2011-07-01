//
//  RegisterTVC.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellFormEntry.h"
#import "UIImageViewAsyncLoader.h"

@class DataFetcher;

@interface RegisterTVC : UITableViewController <CellFormEntryDelegate, FBSessionDelegate, DataFetcherMessageHandler> {
    NSMutableArray *cellFormDataHolder;
    UIImageViewAsyncLoader *avatarImage;
}

- (void)prepopulateFormWithFacebookInfo:(NSDictionary *)facebook;

@end
