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
}


//- (EPCalendarView *) calendarView {
//    if (!_calendarView) {
//        EPCalendarView *cv = [EPCalendarView new];
//        cv.frame = self.view.bounds;
//        cv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        _calendarView = cv;
//        _calendarView.delegate = self;
//    }
//    return _calendarView;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarTableView Delegate

- (void)moveUpTableView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.collectionViewContainer.frame;
        frame.origin.y = frame.origin.y-self.collectionViewContainer.frame.size.height*0.7;
        frame.size.height = frame.size.height;
        self.collectionViewContainer.frame = frame;
        frame = self.tableViewContainer.frame;
        frame.origin.y = frame.origin.y-self.collectionViewContainer.frame.size.height*0.7;
        self.tableViewContainer.frame = frame;
    } completion:^(BOOL finished) {
        [self.calendarView.collectionView scrollToItemAtIndexPath:self.calendarView.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        self.calendarView.collectionView.scrollEnabled = NO;
        self.didMoveUp = YES;
    }];
}

- (void)moveDownTableView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.collectionViewContainer.frame;
        frame.origin.y = frame.origin.y+self.collectionViewContainer.frame.size.height*0.7;
        self.collectionViewContainer.frame = frame;
        frame = self.tableViewContainer.frame;
        frame.origin.y = frame.origin.y+self.collectionViewContainer.frame.size.height*0.7;
        self.tableViewContainer.frame = frame;
    } completion:^(BOOL finished) {
        self.calendarView.collectionView.scrollEnabled = YES;
        self.didMoveUp = NO;
    }];
}

- (void)eventsButtonPressed
{
    if (!self.didMoveUp) {
        [self moveUpTableView];
    } else {
        [self moveDownTableView];
    }
}

- (void)dataItems:(NSArray *)items
{
    self.tableViewController.dataItems = items;
    [self.tableViewController.tableView reloadData];
}


- (void)setNavigationTitle:(NSString *)title
{
    self.title = title;
}

@end
