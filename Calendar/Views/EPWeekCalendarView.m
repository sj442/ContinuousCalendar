//
//  EPCalendarView.m
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import "EPWeekCalendarView.h"
#import  <QuartzCore/QuartzCore.h>
#import "EPCalendarWeekCell.h"
#import "DateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"
#import "EventStore.h"
#import "NSDate+calendar.h"

static NSString * const EPCalendarWeekCellIdentifier = @"CalendarWeekCell";

@interface EPWeekCalendarView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;
@property CGFloat itemWidth;
@property CGFloat itemHeight;

+ (NSCache *) eventsCache;

@end

@implementation EPWeekCalendarView

- (instancetype)initWithCalendar:(NSCalendar *)calendar
{
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.calendar = calendar;
    self.selectedDate = [NSDate date];
    self.referenceDate = [NSDate date];
    self.backgroundColor = [UIColor whiteColor];
    NSDate *now = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]]];
    
    NSDateComponents *components = [NSDateComponents new];
    components.month = -6;
    self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
    
    components.month = 6;
    self.toDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [self initWithCalendar:[NSCalendar currentCalendar]];
  if (self) {
    self.frame = frame;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [self initializeWeekFlowLayout];
  [self initializeCollectionView];
  
  self.collectionView.frame = self.bounds;
  if (!self.collectionView.superview) {
    [self addSubview:self.collectionView];
  }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
  [super willMoveToSuperview:newSuperview];
}

- (UICollectionView *)initializeCollectionView
{
  if (!_collectionView) {
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) collectionViewLayout:self.weekFlowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[EPCalendarWeekCell class] forCellWithReuseIdentifier:EPCalendarWeekCellIdentifier];
    [_collectionView reloadData];
  }
  return _collectionView;
}

- (UICollectionViewFlowLayout *)initializeWeekFlowLayout
{
  if (!self.weekFlowLayout) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.headerReferenceSize = CGSizeZero;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds)/7, CGRectGetHeight(self.bounds)/2);
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;
    self.weekFlowLayout = layout;
  }
  return self.weekFlowLayout;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 14;
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
{
  return [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    return dateComponents;
  })()) toDate:[self dateFromCalendarDate:self.fromDate] options:0];
}

- (NSUInteger)numberOfWeeksForMonthOfDate:(NSDate *)date
{
  NSDate *firstDayInMonth = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
  
  NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = 1;
    dateComponents.day = -1;
    return dateComponents;
  })()) toDate:firstDayInMonth options:0];
  
  NSDate *fromSunday = [self.calendar dateFromComponents:((^{
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
    dateComponents.weekday = 1;
    return dateComponents;
  })())];
  
  NSDate *toSunday = [self.calendar dateFromComponents:((^{
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
    dateComponents.weekday = 1;
    return dateComponents;
  })())];
  
  return 1 + [self.calendar components:NSCalendarUnitWeekOfMonth fromDate:fromSunday toDate:toSunday options:0].weekOfMonth;
}

- (EPCalendarWeekCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  EPCalendarWeekCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPCalendarWeekCellIdentifier forIndexPath:indexPath];
  cell.selected = NO;
  NSDate *firstDayInWeek = [self dateForFirstDayInWeekForDate:self.referenceDate];
  NSUInteger weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInWeek].weekday;
  NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item - (weekday - 1);
    return dateComponents;
  })()) toDate:firstDayInWeek options:0];
  cell.cellDate = cellDate;
  cell.hasEvents = [self calendarEventsForDate:cell.cellDate];
  EPCalendarDate cellPickerDate = [self calendarDateFromDate:cellDate];
  cell.date = cellPickerDate;
  cell.selected = (([self.selectedDate isEqualToDate:cellDate]) || ([cellDate isCurrentDateForCalendar:self.calendar] && ![self.selectedDate isEqualToDate:cellDate]));
  return cell;
}

