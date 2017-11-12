/*
 * Copyright (C) 2014 Xianwen Chen <xianwen@xianwenchen.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#import "XCAppDelegate.h"
#import "XCPjsua.h"
#import "XCLoginViewController.h"

@interface XCAppDelegate ()
@property (nonatomic, strong) NSURL *launchedURL;
@end

@implementation XCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [XCPjsua sharedXCPjsua];// start pjsip
    
    NSLog(@"launchOptions in didFinishLaunchingWithOptions: %@", launchOptions);
    self.launchedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (self.launchedURL) {
        //[self openLink:self.launchedURL];
        NSLog(@"_launchedURL: %@", _launchedURL);
        self.launchedURL = nil;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[XCPjsua sharedXCPjsua] endAllCalls];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    //NSLog(@"launchOptions in openURL: %@", options);
    
    NSString *settingsStringURL = [url absoluteString] ;
    NSString *settingsString = [settingsStringURL stringByRemovingPercentEncoding];
    
    NSArray *arguments = [settingsString componentsSeparatedByString: @"?"];
    NSLog(@"arguments in openURL: %@", arguments);
    
    NSNumber *sipPort = arguments[3];
    NSString *sipAddress = arguments[2];
    NSString *congregationName = arguments[1];
    
    [KHPhonePrefUtil saveWithSipAddress:sipAddress];
    [KHPhonePrefUtil saveWithSipPort:[sipPort integerValue]];
    [KHPhonePrefUtil saveWithCongregationName:congregationName];
    
    NSLog(@"Preferences updated via URL.");
    
    XCLoginViewController *rootViewController = (XCLoginViewController*)self.window.rootViewController;
    
    if (sipPort != nil && sipAddress != nil) {
        
        // now let's inform the user
        NSString *message = [NSString stringWithFormat:@"Instellingen bijgewerkt voor %@!\nVul nu uw eigen telefoonnummer in", congregationName];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Bericht"
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                             // present settingsVC
                                                             // after that focus on user phone number
                                                             [rootViewController showSettingsAndFocusOnUserPhoneNumber];

        }];
        [controller addAction:okAction];
        [rootViewController presentViewController:controller animated:YES completion:^{
            
        }];
        
    } else {
        // there was something wrong with the settings URL
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Bericht"
                                                                            message:@"Er is iets mis met de instellingen link"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [controller addAction:okAction];
        [rootViewController presentViewController:controller animated:YES completion:^{
            
        }];
        
    }

    return YES;
}

@end
