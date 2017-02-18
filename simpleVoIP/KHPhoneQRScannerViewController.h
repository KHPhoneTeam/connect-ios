//
//  KHPhoneQRScannerViewController.h
//  KHPhone Connect
//
//  Created by armand on 11-11-16.
//  Copyright © 2016 KHPhone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KHPhoneQRScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@end
