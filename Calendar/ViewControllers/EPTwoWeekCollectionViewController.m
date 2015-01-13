//
//  EPTwoWeekCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.

#import  <QuartzCore/QuartzCore.h>
#import "EPCalendarWeekCell.h"
#import "DateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"
#import "NSDate+calendar.h"
#import "UIColor+EH.h"
#import "EPTwoWeekCollectionViewController.h"

static NSString * const EPCalendarWeekCellIdentifier = @"CalendarWeekCell";

@interface EPTwoWeekCollectionViewController ()

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;
@property CGFloat itemWidth;
@property CGFloat itemHeight;

@property (weak, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIBarButtonItem *eventsButton;

@end

@implementation EPTwoWeekCollectionViewController

#pragma mark - Initialization methods

- (instancetype)initWithCalendar:(NSCalendar *)calendar
{
  self = [super init];
  if (self) {
    self.calendar = calendar;
    self.selectedDate = [NSDate date];
    self.referenceDate = [NSDate date];
    self.events = [NSMutableDictionary dictionary];
    NSDate *now = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]]];
    
    NSDateComponents *components = [NSDateComponents new];
    components.month = -6;
    self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
    
    components.month = 6;
    self.toDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
  }
  return self;
}

#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.automaticallyAdjustsScrollViewInsets = NO;
  [self initializeWeekFlowLayout];
  [self initializeCollectionView];
  [self setupToolBar];
  [self addCalendarTableViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (self.fromCreateEvent) {
    [self.weekDelegate updateEventsDictionaryWithCompletionBlock:^{
      [self.collectionView reloadData];
      self.fromCreateEvent = NO;
      self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
      [self.tableViewController refreshTableView];
    }];
  }
}

#pragma mark - Layout methods

- (void)setupToolBar
{
  UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), CGRectGetWidth(self.view.bounds), 44)];
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Events" style:UIBarButtonItemStyleDone target:self action:nil];
  toolBar.items = @[flexibleSpace, events, flexibleSpace];
  toolBar.tintColor = [UIColor primaryColor];
  [self.view addSubview:toolBar];
  self.toolBar = toolBar;
  self.eventsButton = events;
}

- (void)addCalendarTableViewController
{
  EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.collectionView.frame)-CGRectGetHeight(self.toolBar.frame))];
  self.tableViewController = tableVC;
  [self addChildViewController:tableVC];
  tableVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.collectionView.frame)-CGRectGetHeight(self.toolBar.frame));
  [self.view addSubview:tableVC.view];
  [tableVC didMoveToParentViewController:self];
  self.tableViewController.calendar = self.calendar;
  self.tableViewController.selectedDate = self.selectedDate;
  self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
  self.tableViewController.tableViewDelegate = self;
  [self.tableViewController refreshTableView];
}

- (UICollectionView *)initializeCollectionView
{
  if (!_collectionView) {
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/6) collectionViewLayout:self.weekFlowLayout];
    [self.view addSubview:_collectionView];
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
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds)/7, CGRectGetHeight(self.view.bounds)/12);
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;
    self.weekFlowLayout = layout;
  }
  return self.weekFlowLayout;
}

#pragma mark - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 14;
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
  NSArray *events = [self.events objectForKey:cell.cellDate];
  if (events.count>0) {
    cell.hasEvents = YES;
  } else {
    cell.hasEvents = NO;
  }
  EPCalendarDate cellPickerDate = [self calendarDateFromDate:cellDate];
  cell.date = cellPickerDate;
  cell.selected = (([self.selectedDate isEqualToDate:cellDate]) || ([cellDate isCurrentDateForCalendar:self.calendar] && ![self.selectedDate isEqualToDate:cellDate]));
  return cell;
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
  self.tableViewController.selectedDate = self.selectedDate;
  self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
  [self.tableViewController refreshTableView];
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
{
  return [self.calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    return dateComponents;
  })()) toDate:[self dateFromCalendarDate:self.fromDate] options:0];
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

#pragma mark - EPTableViewDelegate

- (void)eventWasSelected
{
  self.fromCreateEvent = YES;
  [self.weekDelegate eventWasSelected];
}

@end
