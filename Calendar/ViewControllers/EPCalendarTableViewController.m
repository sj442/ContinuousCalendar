//
//  EPCalendarTableViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewController.h"
#import "EPCreateEventTableViewController.h"
#import "EPCalendarTableViewCell.h"
#import "UIColor+EH.h"
#import "NSDate+calendar.h"

#import <EventKit/EventKit.h>


@interface EPCalendarTableViewController ()

@property (strong, nonatomic) UIBarButtonItem *eventsButton;

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
}

- (void)setupCalendarView
{
    EPWeekCalendarView *calendarView = [EPWeekCalendarView new];
    calendarView.frame =CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/5);
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
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calendarView.frame), CGRectGetWidth(self.view.bounds), 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *events = [[UIBarButtonItem alloc]initWithTitle:@"Event" style:UIBarButtonItemStyleDone target:self action:nil];
    toolBar.items = @[flexibleSpace, events, flexibleSpace];
    toolBar.tintColor = [UIColor primaryColor];
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    self.eventsButton = events;
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBar.frame), CGRectGetWidth(self.view.bounds), self.view.frame.size.height-CGRectGetHeight(self.calendarView.frame)-20-84)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView registerNib:[EPCalendarTableViewCell nib] forCellReuseIdentifier:EPCalendarTableViewCellIdentifier];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EPCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EPCalendarTableViewCellIdentifier];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *separatorView = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 50, 10)];
    NSString *compoundString =[NSDate timeAtIndex:indexPath.row forDate:self.calendarView.selectedDate calendar:self.calendarView.calendar];
    separatorView.text = [[compoundString componentsSeparatedByString:@"~"] firstObject];
    separatorView.font = [UIFont systemFontOfSize:10];
    separatorView.textColor = [UIColor secondaryColor];
    cell.separatorView = separatorView;
    [cell.contentView addSubview:separatorView];
    
    NSString *dateString = [[compoundString componentsSeparatedByString:@"~"] lastObject];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    cell.startDate = date;
    NSDate *endDate = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    cell.endDate = endDate;
    
    cell.hasEvents = NO;
    for (EKEvent *event in self.dataItems) {
        if (event.allDay) {
            continue;
        }
        NSDate *startTime = event.startDate;
        NSInteger startMinutes = [self minutesInDate:startTime];
        NSDate *endTime = event.endDate;
        NSInteger endMinutes  =[self minutesInDate:endTime];
        if (endMinutes == 0) {
            endMinutes =60;
        }
        NSComparisonResult startResult = [startTime compare:date];
        NSComparisonResult startBoundaryResult = [startTime compare:endDate];
        NSComparisonResult endBoundaryResult = [endTime compare:date];
        NSComparisonResult endResult = [endTime compare:endDate];
        CGFloat startPointY = 0.0;
        CGFloat height = 0.0;
        if ((startResult == NSOrderedDescending || startResult == NSOrderedSame) && (startBoundaryResult == NSOrderedAscending) && (endBoundaryResult == NSOrderedDescending) && (endResult == NSOrderedSame || endResult == NSOrderedAscending)) { //lies completely within the cell
            startPointY = (startMinutes*44)/60;
            height = ((endMinutes-startMinutes)*44)/60;
        } else if ((startResult == NSOrderedSame || startResult == NSOrderedDescending) && (startBoundaryResult == NSOrderedAscending) && (endBoundaryResult == NSOrderedDescending) && (endResult == NSOrderedDescending)) { //only start time lies in the cell
            startPointY = (startMinutes*44)/60;
            height = ((60-startMinutes)*44)/60;
        } else if ((startResult == NSOrderedAscending) && (endBoundaryResult == NSOrderedDescending) && (startBoundaryResult == NSOrderedAscending) && (endResult ==NSOrderedSame || endResult == NSOrderedAscending)) { //only end time lies in the cell
            startPointY = 0;
            height = (endMinutes*44)/60;
        } else if (startResult == NSOrderedAscending && endResult == NSOrderedDescending) { //cell is part of bigger event
            startPointY = 0;
            height =44;
        } else if (startResult == NSOrderedDescending && endResult == NSOrderedDescending){
            //event does not lie even partially in the cell
            startPointY =0;
            height =0;
        } else if (startResult == NSOrderedAscending && endResult == NSOrderedAscending) {
            startPointY =0;
            height =0;
        }
        if (!cell.hasEvents) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(50, startPointY, 200, height)];
            view.backgroundColor = [UIColor yellowColor];
            [cell.contentView addSubview:view];
            cell.hasEvents = YES;
        } else {
            for (UIView *view in cell.contentView.subviews) {
                if (![view isKindOfClass:[UILabel class]]) {
                    
                }
            }
        }
        
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
    return 44;
}

- (NSInteger)minutesInDate:(NSDate *)date
{
    NSInteger minutes = [self.calendarView.calendar component:NSCalendarUnitMinute fromDate:date];
    return minutes;
}

#pragma mark - CalendarTableView Delegate

- (void)dataItems:(NSArray *)items
{
    self.dataItems = items;
    [self.tableView reloadData];
}

- (void)setToolbarText:(NSString *)text
{
    [self.eventsButton setTitle:text];
}

@end
