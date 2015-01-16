//
//  EPTwoWeekCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.

#import  <QuartzCore/QuartzCore.h>
#import "EPDateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"
#import "EPTwoWeekCollectionViewController.h"

static NSString * const EPCalendarWeekCellIdentifier = @"CalendarWeekCell";

@interface EPTwoWeekCollectionViewController ()

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;
@property CGFloat itemWidth;
@property CGFloat itemHeight;
@property (strong, nonatomic) UIBarButtonItem *eventsButton;
@property CGFloat rowHeight;
@property CGFloat screenHeight;

@property CGFloat startPointY;
@end

@implementation EPTwoWeekCollectionViewController

#pragma mark - Initialization

- (instancetype)initWithCalendar:(NSCalendar *)calendar
{
  self = [super init];
  if (self) {
    self.calendar = calendar;
    self.selectedDate = [NSDate date];
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
  if ([[UIScreen mainScreen] bounds].size.height == 480) {
    self.rowHeight = CGRectGetHeight(self.view.bounds)/10;
  } else {
    self.rowHeight = MIN(CGRectGetHeight(self.view.bounds)/9, 568/9);
  }
  self.screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
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
  toolBar.items = @[flexibleSpace, events, flexibleSpace];
  toolBar.tintColor = [UIColor grayColor];
  [self.view addSubview:toolBar];
  self.toolBar = toolBar;
  self.eventsButton = events;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(move:)];
  [self.view addGestureRecognizer:pan];
}

- (void)addCalendarTableViewController
{
  EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]initWithFrame:CGRectZero];
  self.tableViewController = tableVC;
  [self addChildViewController:tableVC];
  tableVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-2*self.rowHeight-CGRectGetHeight(self.toolBar.frame) - CGRectGetHeight(self.view.bounds)/25-64);
  [self.view addSubview:tableVC.view];
  [tableVC didMoveToParentViewController:self];
  self.tableViewController.calendar = self.calendar;
  self.tableViewController.selectedDate = self.selectedDate;
  self.tableViewController.dataItems = [self.events objectForKey:self.selectedDate];
  self.tableViewController.tableViewDelegate = self;
  [self.tableViewController refreshTableView];
}

- (void)move:(UIPanGestureRecognizer *)pan
{
  if (pan.state == UIGestureRecognizerStateBegan) {
    CGPoint translatedPoint = [pan locationInView:self.view];
    self.startPointY = translatedPoint.y;
  }
  if (pan.state == UIGestureRecognizerStateChanged) {
    CGPoint translatedPoint = [pan locationInView:self.view];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      CGFloat centerY = self.view.center.y;
      [self.view setCenter:CGPointMake(self.view.center.x, centerY +translatedPoint.y-self.startPointY)];
    } completion:^(BOOL finished) {
      CGFloat distanceMoved = translatedPoint.y-self.startPointY;
      [self.weekDelegate scrollCollectionViewBy:distanceMoved];
    }];
  }
  if (pan.state == UIGestureRecognizerStateEnded) {
    CGFloat velocityY = [pan velocityInView:self.view].y;
    if (velocityY>0) {//moving down
      [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.screenHeight + CGRectGetHeight(self.view.frame)/2)];
      } completion:^(BOOL finished) {
        [self.weekDelegate tableViewClosed];
      }];
    } else { //moving up
      [UIView animateWithDuration:0.1f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setCenter:CGPointMake(self.view.center.x, self.rowHeight*2 + self.screenHeight/25 + CGRectGetHeight(self.view.frame)/2)];
      } completion:^(BOOL finished) {
        [self.weekDelegate resetToOriginalPosition];
      }];
    }
  }
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
