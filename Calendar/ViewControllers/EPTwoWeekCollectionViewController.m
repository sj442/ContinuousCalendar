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
#import "UIColor+EH.h"
#import "EPTwoWeekCollectionViewController.h"

static NSString * const EPCalendarWeekCellIdentifier = @"CalendarWeekCell";

@interface EPTwoWeekCollectionViewController ()

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;
@property CGFloat itemWidth;
@property CGFloat itemHeight;
@property (strong, nonatomic) UIBarButtonItem *eventsButton;

@end

@implementation EPTwoWeekCollectionViewController

#pragma mark - Initialization

- (instancetype)initWithCalendar:(NSCalendar *)calendar
{
  self = [super init];
  if (self) {
    self.calendar = calendar;
    self.selectedDate = [NSDate date];
    self.referenceDate = [NSDate date];
    self.events = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.automaticallyAdjustsScrollViewInsets = NO;
  [self setupToolBar];
  [self addCalendarTableViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (self.fromCreateEvent) {
    [self.weekDelegate updateEventsDictionaryWithCompletionBlock:^{
      self.fromCreateEvent = NO;
      self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
      [self.tableViewController refreshTableView];
    }];
  }
  [self updateToolBar];
}

#pragma mark - Layout

- (void)setupToolBar
{
  UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), CGRectGetWidth(self.view.bounds), 44)];
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
  UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Events" style:UIBarButtonItemStyleDone target:self action:nil];
  UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"B22_taskbar__close-icon-outline"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed:)];
  self.closeButton = closeButton;
  toolBar.items = @[flexibleSpace, events, flexibleSpace, closeButton];
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
  tableVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.collectionView.frame)-CGRectGetHeight(self.toolBar.frame)-CGRectGetHeight(self.view.bounds)/25);
  [self.view addSubview:tableVC.view];
  [tableVC didMoveToParentViewController:self];
  self.tableViewController.calendar = self.calendar;
  self.tableViewController.selectedDate = self.selectedDate;
  self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
  self.tableViewController.tableViewDelegate = self;
  [self.tableViewController refreshTableView];
}

- (void)closeButtonPressed:(id)sender
{
  [self.weekDelegate closeTableView];
}

- (void)updateToolBar
{
  NSString *title = [NSDate getOrdinalSuffixForDate:self.selectedDate forCalendar:self.calendar];
  [self.eventsButton setTitle:title];
}

#pragma mark - EPTableViewDelegate

- (void)eventWasSelected
{
  self.fromCreateEvent = YES;
  [self.weekDelegate eventWasSelected];
}

@end
