//
//  EPCalendarTableViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewController.h"
#import "EPCreateEventTableViewController.h"
#import <EventKit/EventKit.h>
#import "UIColor+EH.h"


@interface EPCalendarTableViewController ()

@end

@implementation EPCalendarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCalendarView];
    [self setupDayLabel];
    [self setupToolBar];
    [self setupTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCalendarView
{
    EPWeekCalendarView *calendarView = [EPWeekCalendarView new];
    calendarView.frame =CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150);
    [self.view addSubview:calendarView];
    self.calendarView = calendarView;
    self.calendarView.tableViewDelegate = self;
}

- (void)setupDayLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calendarView.bounds), CGRectGetWidth(self.view.bounds), 20)];
    label.text = @"date";
    label.backgroundColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor primaryColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [self.view addSubview:label];
    self.dayLabel = label;
}

- (void)setupToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dayLabel.frame), CGRectGetWidth(self.view.bounds), 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:nil];
    toolBar.items = @[flexibleSpace, events, flexibleSpace];
    toolBar.tintColor = [UIColor primaryColor];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), self.view.frame.size.height-CGRectGetHeight(self.calendarView.frame)-20-44-84)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1, self.dataItems.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    if (self.dataItems.count ==0) {
        cell.textLabel.text = @"                        No Events";
        cell.textLabel.textColor = [UIColor secondaryColor];
        
    } else {
        EKEvent *event = self.dataItems[indexPath.row];
        cell.textLabel.text = event.title;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    EKEvent *event = self.dataItems[indexPath.row];
    EPCreateEventTableViewController *createEvent = [[EPCreateEventTableViewController alloc]initWithEvent:event eventName:event.title location:event.location notes:event.notes startDate:event.startDate endDate:event.endDate];
    createEvent.eventSelected = YES;
    [self.navigationController pushViewController:createEvent animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - CalendarTableView Delegate

- (void)dataItems:(NSArray *)items
{
    self.dataItems = items;
    [self.tableView reloadData];
}

- (void)setDayLabelText:(NSString *)text
{
    self.dayLabel.text = text;
}

@end
