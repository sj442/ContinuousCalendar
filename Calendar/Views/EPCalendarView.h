//
//  EPCalendarView.h
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCalendarCollectionView.h"

@protocol CalendarViewDelegate <NSObject>

- (void)moveupTableView;
- (void)setNavigationTitle:(NSString *)title;

@end

@interface EPCalendarView : UIView

- (instancetype)initWithCalendar:(NSCalendar *)calendar;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) EPCalendarCollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) id<CalendarViewDelegate> delegate;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) NSCalendar *calendar;

- (void)populateCellsWithEvents;

@end