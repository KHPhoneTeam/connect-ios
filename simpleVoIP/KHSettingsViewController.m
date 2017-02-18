//
//  KHSettingsViewController.m
//  simpleVoIP
//
//  Created by armand on 28-10-16.
//  Copyright © 2016 Xianwen Chen. All rights reserved.
//

#import "KHSettingsViewController.h"

@interface KHSettingsViewController ()
@property BOOL cameFromQR;
@end

@implementation KHSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cameFromQR = NO;
    
    self.portNumberTextField.delegate = self;
    self.sipAdressTextField.delegate = self;
    self.userPhoneNumberTextField.delegate = self;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Pas toe" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.userPhoneNumberTextField.inputAccessoryView = numberToolbar;
    
    if (_focusOnUserPhoneNeeded) {
        [self focusOnUserPhonenumber];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self updateTextFields];
    
    if (self.cameFromQR) {
        [self.userPhoneNumberTextField becomeFirstResponder];
        self.cameFromQR = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneWithNumberPad{
    //NSString *numberFromTheKeyboard = self.userPhoneNumberTextField.text;
    [self.userPhoneNumberTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self updatePreferences];
}

-(void)updateTextFields{
    
        NSInteger sipPort = [KHPhonePrefUtil returnSipPort];
        if (sipPort != 0) {
            self.portNumberTextField.text = [NSString stringWithFormat:@"%@", @(sipPort) ];
        } else {
            self.portNumberTextField.text = @"5011"; // default
        }
        
        NSString *sipAddress = [KHPhonePrefUtil returnSipURL];
        if (sipAddress != nil) {
            self.sipAdressTextField.text = sipAddress;
        } else {
            
        }
        
        NSString *userPhoneNumber = [KHPhonePrefUtil returnUserPhoneNumber];
        if (userPhoneNumber != nil) {
            self.userPhoneNumberTextField.text = userPhoneNumber;
        } else {
            
        }
    
}

- (void)updatePreferences{
    
    NSInteger sipPort = [self.portNumberTextField.text integerValue];
    
    NSString *sipAddress = self.sipAdressTextField.text;
    
    NSString *userPhoneNumber = self.userPhoneNumberTextField.text;
    
    [KHPhonePrefUtil saveWithSipPort:sipPort]; // Swift!
    [KHPhonePrefUtil saveWithSipAddress:sipAddress];
    [KHPhonePrefUtil saveWithUserPhoneNumber:userPhoneNumber];
    
    NSLog(@"Preferences updated.");
    
}

-(void)focusOnUserPhonenumber{
    [self.userPhoneNumberTextField becomeFirstResponder];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.portNumberTextField resignFirstResponder];
    [self.sipAdressTextField resignFirstResponder];
    [self.userPhoneNumberTextField resignFirstResponder];
}

- (IBAction)qrButtonPressed:(id)sender {
    
}

- (IBAction)closeButtonPressed:(id)sender {
 [self dismissViewControllerAnimated:YES completion:^{
     
 }];
}
 

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"QRSegue"]) {
        self.cameFromQR = YES;
    }
}


@end
