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
    [self.delegate calendarCollectionViewWillLayoutSubviews:self];
}


@end
