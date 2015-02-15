
//  EPCalendarCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import "EPCalendarViewController.h"

#import "EPTwoWeekCollectionViewController.h"

#import "EPExtendedNavBarView.h"

#import "EPCreateEventTableViewController.h"

#import "EPCalendarCell.h"
#import "NSDate+Calendar.h"
#import "EPEventStore.h"

@interface EPCalendarViewController () <EPCollectionViewControllerDelegate,EPTwoWeekCollectionViewControllerDelegate>

@property (weak, nonatomic) UIView *containerView;

@property (weak, nonatomic) EPExtendedNavBarView *dayView;

@property (strong, nonatomic) EPCollectionViewController *collectionVC;

@property (strong, nonatomic) EPTwoWeekCollectionViewController *twoWeekVC;

@property (strong, nonatomic) NSCalendar *calendar;

@property (strong, nonatomic) NSMutableDictionary *eventsDictionary;

@property (strong, nonatomic) EKEventStore *eventStore;

@property (nonatomic) BOOL fromCreateEvent;

@property (nonatomic) BOOL collectionViewDrawn;

@property (nonatomic) BOOL twoWeekViewDrawn;

@property (nonatomic) BOOL twoWeekViewInFront;

@end

@implementation EPCalendarViewController

#pragma mark - LifeCycle

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  [self setupContainerView];
  
  [self setUpNavigationBar];
  
  self.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  
  self.eventsDictionary = [NSMutableDictionary dictionary];
  
  self.eventStore = [EventStore sharedInstance].eventStore;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (!self.collectionViewDrawn) {
    
    [self addCollectionViewController];
  }
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  NSNumber *access = [defaults objectForKey:@"calendarPermissionDone"];
  
  [self addEventStoreNotifications];
  
  if (access == nil) {
    [self checkCalendarPermissionsWithCompletionHandler:^{
      
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"calendarPermissionDone"];
      [self updateCollectionView];
    }];
  } else {
    
    [self updateCollectionView];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Layout

- (void)setupContainerView
{
  UIView *container = [UIView new];
  
  CGRect frame = CGRectZero;
  frame.origin.y = 64;
  frame.size.width = CGRectGetWidth(self.view.frame);
  frame.size.height = CGRectGetHeight(self.view.frame) - 49-64;
  container.frame = frame;
  
  [self.view addSubview:container];
  
  self.containerView = container;
}

- (void)setUpNavigationBar
{
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
  
  self.navigationController.navigationBar.tintColor = [UIColor grayColor];
  
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init]
                                                forBarMetrics:UIBarMetricsDefault];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"B22_taskbar__add-icon-outline"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(addEvent:)];
  
  
  EPExtendedNavBarView *dayView = [EPExtendedNavBarView new];
  
  CGRect frame = CGRectZero;
  frame.size.width = CGRectGetWidth(self.view.frame);
  frame.size.height = CGRectGetHeight(self.view.frame)/25;
  
  dayView.frame = frame;
  
  [self.containerView addSubview:dayView];
  
  self.dayView = dayView;
}

- (void)addCollectionViewController
{
  EPCollectionViewController *collectionVC = [[EPCollectionViewController alloc]initWithCalendar:self.calendar];
  
  collectionVC.delegate = self;
  collectionVC.events = self.eventsDictionary;
  
  [self addChildViewController:collectionVC];
  
  [self.containerView addSubview:collectionVC.view];
  
  [collectionVC didMoveToParentViewController:self];
  
  CGRect frame = CGRectZero;
  frame.origin.y = CGRectGetMaxY(self.dayView.frame);
  frame.size.width = CGRectGetWidth(self.view.frame);
  frame.size.height = CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(self.dayView.frame);
  collectionVC.view.frame = frame;
  
  self.collectionVC = collectionVC;
  self.collectionViewDrawn = YES;
}

- (void)addTwoWeekViewController
{
  EPTwoWeekCollectionViewController *twoWeekVC = [[EPTwoWeekCollectionViewController alloc]initWithCalendar:self.calendar];
  
  [self addChildViewController:twoWeekVC];
  [self.containerView insertSubview:twoWeekVC.view aboveSubview:self.collectionVC.view];
  [twoWeekVC didMoveToParentViewController:self];
  
  CGRect frame = CGRectZero;
  
  frame.origin.y = CGRectGetHeight(self.containerView.frame);
  frame.size.width = CGRectGetWidth(self.view.frame);
  frame.size.height = CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(self.dayView.frame);
  
  twoWeekVC.view.frame = frame;
  
  self.twoWeekVC = twoWeekVC;
  
  self.twoWeekVC.events = self.eventsDictionary;
  self.twoWeekVC.weekDelegate = self;
  self.twoWeekViewDrawn = YES;
}

#pragma mark - EventStore Notifications

- (void)addEventStoreNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChangedNotification:) name:EKEventStoreChangedNotification object:nil];
}

- (void)eventStoreChangedNotification:(NSNotification *)sneder
{
  if (!self.fromCreateEvent) {
    
    [self updateCollectionView];
    
  } else {
    
    [self updateEventsDictionaryWithCompletionBlock:^{
      
      [self.collectionVC populateCellsWithEvents];
      self.twoWeekVC.tableViewController.dataItems = [self.eventsDictionary objectForKey:self.collectionVC.selectedDate];
      [self.twoWeekVC.tableViewController refreshTableView];
    }];
    
  }
}

- (void)checkCalendarPermissionsWithCompletionHandler:(void (^)(void))completion
{
  [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
    if (granted) {
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self.eventStore reset];
        completion();
      });
      
    } else {
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        completion();
      });
      
    }
  }];
}

#pragma mark - IBActions

