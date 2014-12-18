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
@property (strong, nonatomic) NSCache *separatorTimesCache;
@property (strong, nonatomic) NSMutableDictionary *startTimesCache;
@property (strong, nonatomic) NSMutableDictionary *endTimesCache;
@property (strong, nonatomic) NSMutableDictionary *indexDictionary;

@end

@implementation EPCalendarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indexDictionary = [NSMutableDictionary dictionary];
    [self setupCalendarView];
    [self setupDayLabel];
    [self setupToolBar];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self populateStartAndEndTimeCache];
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
        if (!(view.tag ==100)) {
            [view removeFromSuperview];
        }
    }
    cell.separatorLabel.text = [self fetchObjectForKey:indexPath withCreator:^id {
        NSString *compoundString =[NSDate timeAtIndex:indexPath.row forDate:self.calendarView.selectedDate calendar:self.calendarView.calendar];
        NSString *time = [[compoundString componentsSeparatedByString:@"~"] firstObject];
        [self.separatorTimesCache setObject:time forKey:indexPath];
        NSString *hourString = [[compoundString componentsSeparatedByString:@"~"] lastObject];
        NSInteger hour = hourString.integerValue;
        [self.startTimesCache setObject:[NSNumber numberWithInteger:hour] forKey:indexPath];
        [self.endTimesCache setObject:[NSNumber numberWithInteger:hour+1] forKey:indexPath];
        return time;
    }];
    
    NSArray *events = [self.indexDictionary objectForKey:indexPath];
    NSLog(@"events %@", events);
    
    for (NSDictionary *temp in events) {
        NSInteger labels =0;
        for (UILabel *label in cell.contentView.subviews) {
            if (label.tag!=100) {
                labels++;
            }
        }
        CGFloat width = 200;
        CGFloat height = ((NSNumber *)[temp objectForKey:@"height"]).floatValue;
        CGFloat startPointY = ((NSNumber *)[temp objectForKey:@"startPointY"]).floatValue;
        CGFloat startPointX = 50 +15*labels;
        UILabel *view = [[UILabel alloc]initWithFrame:CGRectMake(startPointX, startPointY, width, height)];
        view.backgroundColor = [UIColor secondaryColor];
        if ([[temp objectForKey:@"isStartIP"] isEqualToNumber:@1]) {
            view.text = [temp objectForKey:@"title"];
        }
        view.font = [UIFont systemFontOfSize:12];
        view.textColor = [UIColor blackColor];
        view.numberOfLines = 2;
        view.alpha = 0.3;
        [cell.contentView addSubview:view];
    }
       return cell;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date
{
    NSInteger hour = [self.calendarView.calendar component:NSCalendarUnitHour fromDate:date];
    for (NSIndexPath *ip in [self.startTimesCache allKeys]) {
        NSInteger startHour = ((NSNumber *)[self.startTimesCache objectForKey:ip]).integerValue;
        if (startHour == hour) {
            return ip;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    EKEvent *event = self.dataItems[indexPath.row];
//    EPCreateEventTableViewController *createEvent = [[EPCreateEventTableViewController alloc]initWithEvent:event eventName:event.title location:event.location notes:event.notes startDate:event.startDate endDate:event.endDate];
//    createEvent.eventSelected = YES;
//    [self.navigationController pushViewController:createEvent animated:YES];
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
    [self populateStartAndEndTimeCache];
}

- (void)setToolbarText:(NSString *)text
{
    [self.eventsButton setTitle:text];
}

#pragma mark - Initializers

- (NSCache *)separatorTimesCache
{
    if (!_separatorTimesCache) {
        _separatorTimesCache = [NSCache new];
    }
    return _separatorTimesCache;
}

- (NSMutableDictionary *)startTimesCache
{
    if (!_startTimesCache) {
        _startTimesCache = [NSMutableDictionary new];
    }
    return _startTimesCache;
}

- (NSMutableDictionary *)endTimesCache
{
    if (!_endTimesCache) {
        _endTimesCache = [NSMutableDictionary new];
    }
    return _endTimesCache;
}

- (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block {
    id answer = [[self separatorTimesCache] objectForKey:key];
    if (!answer) {
        answer = block();
        [[self separatorTimesCache] setObject:answer forKey:key];
    }
    return answer;
}

- (void)populateStartAndEndTimeCache
{
    NSIndexPath *scrollToIP;
    for (int i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        EPCalendarTableViewCell *cell = (EPCalendarTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [self.indexDictionary removeAllObjects];
        cell.separatorLabel.text = [self fetchObjectForKey:indexPath withCreator:^id {
            NSString *compoundString =[NSDate timeAtIndex:indexPath.row forDate:self.calendarView.selectedDate calendar:self.calendarView.calendar];
            NSString *time = [[compoundString componentsSeparatedByString:@"~"] firstObject];
            [self.separatorTimesCache setObject:time forKey:indexPath];
            NSString *hourString = [[compoundString componentsSeparatedByString:@"~"] lastObject];
            NSInteger hour = hourString.integerValue;
            [self.startTimesCache setObject:[NSNumber numberWithInteger:hour] forKey:indexPath];
            [self.endTimesCache setObject:[NSNumber numberWithInteger:hour+1] forKey:indexPath];
            return time;
        }];
    }
    for (int i=0; i<=24; i++) {
        NSMutableArray *array = [NSMutableArray array];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSDateComponents *selectedDateComponents = [self.calendarView.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.calendarView.selectedDate];
        NSDateComponents *startDateComponents = [[NSDateComponents alloc]init];
        [startDateComponents setYear:selectedDateComponents.year];
        [startDateComponents setMonth:selectedDateComponents.month];
        [startDateComponents setDay:selectedDateComponents.day];
        [startDateComponents setHour:i];
        NSDate *cellStartDate = [self.calendarView.calendar dateFromComponents:startDateComponents];
        [startDateComponents setHour:i+1];
        NSDate *cellEndDate = [self.calendarView.calendar dateFromComponents:startDateComponents];
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"startDate" ascending:YES];
        NSArray *sortedItems = [self.dataItems sortedArrayUsingDescriptors:@[descriptor]];
        NSInteger eventCount = 0;
        for (EKEvent *event in sortedItems) {
            eventCount++;
            NSDate *startDate = event.startDate;
            NSIndexPath *startIP = [self indexPathForDate:startDate];
            scrollToIP = startIP;
            NSDate *endDate = event.endDate;
            NSInteger startMinutes = [self minutesInDate:startDate];
            NSInteger endMinutes  =[self minutesInDate:endDate];
            NSComparisonResult startResult = [startDate compare:cellStartDate];
            NSComparisonResult startBoundaryResult = [startDate compare:cellEndDate];
            NSComparisonResult endBoundaryResult = [endDate compare:cellStartDate];
            NSComparisonResult endResult = [endDate compare:cellEndDate];
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
            
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            if (startIP.row == indexPath.row) {
                [temp setObject:[NSNumber numberWithInt:1] forKey:@"isStartIP"];
            } else {
                [temp setObject:[NSNumber numberWithInt:0] forKey:@"isStartIP"];
            }
            [temp setObject:event.title forKey:@"title"];
            [temp setObject:[NSNumber numberWithFloat:height] forKey:@"height"];
            [temp setObject:[NSNumber numberWithFloat:startPointY] forKey:@"startPointY"];
            [array addObject:temp];
        }
        [self.indexDictionary setObject:array forKey:indexPath];
    }
    [self.tableView scrollToRowAtIndexPath:scrollToIP atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView reloadData];
}


@end