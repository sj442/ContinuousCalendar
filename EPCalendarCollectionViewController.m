//
//  EPCalendarCollectionViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarCollectionViewController.h"
#import "EPCalendarTableViewController.h"

@interface EPCalendarCollectionViewController ()

@property (strong, nonatomic) EPCalendarTableViewController *tableViewController;

@end

@implementation EPCalendarCollectionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupToolBar];
    [self.collectionViewContainer addSubview:self.calendarView];
    
    EPCalendarTableViewController *tableVC = [[EPCalendarTableViewController alloc]init];
    self.tableViewController = tableVC;
    
    [self addChildViewController:tableVC];
    [self.tableViewContainer addSubview:tableVC.view];
    [tableVC didMoveToParentViewController:self];
    tableVC.view.frame = self.tableViewContainer.bounds;
    tableVC.delegate = self;
}

- (void)setupToolBar
{
    UIBarButtonItem *sunday = [[UIBarButtonItem alloc] initWithTitle:@"S" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *monday = [[UIBarButtonItem alloc] initWithTitle:@"M" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *tuesday = [[UIBarButtonItem alloc] initWithTitle:@"T" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *wednesday = [[UIBarButtonItem alloc] initWithTitle:@"W" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *thursday = [[UIBarButtonItem alloc] initWithTitle:@"T" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *friday = [[UIBarButtonItem alloc] initWithTitle:@"F" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *saturday = [[UIBarButtonItem alloc] initWithTitle:@"S" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    self.toolBar.items = @[sunday, space, monday, space, tuesday, space, wednesday, space, thursday, space, friday, space, saturday];
}

- (EPCalendarView *) calendarView {
    if (!_calendarView) {
        EPCalendarView *cv = [EPCalendarView new];
        cv.frame = self.collectionViewContainer.bounds;
        cv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _calendarView = cv;
    }
    return _calendarView;
}

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
        self.collectionViewContainer.frame = frame;
        frame = self.tableViewContainer.frame;
        frame.origin.y = frame.origin.y-self.collectionViewContainer.frame.size.height*0.7;
        self.tableViewContainer.frame = frame;
    } completion:^(BOOL finished) {
        NSLog(@"collection View Moved Up");
        NSInteger item = self.calendarView.collectionView.numberOfSections/4;
        NSInteger section = self.calendarView.collectionView.numberOfSections/2;
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [self.calendarView.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
//        self.calendarView.collectionView.scrollEnabled = NO;
        self.tableViewController.didMoveUp = YES;
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
        NSLog(@"collection View Moved down");
        self.calendarView.collectionView.scrollEnabled = YES;
        self.tableViewController.didMoveUp = NO;
    }];
}

@end
