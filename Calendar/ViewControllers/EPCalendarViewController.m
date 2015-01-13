
//
//  EPCalendarCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarViewController.h"
#import "EPCalendarCell.h"
#import "EPCalendarWeekCell.h"
#import "UIColor+EH.h"
#import "NSDate+Calendar.h"
#import "EventStore.h"
#import "ExtendedNavBarView.h"

@interface EPCalendarViewController ()

@property (weak, nonatomic) ExtendedNavBarView *dayView;
@property (strong, nonatomic) EPCollectionViewController *collectionVC;
@property (strong, nonatomic) EPTwoWeekCollectionViewController *twoWeekVC;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSMutableDictionary *eventsDictionary;
@property (strong, nonatomic) EKEventStore *eventStore;

@property BOOL collectionViewDrawn;
@property BOOL twoWeekViewDrawn;

@end

@implementation EPCalendarViewController

#pragma mark -LifeCycle methods

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-49)];
  [self.view addSubview:container];
  self.containerView = container;
  [self setUpNavigationBar];
  self.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  self.eventsDictionary = [NSMutableDictionary dictionary];
  self.eventStore = [EventStore sharedInstance].eventStore;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (!self.collectionViewDrawn) {
    [self addCollectionViewController];
  }
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSNumber *access = [defaults objectForKey:@"calendarPermissionDone"];
  if (access == nil) {
    [self checkCalendarPermissions];
    [self restCalendarPermissionsWithCompletionHandler:^{
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

- (void)setUpNavigationBar
{
  self.navigationController.navigationBar.translucent = NO;
  self.automaticallyAdjustsScrollViewInsets = NO;
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor primaryColor]}];
  self.navigationController.navigationBar.tintColor = [UIColor primaryColor];
  
  [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init]
                                                forBarMetrics:UIBarMetricsDefault];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"B22_taskbar__add-icon-outline"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent:)];
  CGRect bounds = [UIScreen mainScreen].bounds;
  ExtendedNavBarView *dayView = [[ExtendedNavBarView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds)/25)];
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
  collectionVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.dayView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(self.dayView.frame));
  self.collectionVC = collectionVC;
  self.collectionViewDrawn = YES;
}

- (void)addTwoWeekViewController
{
  EPTwoWeekCollectionViewController *twoWeekVC = [[EPTwoWeekCollectionViewController alloc]initWithCalendar:self.calendar];
  [self addChildViewController:twoWeekVC];
  [self.containerView insertSubview:twoWeekVC.view aboveSubview:self.collectionVC.view];
  [twoWeekVC didMoveToParentViewController:self];
  twoWeekVC.view.frame = CGRectMake(0, CGRectGetHeight(self.containerView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView.frame)-CGRectGetHeight(self.dayView.frame));
  self.twoWeekVC = twoWeekVC;
  self.twoWeekVC.events= self.eventsDictionary;
  self.twoWeekVC.weekDelegate = self;
}

- (void)checkCalendarPermissions
{
  EKEventStore *eventStore = [[EventStore sharedInstance] eventStore];
  [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
    // handle access here
    if (granted) {
      [eventStore reset];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChangedNotification:) name:EKEventStoreChangedNotification object:nil];
  }];
}

- (void)eventStoreChangedNotification:(NSNotification *)sneder
{
  if (!self.fromCreateEvent) {
    [self updateCollectionView];
  } else {
    self.fromCreateEvent = NO;
    [self updateEventsDictionaryWithCompletionBlock:^{
      [self.collectionVC populateCellsWithEvents];
      self.twoWeekVC.events = self.eventsDictionary;
    }];
  }
}

- (void)restCalendarPermissionsWithCompletionHandler:(void (^)(void))completion
{
  EKEventStore *eventStore = [[EventStore sharedInstance] eventStore];
  [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
    // handle access here
    if (granted) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"calendarPermissionDone"];
        [eventStore reset];
        completion();
      });
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"calendarPermissionDone"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        completion();
      });
    }
  }];
}

- (void)addEvent:(id)sender
{
  EPCreateEventTableViewController *createEventVC;
  createEventVC = [[EPCreateEventTableViewController alloc] initWithDate:self.collectionVC.selectedDate];
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
    self.twoWeekViewDrawn = YES;
  }
  [UIView animateWithDuration:0.1 animations:^{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goToFullCalendarView:)];
    CGRect frame = self.twoWeekVC.view.frame;
    frame.origin.y = CGRectGetHeight(self.dayView.frame);
    self.twoWeekVC.view.frame = frame;
    [self.containerView bringSubviewToFront:self.twoWeekVC.view];
    self.twoWeekVC.selectedDate = self.collectionVC.selectedDate;
    self.twoWeekVC.referenceDate = self.collectionVC.selectedDate;
    [self.twoWeekVC.collectionView reloadData];
  } completion:^(BOOL finished) {
    NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
    abbreviatedDateFormatter.calendar = self.calendar;
    abbreviatedDateFormatter.dateFormat = [abbreviatedDateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
    NSString *navtitle =[abbreviatedDateFormatter stringFromDate:self.collectionVC.selectedDate];
    self.navigationItem.title = navtitle;
  }];
}

- (void)goToFullCalendarView:(id)sender
{
  [UIView animateWithDuration:0.1 animations:^{
    CGRect frame = self.twoWeekVC.view.frame;
    frame.origin.y = CGRectGetHeight(self.containerView.frame);
    self.twoWeekVC.view.frame = frame;
    frame = self.collectionVC.view.frame;
    frame.origin.y = CGRectGetHeight(self.dayView.frame);
    self.collectionVC.view.frame = frame;
    [self.view bringSubviewToFront:self.collectionVC.view];
    self.collectionVC.selectedDate = self.twoWeekVC.selectedDate;
    self.navigationItem.leftBarButtonItem = nil;
  } completion:^(BOOL finished) {
    [self updateEventsDictionaryWithCompletionBlock:^{
      [self.collectionVC populateCellsWithEvents];
    }];
  }];
}

#pragma mark- WeekCalendarView Delegate

- (void)checkNavigationTitle:(NSString *)title
{
  self.navigationItem.title = title;
  self.collectionVC.selectedDate = self.twoWeekVC.selectedDate;
}

- (void)eventWasSelected
{
  self.fromCreateEvent = YES;
}

#pragma mark - CollectionViewController Delegate

- (void)setNavigationTitle:(NSString *)title
{
  self.navigationItem.title = title;
}

- (void)cellWasSelected
{
  self.twoWeekVC.events = self.eventsDictionary;
  [self showTwoWeekViewController];
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
  dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
  
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
  [self.collectionVC.collectionView performBatchUpdates:^{
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:self.collectionVC.collectionView.numberOfSections/2];
    [self.collectionVC.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
  } completion:^(BOOL finished) {
    [self updateEventsDictionaryWithCompletionBlock:^{
      [self.collectionVC populateCellsWithEvents];
    }];
  }];
}

@end
