//
//  EPWeekCalendarView.h
//  Calendar
//
//  Created by Sunayna Jain on 12/11/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CalendarWeekViewDelegate <NSObject>

- (void)checkNavigationTitle:(NSString *)title;

@end

@protocol CalendarTableViewDelegate <NSObject>

- (void)dataItems:(NSArray *)items;
- (void)setToolbarText:(NSString *)text;

@end

@interface EPWeekCalendarView : UIView

- (instancetype)initWithCalendar:(NSCalendar *)calendar;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (weak, nonatomic) id <CalendarWeekViewDelegate> weekDelegate;
@property (weak, nonatomic) id <CalendarTableViewDelegate> tableViewDelegate;
@property (strong, nonatomic) NSDate *referenceDate;

@property (strong, nonatomic) UICollectionViewFlowLayout *weekFlowLayout;
@property (strong, nonatomic) NSCalendar *calendar;

- (void)populateCellsWithEvents;

@end
