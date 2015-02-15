//
//  EPCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.
//

#import  <QuartzCore/QuartzCore.h>

#import "EPCollectionViewController.h"

#import "EPCalendarMonthHeader.h"
#import "EPCalendarCollectionView.h"

#import "EPCalendarCell.h"

#import "EPDateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"

static NSString * const EPCalendarCellIdentifier = @"CalendarCell";

static NSString * const EPCalendarMonthHeaderIdentifier = @"MonthHeader";

@interface EPCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, EPCalendarCollectionViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) EPCalendarDate fromDate;

@property (assign, nonatomic) EPCalendarDate toDate;

@property CGPoint tappedPoint;

@end

@implementation EPCollectionViewController

#pragma mark - Initialization

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

#pragma mark - LifeCycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self initializeFlowLayout];
  
  [self initializeCollectionView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Initiazers

- (EPCalendarCollectionView *)initializeCollectionView
{
  if (!self.collectionView) {
    
    EPCalendarCollectionView *collectionView = [[EPCalendarCollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
    
    [self.view addSubview:collectionView];
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.myDelegate = self;
    
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    
    self.collectionView = collectionView;
    
    [self registerCollectionViewCells];
    
    [collectionView reloadData];
    
    UIPanGestureRecognizer *pan = _collectionView.panGestureRecognizer;
    
    [pan addTarget:self action:@selector(collectionViewPanned:)];
  }
  return self.collectionView;
}

- (void)registerCollectionViewCells
{
  [self.collectionView registerClass:[EPCalendarCell class] forCellWithReuseIdentifier:EPCalendarCellIdentifier];
  
  [self.collectionView registerClass:[EPCalendarMonthHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPCalendarMonthHeaderIdentifier];
}

- (UICollectionViewFlowLayout *)initializeFlowLayout
{
  if (!self.flowLayout) {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);
    
    CGFloat rowHeight = 0;
    
    if (CGRectGetHeight(self.view.frame) == 480) {
      rowHeight = CGRectGetHeight(self.view.bounds)/10;
    } else {
      rowHeight = MIN(CGRectGetHeight(self.view.bounds)/9, 568/9);
    }
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds)/7, rowHeight);
    
    layout.minimumLineSpacing = 0.0f;
    
    layout.minimumInteritemSpacing = 0.0f;
    
    self.flowLayout = layout;
  }
  return self.flowLayout;
}

#pragma mark - IBActions

- (void)collectionViewPanned:(UIPanGestureRecognizer *)pan
{
  if (fabsf([pan velocityInView:self.view].y) > 500.0f) {
    return;
  }
  if (pan.state == UIGestureRecognizerStateEnded && fabsf([pan velocityInView:self.view].y) <500.0f) {
    [self.delegate updateEventsDictionaryWithCompletionBlock:^{
      [self populateCellsWithEvents];
    }];
  }
}

#pragma mark - Data manipulation

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
  
  NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0])];
  
  NSInteger fromSection = fromIndexPath.section;
  
  NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
  
  UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
  
  CGPoint fromSectionOrigin = [self.view convertPoint:fromAttrs.frame.origin fromView:cv];
  
  self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromCalendarDate:self.fromDate] options:0]];
  
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

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
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

#pragma mark - UICollectionView Delegate & DataSource

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
  EPCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPCalendarCellIdentifier forIndexPath:indexPath];
  
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
  cell.twoWeekViewInFront = self.twoWeekViewInFront;
  
  cell.enabled = ((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
  
  cell.selected = ([self.selectedDate isEqualToDate:cellDate]);
  
  cell.currentDateCell = [cell.cellDate isCurrentDateForCalendar:self.calendar];
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  EPCalendarCell *cell = ((EPCalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
  if (!cell.enabled) {
    return;
  }
  self.selectedIndexPath = indexPath;
  if (cell) {
    self.selectedDate = [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]];
  } else {
    self.selectedDate = nil;
  }
  [self.delegate cellWasSelected];
  
  [self.collectionView reloadData];
  
  [self.collectionView performBatchUpdates:^{
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
  } completion:^(BOOL finished) {
    
    [self populateCellsWithEvents];
  }];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
  _selectedDate = selectedDate;
  
  [self.collectionView reloadData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    
    EPCalendarMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPCalendarMonthHeaderIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.calendar = self.calendar;
    dateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"LLL" options:0 locale:[NSLocale currentLocale]];
    
    NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
    
    NSDateComponents *formattedDateComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:formattedDate];
    
    NSUInteger weekday = [formattedDateComponents weekday];
    
    NSString *navTitle = [NSDate getMonthYearFromCalendar:self.calendar date:formattedDate];
    [self.delegate setNavigationTitle:navTitle];
    
    NSString *monthHeaderString = [dateFormatter stringFromDate:formattedDate];
    
    monthHeader.textLabel.text = [monthHeaderString uppercaseString];
    
    CGRect frame = monthHeader.textLabel.frame;
    frame.origin.x = 5 + CGRectGetWidth(self.view.bounds)/7 * (weekday-1);
    frame.size.width = 50;
    monthHeader.textLabel.frame = frame;
    
    monthHeader.textLabel.textColor = [UIColor grayColor];
    return monthHeader;
  }
  return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
  if (self.twoWeekViewInFront) {
    return CGSizeMake(0.1f, 0.1f);
  } else {
    return CGSizeMake(self.collectionView.bounds.size.width, 20);
  }
}

- (void)populateCellsWithEvents
{
  NSArray *visibleCells = [self.collectionView visibleCells];
  for (EPCalendarCell *cell in visibleCells) {
    //get calendar events
    NSArray *events = [self.events objectForKey:cell.cellDate];
    if (events.count > 0) {
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
  self.tappedPoint = point;
  NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:point];
  
  [self collectionView:self.collectionView didSelectItemAtIndexPath:ip];
}

- (void)resetSelectedDateMonthToTop
{
  [self.collectionView performBatchUpdates:^{
    
    NSDate *date = [self dateForFirstDayInSection:self.selectedIndexPath.section-1];
    NSInteger itemIndex =  7 * [NSDate numberOfWeeksForMonthOfDate:date calendar:self.calendar];
    NSIndexPath *ip = [NSIndexPath indexPathForItem:itemIndex-1 inSection:self.selectedIndexPath.section-1];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
  } completion:^(BOOL finished) {
      [self populateCellsWithEvents];
  }];
}

- (void)scrollCollectionViewBy:(CGFloat)distance
{
  CGPoint point = CGPointZero;
  point. x = self.tappedPoint.x;
  point. y = self.tappedPoint.y - distance;
  CGPoint toPoint = point;
  
  NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:toPoint];
  
  [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)resetToOriginalPosition;
{
  [self.collectionView performBatchUpdates:^{
    
    [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
  } completion:^(BOOL finished) {
    [self populateCellsWithEvents];
  }];
}

@end
