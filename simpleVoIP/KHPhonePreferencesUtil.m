//
//  KHPhonePreferencesUtil.m
//  KHPhone Connect
//
//  Created by armand on 31-12-16.
//  Copyright © 2016 KHPhone. All rights reserved.
//

#import "KHPhonePreferencesUtil.h"
#import "XCPjsua.h"
static NSString *const sipPortKey           = @"sipPort";
static NSString *const sipAddressKey        = @"sipAddress";
static NSString *const userPhoneNumberKey   = @"userPhoneNumber";
static NSString *const congregationNameKey  = @"congregationName";

@implementation KHPhonePreferencesUtil

+ (BOOL)isPreferencesSet{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        
        NSNumber *sipPort           = [standardUserDefaults objectForKey:sipPortKey];
        NSString *sipAddress        = [standardUserDefaults objectForKey:sipAddressKey];
        NSString *userPhoneNumber   = [standardUserDefaults objectForKey:userPhoneNumberKey];
        
        if (sipPort == nil ||
            sipAddress == nil ||
            [sipAddress isEqualToString:@""] ||
            userPhoneNumber == nil ||
            [userPhoneNumber isEqualToString:@""]){
            
            return NO;
        } else {
            
            return YES;
        }
        
    }
    return NO;
}


/**
 Here we update the preferences. Please alway update all params at once!

 @param sipURL The URL of the SIP address f.i. sip:3120xxxxx@sip1.budgetphone.nl
 @param sipPort The portnumber
 @param userPhoneNumber the phone number of the user
 @param congregationName The name of the congregation
 @return YES if success, NO if failed
 */

+ (BOOL)updatePreferencesWithUserPhoneNumber:(NSString*)userPhoneNumber
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (userPhoneNumber == nil) {
        [standardUserDefaults setObject:nil forKey:userPhoneNumberKey];
        // unregister?
    } else {
        NSLog(@"userPhoneNumber: %@", userPhoneNumber);
        [standardUserDefaults setObject:userPhoneNumber forKey:userPhoneNumberKey];
        
        // it will unregister and register again. (just local)
        char *cUserPhoneNumber = (char*)[userPhoneNumber UTF8String];
        registerAccount(cUserPhoneNumber, "localhost");
    }
    
    //[standardUserDefaults synchronize];
    return YES;
}

+ (BOOL)updatePreferencesWithSipURL:(NSString*)sipURL
                            sipPort:(NSNumber*)sipPort
                      congregationName:(NSString*)congregationName
{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sipPort == nil) {
        [standardUserDefaults setObject:@(5011) forKey:sipPortKey]; // default
    } else {
        NSLog(@"update: sipPort: %@", sipPort);
        [standardUserDefaults setObject:sipPort forKey:sipPortKey];
    }
    
    if (sipURL == nil) {
        [standardUserDefaults setObject:@"" forKey:sipAddressKey]; // this is wrong!
    } else {
        NSLog(@"update: sipURL: %@", sipURL);
        [standardUserDefaults setObject:sipURL forKey:sipAddressKey];
    }
    
    if (congregationName == nil) {
        //[standardUserDefaults setObject:nil forKey:congregationNameKey];
        NSLog(@"congregationName not updated");
    } else {
        NSLog(@"update: congregationName: %@", congregationName);
        [standardUserDefaults setObject:congregationName forKey:congregationNameKey];
    }
    //[standardUserDefaults synchronize];
    
    return YES;
}

+ (NSString*)returnSipURL{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:sipAddressKey];
    }

    return nil;
}

+ (NSNumber*)returnSipPort{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:sipPortKey];
    }
    
    return nil;
}

+ (NSString*)returnUserPhoneNumber{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:userPhoneNumberKey];
    
    }
    
    return nil;
}

+ (NSString*)returnCongregationName{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSString *congregationName = [standardUserDefaults objectForKey:congregationNameKey];
        if (congregationName == nil || [congregationName isEqualToString:@""]) {
            return @"Gemeente onbekend";
        } else {
            return congregationName;
        }
    }
    
    return @"Gemeente onbekend";
}


@end
