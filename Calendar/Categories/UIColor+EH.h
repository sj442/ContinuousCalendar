//
//  UIColor+EH.h
//  CRMStar
//
//  Created by epau on 1/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

// This class is used to store any custom colors we use, so that we can reuse them anywhere in the project and easily change them in the future

#import <UIKit/UIKit.h>

@interface UIColor (EH)

+ (UIColor *)primaryColor;
+ (UIColor *)secondaryColor;
+ (UIColor *)tableViewSeparator;

@end
