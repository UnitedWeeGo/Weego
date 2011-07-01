//
//  KeychainManager.h
//  BigBaby
//
//  Created by Nicholas Velloff on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const KeychainIdFirstname;
NSString * const KeychainIdLastName;
NSString * const KeychainIdEmail;
NSString * const KeychainIdAvatarURL;
NSString * const KeychainIdRUID;

@interface KeychainManager : NSObject {
    
}

+ (KeychainManager *)sharedInstance;
+ (void)destroy;

- (void)addKeychainItemsWithFirstName:(NSString *)firstName
        andLastName:(NSString *)lastName
        andRuid:(NSString *)ruid
        andEmailAddress:(NSString *)emailAddress
        andAvatarURL:(NSString *)avatarURL;

- (void)resetKeychain;

- (NSDictionary *)retreiveKeychainItems;

@end
