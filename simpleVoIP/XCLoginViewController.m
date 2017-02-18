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

#import "XCLoginViewController.h"
#import "XCPjsua.h"
#import "KHSettingsViewController.h"
#import "LocalConnection.h"

@interface XCLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *speakerButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property BOOL speakerOn;
@property BOOL calling;
@property BOOL answering;
@property BOOL isRegistered;
@property BOOL focusOnUserPhoneNumberNeeded;
@property (weak, nonatomic) IBOutlet UILabel *congregationNameLabel;
@end

@implementation XCLoginViewController

#pragma mark - view delegate functions
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(receivedCallNotification:) name:KHPhoneCallNotification object:nil];
    
    [self updateAnswerState:NO];
    [self updateCallState:NO];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        _speakerButton.hidden = YES; /* Device is iPad */
    }
    /*
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    theAnimation.duration=2.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:1.1];
    theAnimation.removedOnCompletion = false;
    [self.callButton.layer addAnimation:theAnimation forKey:@"pulseAnimation"];
     */
}

- (void)viewDidAppear:(BOOL)animated{
     if ([KHPhonePrefUtil isPreferencesSet]) {
         //self.callButton.enabled = NO;
         self.congregationNameLabel.text = [KHPhonePrefUtil returnCongregationName];
     } else {
        // self.callButton.enabled = YES;
         
     }
}

#pragma mark - notifications
- (void)receivedCallNotification:(NSNotification*)notification{
    NSLog(@"receivedCallNotification: %@", notification);
    NSString *state = notification.userInfo[@"state"];
    
    if ([state isEqualToString:@"disconnected"]) {
        [self updateCallState:NO];
        [self updateAnswerState:NO];
        // maybe post an alert?
    }
}

#pragma mark - Alert functions
- (void)showSettingsWarning{
    NSString *message = @"Vul a.u.b. eerst de gegevens in bij instellingen.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mededeling"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Annuleer"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Instelingen"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self performSegueWithIdentifier:@"presentSettingsSegue" sender:self];
                                                               });
                                                           }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController
                       animated:NO
                     completion:nil];

}

- (void)showSettingsActiveCallWarning{
    NSString *message = @"Verbreek eerst de verbinding voordat u de instellingen aan gaat passen.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mededeling"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController
                       animated:NO
                     completion:nil];
    
}

- (void)showNoInternetWarning{
    NSString *message = @"U heeft geen actieve internet verbinding.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mededeling"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                          }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController
                       animated:NO
                     completion:nil];

}

- (void)showWWANWarning{
    NSString *message = @"U heeft een mobiele internet verbinding (geen Wi-Fi). \rMeeluisteren gaat dan ten koste van uw data bundel!";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Mededeling"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Annuleer"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Verbind toch"
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self makeCall];
                                                               });
                                                           }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController
                       animated:NO
                     completion:nil];
    
}

#pragma mark - IBActions

- (IBAction)hashButtonPressed:(id)sender
{
    [[XCPjsua sharedXCPjsua] sendHashTone];
    
}

- (IBAction)asteriskButtonPressed:(id)sender
{
    if (_answering) {
        
        [self updateAnswerState:NO];
    } else {
        
        [self updateAnswerState:YES];
    }
    
    [[XCPjsua sharedXCPjsua] sendAsteriskTone];
    
}

- (IBAction)startCall:(id)sender
{
    if ([KHPhonePrefUtil isPreferencesSet]) {
        
        if (_calling) {
            
            [[XCPjsua sharedXCPjsua] endAllCalls];
            [self updateCallState:NO];
        } else {
            LocalConnectionStatus status = [[LocalConnection sharedInstance] currentLocalConnectionStatus];
            
            if (status == LC_UnReachable) {
                // show no internet warning!
                [self showNoInternetWarning];
                return;
            } else if (status == LC_WWAN) {
                // show warning about costs!
                [self showWWANWarning];
                return;
            }
            
            [self makeCall];
        }
    } else {
        [self showSettingsWarning];
    }
    
}

- (IBAction)switchSpeaker:(id)sender{
    if (_speakerOn) {
        [[XCPjsua sharedXCPjsua] switchSpeaker:NO];
        _speakerOn = NO;
        [self.speakerButton setImage:[UIImage imageNamed:@"speaker-on-icon"] forState:UIControlStateNormal];
    } else {
        
        [[XCPjsua sharedXCPjsua] switchSpeaker:YES];
        _speakerOn = YES;
        [self.speakerButton setImage:[UIImage imageNamed:@"speaker-off-icon"] forState:UIControlStateNormal];
    }
}

- (IBAction)settingsButtonPressed:(id)sender {
    if(_calling){
        [self showSettingsActiveCallWarning];
        return;
    }
    _focusOnUserPhoneNumberNeeded = NO;
    [self performSegueWithIdentifier:@"presentSettingsSegue" sender:self];
}

#pragma mark - helper functions

- (void)updateAnswerState:(BOOL)state{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state) {
            _answering = YES;
            self.answerButton.tintColor = [UIColor redColor];
        } else {
            _answering = NO;
            self.answerButton.tintColor = [UIColor greenColor];
        }
    });
    
}

- (void) updateCallState:(BOOL)state{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state) {
            _calling = YES;
            [self.callButton setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
        } else {
            _calling = NO;
            [self.callButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
    });
    
}

- (void)makeCall{
    NSString *sipAddress = [KHPhonePrefUtil returnSipURL];
    NSInteger sipPort = [KHPhonePrefUtil returnSipPort];
    
    NSString *destUri = [NSString stringWithFormat:@"%@:%@", sipAddress, @(sipPort)];
    
    BOOL succes = [[XCPjsua sharedXCPjsua] makeCallTo:destUri];
    if (succes) {
        [self updateCallState:YES];
        
    } else {
        
        [self updateCallState:NO];
    }
    
}

- (void)showSettingsAndFocusOnUserPhoneNumber{
    _focusOnUserPhoneNumberNeeded = YES;
    [self performSegueWithIdentifier:@"presentSettingsSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"presentSettingsSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[KHSettingsViewController class]]) {
            KHSettingsViewController *settingsVC = (KHSettingsViewController *) segue.destinationViewController;
            settingsVC.focusOnUserPhoneNeeded = _focusOnUserPhoneNumberNeeded;
        }
    }
}

#pragma mark - other functions
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
