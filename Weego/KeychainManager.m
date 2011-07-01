//
//  KeychainManager.m
//  BigBaby
//
//  Created by Nicholas Velloff on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeychainManager.h"
#import "SFHFKeychainUtils.h"

@implementation KeychainManager

static KeychainManager *sharedInstance;

NSString * const KeychainIdFirstname = @"KeychainIdFirstname";
NSString * const KeychainIdLastName = @"KeychainIdLastName";
NSString * const KeychainIdEmail = @"KeychainIdEmail";
NSString * const KeychainIdAvatarURL = @"KeychainIdAvatarURL";
NSString * const KeychainIdRUID = @"KeychainIdRUID";

NSString * const AppId = @"UnityAppID";

#pragma mark -
#pragma mark Object Lifecycle
+ (KeychainManager *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[KeychainManager alloc] init];       
    }
    return sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton KeychainManager.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

+ (void)destroy
{
    [sharedInstance release];
    sharedInstance = nil;
}

- (id)init {
    if (self == [super init]) {
       //
    }
    return self;
}

- (void)addKeychainItemsWithFirstName:(NSString *)firstName
                          andLastName:(NSString *)lastName
                              andRuid:(NSString *)ruid
                      andEmailAddress:(NSString *)emailAddress
                         andAvatarURL:(NSString *)avatarURL
{
    NSError *error = nil;
    if (firstName) [SFHFKeychainUtils storeUsername:KeychainIdFirstname andPassword:firstName forServiceName:AppId updateExisting:YES error:&error];
    if (lastName) [SFHFKeychainUtils storeUsername:KeychainIdLastName andPassword:lastName forServiceName:AppId updateExisting:YES error:&error];
    if (ruid) [SFHFKeychainUtils storeUsername:KeychainIdRUID andPassword:ruid forServiceName:AppId updateExisting:YES error:&error];
    if (emailAddress) [SFHFKeychainUtils storeUsername:KeychainIdEmail andPassword:emailAddress forServiceName:AppId updateExisting:YES error:&error];
    if (avatarURL) [SFHFKeychainUtils storeUsername:KeychainIdAvatarURL andPassword:avatarURL forServiceName:AppId updateExisting:YES error:&error];
}

- (NSDictionary *)retreiveKeychainItems
{
    NSError *error = nil;
    NSString *firstName = [SFHFKeychainUtils getPasswordForUsername:KeychainIdFirstname andServiceName:AppId error:&error];
    NSString *lastName = [SFHFKeychainUtils getPasswordForUsername:KeychainIdLastName andServiceName:AppId error:&error];
    NSString *ruid = [SFHFKeychainUtils getPasswordForUsername:KeychainIdRUID andServiceName:AppId error:&error];
    NSString *emailAddress = [SFHFKeychainUtils getPasswordForUsername:KeychainIdEmail andServiceName:AppId error:&error];
    NSString *avatarURL = [SFHFKeychainUtils getPasswordForUsername:KeychainIdAvatarURL andServiceName:AppId error:&error];
    
    NSMutableArray *objects = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    if (firstName)      [objects replaceObjectAtIndex:0 withObject:firstName];
    if (lastName)       [objects replaceObjectAtIndex:1 withObject:lastName];
    if (ruid)           [objects replaceObjectAtIndex:2 withObject:ruid];
    if (emailAddress)   [objects replaceObjectAtIndex:3 withObject:emailAddress];
    if (avatarURL)      [objects replaceObjectAtIndex:4 withObject:avatarURL];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:KeychainIdFirstname, KeychainIdLastName, KeychainIdRUID, KeychainIdEmail, KeychainIdAvatarURL, nil];
    
        
    NSDictionary *items = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    [keys release];
    [objects release];
    
    return [items autorelease];
    
}

- (void)resetKeychain
{
    NSError *error = nil;
    [SFHFKeychainUtils deleteItemForUsername:KeychainIdFirstname andServiceName:AppId error:&error];
    [SFHFKeychainUtils deleteItemForUsername:KeychainIdLastName andServiceName:AppId error:&error];
    [SFHFKeychainUtils deleteItemForUsername:KeychainIdRUID andServiceName:AppId error:&error];
    [SFHFKeychainUtils deleteItemForUsername:KeychainIdEmail andServiceName:AppId error:&error];
    [SFHFKeychainUtils deleteItemForUsername:KeychainIdAvatarURL andServiceName:AppId error:&error];
}

- (void) dealloc
{
	NSLog(@"KeychainManager dealloc");
    [super dealloc];
}
@end
