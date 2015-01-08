//
//  NSString+EH.m
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSString+EH.h"

@implementation NSString (EH)

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font
{
  CGFloat result = font.pointSize + 4;
  NSString *text = self;
  if (text) {
    CGRect frame = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    
    CGSize size = CGSizeMake(CGRectGetWidth(frame), CGRectGetHeight(frame)+1);
    result = MAX(size.height, result);
  }
  return result;
}

- (CGFloat)heightForTextHavingWidth:(CGFloat)width font:(UIFont *)font maxLines:(CGFloat)maxLines
{
  CGFloat result = [self heightForTextHavingWidth:width font:font];
  if (maxLines > 0) {
    CGFloat maxHeight = font.lineHeight * maxLines;
    result = result>maxHeight ? maxHeight : result;
  }
  return result;
}

@end
