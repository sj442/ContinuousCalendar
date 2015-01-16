//
//  ExtendedNavBarView.m
//  Calendar
//
//  Created by Sunayna Jain on 12/10/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPExtendedNavBarView.h"

@implementation EPExtendedNavBarView

- (void)layoutSubviews
{
  NSArray *days = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
  for (int i=0; i<7; i++) {
    CGFloat width = CGRectGetWidth(self.frame)/7;
    CGFloat xOrigin = 0+ width*i;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(xOrigin, 0, width, CGRectGetHeight(self.frame))];
    label.text = days[i];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.backgroundColor = [UIColor whiteColor];
  }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
  // Use the layer shadow to draw a one pixel hairline under this view.
  [self.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
  [self.layer setShadowRadius:0];
  
  // UINavigationBar's hairline is adaptive, its properties change with
  // the contents it overlies.  You may need to experiment with these
  // values to best match your content.
  [self.layer setShadowColor:[UIColor blackColor].CGColor];
  [self.layer setShadowOpacity:0.25f];
}

@end
