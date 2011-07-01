//
//  Contact.h
//  BigBaby
//
//  Created by Dave Prukop on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Contact : NSObject {
    
}

@property (nonatomic, copy) NSString *contactName;
@property (nonatomic, copy) NSString *emailAddress;
@property (nonatomic, copy) NSString *emailLabel;
@property (nonatomic, readonly) BOOL isValid;

@end
