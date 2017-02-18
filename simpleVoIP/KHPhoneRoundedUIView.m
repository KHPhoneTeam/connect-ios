//
//  KHPhoneRoundedUIView.m
//  KHPhone Connect
//
//  Created by armand on 13-11-16.
//  Copyright © 2016 KHPhone. All rights reserved.
//

#import "KHPhoneRoundedUIView.h"

@implementation KHPhoneRoundedUIView
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.cornerRadius = _cornerRadius;
    self.layer.borderWidth = _borderWidth;
    self.layer.borderColor = [_borderColor CGColor];
    self.layer.masksToBounds = _cornerRadius > 0;
}

@end
