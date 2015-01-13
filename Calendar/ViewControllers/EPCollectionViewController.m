//
//  EPCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.
//

#import "EPCollectionViewController.h"
#import  <QuartzCore/QuartzCore.h>
#import "EPCalendarCollectionView.h"
#import "EPCalendarMonthHeader.h"
#import "EPCalendarCell.h"
#import "DateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"
#import "UIColor+EH.h"
#import "NSDate+calendar.h"

static NSString * const EPCalendarCellIDentifier = @"CalendarCell";
static NSString * const EPCalendarMonthHeaderIDentifier = @"MonthHeader";

@interface EPCollectionViewController ()

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;

@end

@implementation EPCollectionViewController

#pragma mark - Initialization methods

- (instancetype) initWithCalendar:(NSCalendar *)calendar
{
  self = [super init];
  if (self) {
    self.calendar = calendar;
    self.selectedDate = [NSDate date];
    NSDate *now = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]]];
    
    NSDateComponents *components = [NSDateComponents new];
    components.month = -6;
    self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
    
    components.month = 6;
    self.toDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
  }
  return self;
}

#pragma mark - LifeCycle methods

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initializeFlowLayout];
  [self initializeCollectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (EPCalendarCollectionView *)initializeCollectionView
{
  if (!_collectionView) {
    _collectionView = [[EPCalendarCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.myDelegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.scrollEnabled = YES;
    [_collectionView registerClass:[EPCalendarCell class] forCellWithReuseIdentifier:EPCalendarCellIDentifier];
    [_collectionView registerClass:[EPCalendarMonthHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPCalendarMonthHeaderIDentifier];
    [_collectionView reloadData];
    
    UIPanGestureRecognizer *pan = _collectionView.panGestureRecognizer;
    [pan addTarget:self action:@selector(collectionViewPanned:)];
  }
  return _collectionView;
}

- (void)collectionViewPanned:(UIPanGestureRecognizer *)pan
{
  if (fabsf([pan velocityInView:self.view].y)>500.0f) {
    return;
  }
  
  if (pan.state == UIGestureRecognizerStateEnded && fabsf([pan velocityInView:self.view].y)<500.0f) {
    [self.delegate updateEventsDictionaryWithCompletionBlock:^{
      [self populateCellsWithEvents];
    }];
  }
}

- (UICollectionViewFlowLayout *)initializeFlowLayout
{
  if (!self.flowLayout) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds)/7, MIN(CGRectGetHeight(self.view.bounds)/8, 568/8));
    layout.minimumLineSpacing = 2.0f;
    layout.minimumInteritemSpacing = 0.0f;
    self.flowLayout = layout;
  }
  return self.flowLayout;
}

- (void)calendarCollectionViewWillLayoutSubviews:(EPCalendarCollectionView *)collectionView
{
  if (collectionView.contentOffset.y < 0.0f) { //swiping down
    [self appendPastDates];
  }
  
  if (collectionView.contentOffset.y > (collectionView.contentSize.height - CGRectGetHeight(collectionView.bounds))) {
    [self appendFutureDates];
  }
}

- (void)appendPastDates
{
  NSDateComponents *components = [[NSDateComponents alloc]init];
  components.month = -6;
  [self shiftDatesByComponents:components];
}

- (void)appendFutureDates
{
  NSDateComponents *components = [[NSDateComponents alloc]init];
  components.month = 6;
  [self shiftDatesByComponents:components];
}

- (void)shiftDatesByComponents:(NSDateComponents *)components
{
  UICollectionView *cv = self.collectionView;
  UICollectionViewFlowLayout *cvLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
  
  NSArray *visibleCells = [self.collectionView visibleCells];
  if (![visibleCells count]) {
    return;
  }
  NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
  NSInteger fromSection = fromIndexPath.section;
  NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
  UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
  CGPoint fromSectionOrigin = [self.view convertPoint:fromAttrs.frame.origin fromView:cv];
  
  self.fromDate= [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromCalendarDate:self.fromDate] options:0]];
  self.toDate= [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromCalendarDate:self.toDate] options:0]];
  
  [cv reloadData];
  [cvLayout invalidateLayout];
  [cvLayout prepareLayout];
  
  NSInteger toSection = [self.calendar components:NSCalendarUnitMonth fromDate:[self dateForFirstDayInSection:0] toDate:fromSectionOfDate options:0].month;
  UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
  CGPoint toSectionOrigin = [self.view convertPoint:toAttrs.frame.origin fromView:cv];
  
  [cv setContentOffset:(CGPoint) {
    cv.contentOffset.x,
    cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
  }];
}