- (BOOL)calendarEventsForDate:(NSDate *)date
{
  EKEventStore *eventStore = [[EventStore sharedInstance] eventStore];
  //get EKEvents
  NSDate *startDate = [NSDate calendarStartDateFromDate:date ForCalendar:self.calendar]; //starting from 12:01 am
  NSDate *endDate = [NSDate calendarEndDateFromDate:date ForCalendar:self.calendar]; // ending at 11:59 pm
  NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
  NSArray *events = [eventStore eventsMatchingPredicate:predicate];
  if (events.count>0) {
    [[[self class] eventsCache] setObject:events forKey:date];
    return YES;
  }
  return NO;
}

- (NSDate *)dateForFirstDayInWeekForDate:(NSDate *)date
{
  NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay fromDate:date];
  NSInteger weekday = [self.calendar component:NSCalendarUnitWeekday fromDate:date];
  
  [components setDay:components.day-weekday+1];
  NSDate *firstDay = [self.calendar dateFromComponents:components];
  return firstDay;
}

- (NSDate *)oneWeekBeforeFromDate:(NSDate *)selectedDate
{
  NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:selectedDate];
  NSInteger weekday = [self.calendar component:NSCalendarUnitWeekday fromDate:selectedDate];
  [components setDay:components.day-weekday];
  return [self.calendar dateFromComponents:components];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  EPCalendarWeekCell *cell = ((EPCalendarWeekCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
  self.selectedDate = cell.cellDate;
  [self willChangeValueForKey:@"selectedDate"];
  self.selectedIndexPath = indexPath;
  _selectedDate = cell
  ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]]
  : nil;
  [self didChangeValueForKey:@"selectedDate"];
  NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
  abbreviatedDateFormatter.calendar = self.calendar;
  abbreviatedDateFormatter.dateFormat = [abbreviatedDateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
  NSString *navtitle =[abbreviatedDateFormatter stringFromDate:self.selectedDate];
  [self.weekDelegate checkNavigationTitle:navtitle];
  if (indexPath.item>6) {
    self.referenceDate = [self oneWeekBeforeFromDate:self.selectedDate];
  } else {
    self.referenceDate = self.selectedDate;
  }
  [self.collectionView reloadData];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
  _selectedDate = selectedDate;
  NSArray *events;
  if (![[[self class] eventsCache] objectForKey:selectedDate]) {
    [self calendarEventsForDate:selectedDate];
  }
  events = [[[self class] eventsCache] objectForKey:selectedDate];
  [self.tableViewDelegate dataItems:events];
  [self.tableViewDelegate setTableViewSelectedDate:self.selectedDate];
  [self.tableViewDelegate setToolbarText:[NSDate getOrdinalSuffixForDate:self.selectedDate forCalendar:self.calendar]];
  [self.collectionView reloadData];
}

- (NSDate *)dateFromCalendarDate:(EPCalendarDate)dateStruct
{
  return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *)dateComponentsFromPickerDate:(EPCalendarDate)dateStruct
{
  NSDateComponents *components = [NSDateComponents new];
  components.year = dateStruct.year;
  components.month = dateStruct.month;
  components.day = dateStruct.day;
  return components;
}

- (EPCalendarDate)calendarDateFromDate:(NSDate *)date
{
  NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
  return (EPCalendarDate) {
    components.year,
    components.month,
    components.day
  };
}

- (void)populateCellsWithEvents
{
  NSArray *visibleCells = [self.collectionView visibleCells];
  for (EPCalendarWeekCell *cell in visibleCells) {
    cell.hasEvents = [self calendarEventsForDate:cell.cellDate];
    [cell layoutSubviews];
  }
}

#pragma  mark - Events cache

+ (NSCache *)eventsCache {
  static NSCache *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [NSCache new];
  });
  return cache;
}

- (void)refreshEventsCache
{
  [[[self class] eventsCache] removeObjectForKey:self.selectedDate];
  [self calendarEventsForDate:self.selectedDate];
  [self populateCellsWithEvents];
}

@end
