//
//  KHPhonePreferencesUtil.h
//  KHPhone Connect
//
//  Created by armand on 31-12-16.
//  Copyright © 2016 KHPhone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHPhonePreferencesUtil : NSObject

+ (BOOL)isPreferencesSet;

+ (BOOL)updatePreferencesWithUserPhoneNumber:(NSString*)userPhoneNumber;

+ (BOOL)updatePreferencesWithSipURL:(NSString*)sipURL
                            sipPort:(NSNumber*)sipPort
                   congregationName:(NSString*)congregationName;

+ (NSString*)returnSipURL;
+ (NSNumber*)returnSipPort;
+ (NSString*)returnUserPhoneNumber;
+ (NSString*)returnCongregationName;
@end
