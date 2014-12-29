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
#import "EPCalendarEventView.h"
#import "EventDataClass.h"
#import <EventKit/EventKit.h>

@interface EPCalendarTableViewController ()

@property (strong, nonatomic) UIBarButtonItem *eventsButton;
@property (strong, nonatomic) NSCache *separatorTimesCache;
@property (strong, nonatomic) NSMutableDictionary *startTimesCache;
@property (strong, nonatomic) NSMutableDictionary *endTimesCache;
@property (strong, nonatomic) NSMutableDictionary *indexDictionary;
@property (strong, nonatomic) UIView *currentTimeMarker;
@property (strong, nonatomic) NSTimer *currentTimer;

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
    NSInteger labels =0;
    int i=0;
    CGFloat startPointX = 50;
    for (EventDataClass *eventData in events) {
        for (UILabel *label in cell.contentView.subviews) {
            if (label.tag!=100) {
                labels++;
            }
        }
        NSInteger startDateCount = eventData.sameStartDate.integerValue;
        CGFloat width = eventData.width.floatValue;
        CGFloat height = eventData.height.floatValue;
        CGFloat startPointY = eventData.startPointY.floatValue;
        if (startDateCount>0) {
            startPointX = startPointX + 5*labels+width*i;
        } else {
            startPointX = startPointX +5*labels;
        }
        width = MIN(width, 320-startPointX);
        EPCalendarEventView *view = [[EPCalendarEventView alloc]initWithFrame:CGRectMake(startPointX, startPointY, width, height)];
        view.backgroundColor = [UIColor secondaryColor];
        view.event = eventData.event;
        [view addTarget:self action:@selector(viewTapped:) forControlEvents:UIControlEventTouchUpInside];
        if ([eventData.isStartIP isEqualToNumber:@1]) {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, CGRectGetWidth(view.frame)-10, CGRectGetHeight(view.frame))];
            titleLabel.text = eventData.event.title;
            titleLabel.font = [UIFont systemFontOfSize:12];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.numberOfLines = 3;
            titleLabel.alpha = 1;
            [view addSubview:titleLabel];
        }
        view.alpha = 0.3;
        [cell.contentView addSubview:view];
        i++;
    }
       return cell;
}

- (void)viewTapped:(UIButton *)sender
{
    EPCalendarEventView *button = (EPCalendarEventView *)sender;
    EPCreateEventTableViewController *createVC = [[EPCreateEventTableViewController alloc]initWithEvent:button.event eventName:button.event.title location:button.event.location notes:button.event.notes startDate:button.event.startDate endDate:button.event.endDate];
    createVC.eventSelected = YES;
    [self.navigationController pushViewController:createVC animated:YES];
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
        NSIndexPath *previousIP = [NSIndexPath indexPathForRow:24 inSection:0];
        NSMutableArray *array = [NSMutableArray array];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSDateComponents *selectedDateComponents = [self.calendarView.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.calendarView.selectedDate];
        NSInteger selectedDateDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:self.calendarView.selectedDate];
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
        NSInteger eventCount = 1;
        for (EKEvent *event in sortedItems) {
            EventDataClass *eventData = [[EventDataClass alloc]init];
            NSDate *startDate = event.startDate;
            NSInteger startDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:startDate];
            NSIndexPath *startIP = [self indexPathForDate:startDate];
            NSDate *endDate = event.endDate;
            NSInteger endDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:endDate];
            NSInteger startMinutes = 0;
            NSInteger endMinutes = 0;
            if (startDay != selectedDateDay) {
                startMinutes = 0;
                startIP = [NSIndexPath indexPathForRow:0 inSection:0];
            } else if (endDay !=selectedDateDay) {
                endMinutes = 0;
            } else {
                startMinutes = [self minutesInDate:startDate];
                endMinutes  = [self minutesInDate:endDate];
            }
            scrollToIP = startIP;
            NSComparisonResult startResult = [startDate compare:cellStartDate];
            NSComparisonResult startBoundaryResult = [startDate compare:cellEndDate];
            NSComparisonResult endBoundaryResult = [endDate compare:cellStartDate];
            NSComparisonResult endResult = [endDate compare:cellEndDate];
            CGFloat startPointY = 0.0;
            CGFloat height = 0.0;
            if ((startResult == NSOrderedDescending || startResult == NSOrderedSame) && (startBoundaryResult == NSOrderedAscending) && (endBoundaryResult == NSOrderedDescending) && (endResult == NSOrderedSame || endResult == NSOrderedAscending)) {
                //lies completely within the cell
                if (endMinutes ==0) {
                    endMinutes =60;
                }
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
            if (startMinutes>50) {
                startIP = [NSIndexPath indexPathForRow:startIP.row+1 inSection:startIP.section];
            }
            if (startIP.row == indexPath.row) {
                eventData.isStartIP = [NSNumber numberWithInt:1];
            } else {
                eventData.isStartIP = [NSNumber numberWithInt:0];
            }
            if (startIP.row == previousIP.row) {
                eventCount++;
                eventData.sameStartDate = [NSNumber numberWithInteger:eventCount];
            } else {
                eventData.sameStartDate = [NSNumber numberWithInteger:0];
            }
            previousIP = startIP;
            eventData.event = event;
            eventData.height = [NSNumber numberWithFloat:height];
            eventData.startPointY = [NSNumber numberWithFloat:startPointY];
            eventData.selectedDate = event.startDate;
            [array addObject:eventData];
        }
        for (EventDataClass *eventDataClass in array) {
                eventDataClass.width = [NSNumber numberWithFloat:(self.view.frame.size.width-50)/eventCount];
        }
        
        [self.indexDictionary setObject:array forKey:indexPath];
    }
        [self.tableView scrollToRowAtIndexPath:scrollToIP atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self.tableView reloadData];
}

//- (void)refreshCurrentTimeMarker
//{
//    if (self.currentTimer) {
//        [self.currentTimer invalidate];
//    }
//    
//    NSInteger minutes = [self.calendarView.calendar component:NSCalendarUnitMinute fromDate:[NSDate date]];
//    NSIndexPath *ip = [self indexPathForDate:[NSDate date]];
//    EPCalendarTableViewCell *cell = (EPCalendarTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
//    CGFloat startPointY = (minutes*44)/60;
//        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, startPointY, CGRectGetWidth(self.view.frame), 2.0f)];
//        lineView.backgroundColor = [UIColor redColor];
//        [cell.contentView addSubview:lineView];
//        self.currentTimeMarker = lineView;
//    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateTimeMarkerLocation:) userInfo:nil repeats:YES];
//}
//
//- (void)updateTimeMarkerLocation:(id)sender
//{
//    NSInteger minutes = [self.calendarView.calendar component:NSCalendarUnitMinute fromDate:[NSDate date]];
//    if (minutes ==0) {
//        [self refreshCurrentTimeMarker];
//    }
//    CGFloat startPointY = (minutes*44)/60;
//    CGRect rect = self.currentTimeMarker.frame;
//    rect.origin.y = startPointY;
//    self.currentTimeMarker.frame = rect;
//}

@end
