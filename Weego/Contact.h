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

@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *addressLabel;

@property (nonatomic, readonly) NSString *addressLine1;
@property (nonatomic, readonly) NSString *addressLine2;
@property (nonatomic, readonly) NSString *addressSingleLine;

@end
