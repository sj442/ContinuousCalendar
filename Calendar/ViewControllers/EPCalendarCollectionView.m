//
//  EPCalendarCollectionView.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarCollectionView.h"

@implementation EPCalendarCollectionView

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self.myDelegate calendarCollectionViewWillLayoutSubviews:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [[touches allObjects] lastObject];
  if (touches.count==1) {
    CGPoint point = [touch locationInView:self];
    [self.myDelegate collectionViewTappedAtPoint:point];
  }
}

@end
