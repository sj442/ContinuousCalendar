//
//  EPCalendarCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarCollectionViewController.h"
#import "EPCalendarTableViewController.h"
#import "EPCreateEventTableViewController.h"
#import "UIColor+EH.h"

#import "ExtendedNavBarView.h"

@interface EPCalendarCollectionViewController ()

@property (strong, nonatomic) EPCalendarTableViewController *tableViewController;

@property (weak, nonatomic) ExtendedNavBarView *dayView;

@end

@implementation EPCalendarCollectionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor primaryColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor primaryColor];

    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"B22_taskbar__add-icon-outline"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ExtendedNavBarView *dayView = [[ExtendedNavBarView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/25)];
    [self.view addSubview:dayView];
    
    self.dayView = dayView;
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    EPCalendarView *calendarView = [[EPCalendarView alloc]initWithCalendar:gregorian];
    calendarView.frame =CGRectMake(0, CGRectGetMaxY(self.dayView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.dayView.frame));
    [self.view addSubview:calendarView];
    self.calendarView = calendarView;
    self.calendarView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]init];
    self.tableViewController = tableVC;
    [self addChildViewController:tableVC];
    tableVC.view.frame = self.calendarView.frame;
    [self.view insertSubview:tableVC.view belowSubview:self.calendarView];
    [tableVC didMoveToParentViewController:self];
    
    [self.calendarView.collectionView performBatchUpdates:^{
        NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:self.calendarView.collectionView.numberOfSections/2];
        [self.calendarView.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionTop animated:NO];

    } completion:^(BOOL finished) {
        [self.calendarView populateCellsWithEvents];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addEvent:(id)sender
{
    EPCreateEventTableViewController *createEventVC;
    createEventVC = [[EPCreateEventTableViewController alloc] initWithDate:self.calendarView.selectedDate];
    createEventVC.editMode = YES;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:createEventVC];
    createEventVC.title = @"New Event";
    [self presentViewController:navC animated:YES completion:nil];
}

#pragma mark - CalendarView Delegate

- (void)setNavigationTitle:(NSString *)title
{
    self.title = title;
}

- (void)moveupTableView
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.tableViewController.view.frame;
        frame.origin.y = 20;
        frame.size.height = self.view.frame.size.height;
        self.tableViewController.view.frame = frame;
        self.tableViewController.calendarView.weekDelegate = self;
        self.tableViewController.calendarView.selectedDate = self.calendarView.selectedDate;
        self.tableViewController.calendarView.referenceDate = self.calendarView.selectedDate;
        [self.view bringSubviewToFront:self.tableViewController.view];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBackToMonthView:)];
    } completion:^(BOOL finished) {
        NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
        abbreviatedDateFormatter.calendar = self.calendarView.calendar;
        abbreviatedDateFormatter.dateFormat = [abbreviatedDateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
        NSString *navtitle =[abbreviatedDateFormatter stringFromDate:self.calendarView.selectedDate];
        self.title = navtitle;
    }];
}
     
- (void)goBackToMonthView: (id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.tableViewController.view.frame;
        frame.origin.y = self.calendarView.frame.origin.y;
        frame.size.height = self.calendarView.frame.size.height;
        self.tableViewController.view.frame = frame;
        [self.view bringSubviewToFront:self.calendarView];
        self.calendarView.selectedDate = self.tableViewController.calendarView.selectedDate;
        [self.calendarView populateCellsWithEvents];
        self.navigationItem.leftBarButtonItem = nil;
    } completion:^(BOOL finished) {
        [self.calendarView populateCellsWithEvents];
    }];
}

#pragma mark- WeekCalendarView Delegate

- (void)checkNavigationTitle:(NSString *)title
{
    self.title = title;
}


@end
