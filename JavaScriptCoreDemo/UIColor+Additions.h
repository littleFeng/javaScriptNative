//
//  UIColor+Additions.h
//  JDMobile
//
//  Created by heweihua on 13-8-2.
//  Copyright (c) 2013年 jd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithHex:(NSString *)hexColor;
+ (UIColor *)colorWithHex:(NSString *)hexColor withAlpha:(float)alpha_;
+ (UIColor *)color:(UIColor *)color_ withAlpha:(float)alpha_;

//"#0098D2"蓝色字体设置颜色
+ (UIColor *)MyBlueColor;
//"#999999"灰色字体设置颜色
+ (UIColor *)MyGrayColor;

@end
