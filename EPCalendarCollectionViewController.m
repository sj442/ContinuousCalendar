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
    calendarView.delegate = self;
    [self.view addSubview:calendarView];
    self.calendarView = calendarView;
        
    EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]initWithNibName:@"EPCalendarTableViewController" bundle:nil];
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

#pragma mark - CalendarTableView Delegate

- (void)dataItems:(NSArray *)items
{
    self.tableViewController.dataItems = items;
    [self.tableViewController.tableView reloadData];
}

- (void)setNavigationTitle:(NSString *)title
{
    self.title = title;
}

- (void)moveupTableView
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.tableViewController.view.frame;
        frame.origin.y = (CGRectGetHeight(self.calendarView.frame)/7)*2 +60;
        frame.size.height = self.view.frame.size.height -CGRectGetHeight(self.calendarView.frame)/7*2 +44;
        self.tableViewController.view.frame = frame;
        [self.view bringSubviewToFront:self.tableViewController.view];
        UIView *labelView = [[UIView alloc]initWithFrame:CGRectMake(0, -50, 320, 50)];
        labelView.backgroundColor = [UIColor redColor];
        [self.tableViewController.view addSubview:labelView];
        self.tableViewController.labelView = labelView;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBackToMonthView:)];
    }];
    }

- (void)goBackToMonthView: (id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = self.tableViewController.view.frame;
        frame.origin.y = self.calendarView.frame.origin.y;
        frame.size.height = self.calendarView.frame.size.height;
        self.tableViewController.view.frame = frame;
        [self.tableViewController.labelView removeFromSuperview];
        [self.view bringSubviewToFront:self.calendarView];
        self.navigationItem.leftBarButtonItem = nil;
        [self.calendarView populateCells];
        [self.calendarView.collectionView setCollectionViewLayout:self.calendarView.flowLayout];
    }];
}

@end