- (void)addEvent:(id)sender
{
  EPCreateEventTableViewController *createEventVC = [[EPCreateEventTableViewController alloc] initWithDate:self.collectionVC.selectedDate];
  
  createEventVC.editMode = YES;
  self.fromCreateEvent = YES;
  self.twoWeekVC.fromCreateEvent = YES;
  
  self.twoWeekVC.tableViewController.fromCreateEvent = YES;
  
  UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:createEventVC];
  
  createEventVC.title = @"New Event";
  [self presentViewController:navC animated:YES completion:nil];
}

- (void)showTwoWeekViewController
{
  if (!self.twoWeekViewDrawn) {
    [self addTwoWeekViewController];
  }
  [UIView animateWithDuration:0.1 animations:^{
    
    self.twoWeekViewInFront = YES;
    self.collectionVC.twoWeekViewInFront = YES;
    CGRect frame = self.twoWeekVC.view.frame;
    
    CGFloat rowHeight = 0;
    
    if (CGRectGetHeight(self.view.frame) == 480) {
      rowHeight = CGRectGetHeight(self.view.bounds)/10;
    } else {
      rowHeight = MIN(CGRectGetHeight(self.view.bounds)/9, 568/9);
    }
    frame.origin.y = CGRectGetHeight(self.dayView.frame)+2*rowHeight;
    
    self.twoWeekVC.view.frame = frame;
    
    [self.containerView bringSubviewToFront:self.twoWeekVC.view];
    
    self.twoWeekVC.selectedDate = self.collectionVC.selectedDate;
    
  } completion:^(BOOL finished) {
    
    NSString *navtitle= [NSDate getMonthYearFromCalendar:self.calendar date:self.collectionVC.selectedDate];
    self.navigationItem.title = navtitle;
  }];
}

#pragma mark - WeekCalendarView Delegate

- (void)eventWasSelected
{
  self.fromCreateEvent = YES;
}

- (void)scrollCollectionViewBy:(CGFloat)distance
{
  [self.collectionVC scrollCollectionViewBy:distance];
}

- (void)resetToOriginalPosition
{
  [self.collectionVC resetToOriginalPosition];
}

- (void)tableViewClosed
{
  self.twoWeekViewInFront = NO;
  
  self.collectionVC.twoWeekViewInFront = NO;
  
  [self.collectionVC.collectionView reloadData];
  
  [self.collectionVC resetSelectedDateMonthToTop];
}

#pragma mark - CollectionViewController Delegate

- (void)setNavigationTitle:(NSString *)title
{
  self.navigationItem.title = title;
}

- (void)cellWasSelected
{
  self.twoWeekVC.events = self.eventsDictionary;
  
  self.twoWeekVC.selectedDate = self.collectionVC.selectedDate;
  
  [self showTwoWeekViewController];
  
  self.twoWeekVC.tableViewController.dataItems = [self.eventsDictionary objectForKey:self.collectionVC.selectedDate];
  
  self.twoWeekVC.tableViewController.selectedDate = self.collectionVC.selectedDate;
  
  [self.twoWeekVC.tableViewController refreshTableView];
  
  [self.twoWeekVC updateToolBar];
}

- (void)updateEventsDictionaryWithCompletionBlock:(void(^)(void))completion
{
  [self populateCellsWithEventsWithCompletionHandler:^(NSMutableDictionary *dictionary) {
    
    self.collectionVC.events = self.eventsDictionary;
    self.twoWeekVC.events = self.eventsDictionary;
    completion();
  }];
}

#pragma mark - Events Fetch

- (NSArray *)calendarEventsForDate:(NSDate *)date
{
  NSDate *startDate = [NSDate calendarStartDateFromDate:date ForCalendar:self.calendar]; //starting from 12:01 am
  NSDate *endDate = [NSDate calendarEndDateFromDate:date ForCalendar:self.calendar]; // ending at 11:59 pm
  NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
  NSArray *events = [self.eventStore eventsMatchingPredicate:predicate];
  if (events.count>0) {
    [self.eventsDictionary setObject:events forKey:date];
  }
  return events;
}

- (void)populateCellsWithEventsWithCompletionHandler:(void (^) (NSMutableDictionary *))completion
{
  NSArray *visibleCells = [self.collectionVC.collectionView visibleCells];
  
  dispatch_queue_t myQueue = dispatch_queue_create("My Queue", NULL);
  
  for (int i=0; i<visibleCells.count; i++) {
    EPCalendarCell *cell= visibleCells[i];
    dispatch_sync(myQueue, ^{
      //get calendar events
      NSArray *events = [self calendarEventsForDate:cell.cellDate];
      if (events.count>0) {
        [self.eventsDictionary setObject:events forKey:cell.cellDate];
      } else {
        [self.eventsDictionary removeObjectForKey:cell.cellDate];
      }
      if (i== visibleCells.count-1) {
        completion(self.eventsDictionary);
      }
    });
  }
}

- (void)updateCollectionView
{
  if (!self.fromCreateEvent) {
    
    [self.collectionVC.collectionView performBatchUpdates:^{
      
      NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:self.collectionVC.collectionView.numberOfSections/2];
      [self.collectionVC.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
      
    } completion:^(BOOL finished) {
      [self updateEventsDictionaryWithCompletionBlock:^{
        [self.collectionVC populateCellsWithEvents];
      }];
    }];
    
  } else {
    [self updateEventsDictionaryWithCompletionBlock:^{
      
      [self.collectionVC populateCellsWithEvents];
      self.twoWeekVC.tableViewController.dataItems = [self.eventsDictionary objectForKey:self.collectionVC.selectedDate];
      [self.twoWeekVC.tableViewController refreshTableView];
    }];
    
    self.fromCreateEvent = NO;
  }
}

@end
