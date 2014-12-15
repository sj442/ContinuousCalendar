//
//  UIColor+EH.m
//  CRMStar
//
//  Created by epau on 1/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "UIColor+EH.h"

@implementation UIColor (EH)

+ (UIColor *)primaryColor
{
    return [UIColor colorWithRed:0/255.0 green:94/255.0 blue:153/255.0 alpha:1.0];
}

+ (UIColor *)secondaryColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *)tableViewSeparator
{
    return [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
}

@end
