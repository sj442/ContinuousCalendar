//
//  CalendarEventLabel.m
//  Calendar
//
//  Created by Sunayna Jain on 12/18/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "CalendarEventLabel.h"

@implementation CalendarEventLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, 5, 0, 0};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

@end
