//
//  EPCalendarEventView.m
//  Calendar
//
//  Created by Sunayna Jain on 12/18/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarEventView.h"

@implementation EPCalendarEventView

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  [[UIColor blackColor] set];
  /* Get the current graphics context */
  CGContextRef currentContext =UIGraphicsGetCurrentContext();
  /* Set the width for the line */
  CGContextSetLineWidth(currentContext,2.0f);
  /* Start the line at this point */
  CGContextMoveToPoint(currentContext,0.0f, 0.0f);
  /* And end it at this point */
  CGContextAddLineToPoint(currentContext,0.0f, CGRectGetHeight(self.frame));
  /* Use the context's current color to draw the line */
  CGContextStrokePath(currentContext);
  self.alpha = 0.3;
}


@end
