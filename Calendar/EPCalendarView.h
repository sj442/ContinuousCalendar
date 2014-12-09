//
//  EPCalendarView.h
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarViewDelegate <NSObject>

- (void)dataItems:(NSArray *)items;

@end

@interface EPCalendarView : UIView

- (instancetype)initWithCalendar:(NSCalendar *)calendar;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) id <CalendarViewDelegate> delegate;

@end
