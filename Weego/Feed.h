//
//  Feed.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageEntryWidget.h"

@class DataFetcher;

@interface Feed : UIViewController <UITableViewDelegate, UITableViewDataSource, MessageEntryWidgetDelegate, DataFetcherMessageHandler> {
    
    UITableView *tableViewMessages;
    MessageEntryWidget *messageEntryWidget;
    Event *currentEvent;
    CGRect TableViewMessagesFullRect;
    CGRect TableViewMessagesCollapsedRect;
}

@end
