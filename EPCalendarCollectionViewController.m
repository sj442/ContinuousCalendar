//
//  EPCalendarCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarCollectionViewController.h"
#import "EPCalendarTableViewController.h"

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
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ExtendedNavBarView *dayView = [[ExtendedNavBarView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/25)];
    [self.view addSubview:dayView];
    
    self.dayView = dayView;
    
    EPCalendarView *calendarView = [EPCalendarView new];
    calendarView.frame =CGRectMake(0, CGRectGetMaxY(self.dayView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.dayView.frame));
    [self.view addSubview:calendarView];
    self.calendarView = calendarView;
    self.calendarView.delegate = self;
    
    EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]init];
    self.tableViewController = tableVC;
    [self addChildViewController:tableVC];
    tableVC.view.frame = self.calendarView.frame;
    [self.view insertSubview:tableVC.view belowSubview:self.calendarView];
    [tableVC didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.tableViewController.calendarView.selectedDate = self.calendarView.selectedDate;
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
        [self.calendarView populateCells];
        [self.calendarView.collectionView setCollectionViewLayout:self.calendarView.flowLayout];
        self.navigationItem.leftBarButtonItem = nil;
    } completion:^(BOOL finished) {
        self.calendarView.weekMode = NO;
        [self.calendarView populateCells];
    }];
}


@end