#pragma mark - UICollectionView Delegate & DataSource methods

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateFromCalendarDate:self.fromDate] toDate:[self dateFromCalendarDate:self.toDate] options:0].month;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 7 * [NSDate numberOfWeeksForMonthOfDate:[self dateForFirstDayInSection:section] calendar:self.calendar];
}

- (EPCalendarCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  EPCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPCalendarCellIDentifier forIndexPath:indexPath];
  cell.selected = NO;
  NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
  EPCalendarDate firstDayPickerDate = [self calendarDateFromDate:firstDayInMonth];
  NSUInteger weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday;
  NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item - (weekday - 1);
    return dateComponents;
  })()) toDate:firstDayInMonth options:0];
  cell.cellDate = cellDate;
  cell.hasEvents = NO;
  EPCalendarDate cellPickerDate = [self calendarDateFromDate:cellDate];
  cell.date = cellPickerDate;
  cell.enabled = ((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
  cell.selected = (([self.selectedDate isEqualToDate:cellDate]) || ([cellDate isCurrentDateForCalendar:self.calendar] && ![self.selectedDate isEqualToDate:cellDate]));
  return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
  return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  EPCalendarCell *cell = ((EPCalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
  if (!cell.enabled) {
    return;
  }
  [self willChangeValueForKey:@"selectedDate"];
  self.selectedIndexPath = indexPath;
  _selectedDate = cell
  ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]]
  : nil;
  [self didChangeValueForKey:@"selectedDate"];
  [self.delegate cellWasSelected];
  [self.collectionView reloadData];
  [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
  _selectedDate = selectedDate;
  [self.collectionView reloadData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    EPCalendarMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPCalendarMonthHeaderIDentifier forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:@"calendarMonthHeader" withConstructor:^{
      NSDateFormatter *dateFormatter = [NSDateFormatter new];
      dateFormatter.calendar = self.calendar;
      dateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"LLL" options:0 locale:[NSLocale currentLocale]];
      return dateFormatter;
    }];
    NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
    NSDateComponents *formattedDateComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:formattedDate];
    NSUInteger weekday = [formattedDateComponents weekday];
    NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
    abbreviatedDateFormatter.calendar = self.calendar;
    abbreviatedDateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
    NSString *navtitle =[abbreviatedDateFormatter stringFromDate:formattedDate];
    [self.delegate setNavigationTitle:navtitle];
    NSString *monthHeaderString = [dateFormatter stringFromDate:formattedDate];
    monthHeader.textLabel.text = [monthHeaderString uppercaseString];
    CGRect frame = monthHeader.textLabel.frame;
    frame.origin.x = 5+CGRectGetWidth(self.view.bounds)/7*(weekday-1);
    frame.size.width = 50;
    monthHeader.textLabel.frame = frame;
    monthHeader.textLabel.textColor = [UIColor primaryColor];
    monthHeader.textLabel.textAlignment = NSTextAlignmentLeft;
    return monthHeader;
  }
  return nil;
}

- (NSDate *) dateForFirstDayInSection:(NSInteger)section
{
  return [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    return dateComponents;
  })()) toDate:[self dateFromCalendarDate:self.fromDate] options:0];
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
  for (EPCalendarCell *cell in visibleCells) {
    //get calendar events
    NSArray *events = [self.events objectForKey:cell.cellDate];
    if (events.count>0) {
      cell.hasEvents = cell.isEnabled && YES;
    } else {
      cell.hasEvents = NO;
    }
    [cell layoutSubviews];
  }
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  [self.delegate updateEventsDictionaryWithCompletionBlock:^{
    [self populateCellsWithEvents];
  }];
}

- (void)collectionViewTappedAtPoint:(CGPoint)point
{
  NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:point];
  [self collectionView:self.collectionView didSelectItemAtIndexPath:ip];
}

@end
