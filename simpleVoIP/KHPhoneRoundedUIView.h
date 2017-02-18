//
//  KHPhoneRoundedUIView.h
//  KHPhone Connect
//
//  Created by armand on 13-11-16.
//  Copyright © 2016 KHPhone. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface KHPhoneRoundedUIView : UIView

@property (nonatomic)IBInspectable float cornerRadius;
@property (nonatomic)IBInspectable float borderWidth;
@property (nonatomic)IBInspectable UIColor *borderColor;

@end
