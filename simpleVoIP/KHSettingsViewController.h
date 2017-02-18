 //
//  KHSettingsViewController.h
//  KHConnect
//
//  Created by armand on 28-10-16.
//  Copyright © 2016 Xianwen Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KHSettingsViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sipAdressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPhoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property BOOL focusOnUserPhoneNeeded;

-(void)updateTextFields;

@end
