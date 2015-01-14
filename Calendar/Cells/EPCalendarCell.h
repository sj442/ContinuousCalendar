//
//  EPCalendarCell.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateHelper.h"

@interface EPCalendarCell : UICollectionViewCell

@property (nonatomic, readwrite, assign) EPCalendarDate date;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) BOOL hasEvents;
@property BOOL twoWeekViewInFront;
@property (strong, nonatomic) NSDate *cellDate;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIView *overlayView;
@property (nonatomic, readonly, strong) UIView *dotview;

- (void)refreshDotViews;

@end
