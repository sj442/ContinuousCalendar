//
//  EPCalendarWeekCell.h
//  Calendar
//
//  Created by Sunayna Jain on 12/11/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateHelper.h"

@interface EPCalendarWeekCell : UICollectionViewCell

@property (nonatomic, readwrite, assign) EPCalendarDate date;
@property (nonatomic) BOOL hasEvents;
@property (strong, nonatomic) NSDate *cellDate;
@property (nonatomic, readonly, strong) UIView *overlayView;
@property (nonatomic, readonly, strong) UIImageView *imageView;

@end

