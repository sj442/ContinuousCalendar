//
//  NSString+EH.h
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (EH)

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font;

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font maxLines:(CGFloat)maxLines;

@end
