//
//  EPCalendarTableViewController.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

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
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSTimer *currentTimer;
@property (strong, nonatomic) UIView *blankView;

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
    
    if ([self.calendarView.selectedDate isCurrentDateForCalendar:self.calendarView.calendar]) {
        NSInteger minutes = [self.calendarView.calendar component:NSCalendarUnitMinute fromDate:[NSDate date]];
        NSInteger hour = [self.calendarView.calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
        CGFloat tableViewHeight = 44*25;
        NSInteger totalMinutes = hour*60+ minutes;
        CGFloat startPointY = (totalMinutes*tableViewHeight)/(25*60);
        int cellNumber = startPointY/44;
        int blankViewStartPointY = cellNumber*44-5;
        UIView *blankView = [[UIView alloc]initWithFrame:CGRectMake(0, blankViewStartPointY, 50, 44)];
        blankView.backgroundColor = [UIColor whiteColor];
        [self.tableView addSubview:blankView];
        self.blankView = blankView;
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(50, startPointY, CGRectGetWidth(self.view.frame), 1.0f)];
        lineView.backgroundColor = [UIColor redColor];
        [self.tableView addSubview:lineView];
        self.currentTimeMarker = lineView;
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, startPointY-5, 45, 10)];
        timeLabel.text = [NSDate getCurrentTimeForCalendar:self.calendarView.calendar];
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.textColor = [UIColor redColor];
        [self.tableView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(updateTimeMarkerLocation:) userInfo:nil repeats:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.calendarView.selectedDate isCurrentDateForCalendar:self.calendarView.calendar]) {
        NSIndexPath *ip = [self indexPathForDate:[NSDate date]];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupCalendarView
{
    EPWeekCalendarView *calendarView = [EPWeekCalendarView new];
    calendarView.frame =CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/6);
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
    cell.separatorLabel.hidden = NO;
    for (UIView *view in cell.contentView.subviews) {
        if (!(view.tag ==100)) {
            [view removeFromSuperview];
        }
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 50, 0, 0);
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
    cell.separatorLabel.hidden = NO;
    NSArray *events = [self.indexDictionary objectForKey:indexPath];
    CGFloat startPointX = 50;
    CGFloat height = 0;
    CGFloat startPointY = 0;
    
    for (NSArray *arrayOfEvents in events) {
        for (int k =0; k<arrayOfEvents.count; k++) {
            EventDataClass *eventData = arrayOfEvents[k];
            CGFloat width = (self.tableView.frame.size.width-50)/arrayOfEvents.count;
            startPointX = 50 + width*k;
            height = eventData.height.floatValue;
            startPointY = eventData.startPointY.floatValue;
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
        }
    }
    return cell;
}

- (NSArray *)visibleIndexPaths
{
    NSMutableArray *IPArray = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *ip = [self.tableView indexPathForCell:cell];
        if (ip !=nil) {
            [IPArray addObject:ip];
        }
    }
    return IPArray;
}

- (void)viewTapped:(UIButton *)sender
{
    EPCalendarEventView *button = (EPCalendarEventView *)sender;
    EPCreateEventTableViewController *createVC = [[EPCreateEventTableViewController alloc]initWithEvent:button.event
                                                                                              eventName:button.event.title
                                                                                               location:button.event.location
                                                                                                  notes:button.event.notes
                                                                                              startDate:button.event.startDate
                                                                                                endDate:button.event.endDate];
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

- (id)fetchObjectForKey:(id)key withCreator:(id(^)(void))block
{
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
            NSString *compoundString =[NSDate timeAtIndex:indexPath.row
                                                  forDate:self.calendarView.selectedDate
                                                 calendar:self.calendarView.calendar];
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
        NSInteger itemsCount = sortedItems.count;
        NSInteger startHour = 0;
        NSMutableArray *listOfEvents = [NSMutableArray array];
        NSMutableArray *tempArray = [NSMutableArray array];
        int index = 0;
        
        for (int j=0; j<itemsCount; j++) {
            EKEvent *event = sortedItems[j];
            NSInteger eventStartHour = [self.calendarView.calendar component:NSCalendarUnitHour fromDate:event.startDate];
            EventDataClass *eventData = [self compareEvent:event withCellStartDate:cellStartDate cellEndDate:cellEndDate];
            NSIndexPath *startIP = eventData.startIP;
            if (startIP.row == indexPath.row) {
                eventData.isStartIP = [NSNumber numberWithInt:1];
            } else {
                eventData.isStartIP = [NSNumber numberWithInt:0];
            }
            scrollToIP = startIP;
            if (index == 0) {
                startHour = eventStartHour;
                [tempArray addObject:eventData];
                index++;
                if (itemsCount ==1 || j == itemsCount-1) {
                    [listOfEvents addObject:tempArray];
                }
            } else if (startHour == eventStartHour) {
                [tempArray addObject:eventData];
                index++;
                if (j== itemsCount-1) {
                    [listOfEvents addObject:tempArray];
                }
            } else {
                [listOfEvents addObject:tempArray];
                tempArray = [NSMutableArray new];
                index =0;
                startHour = eventStartHour;
                [tempArray addObject:eventData];
                index++;
                if (j == itemsCount-1) {
                    [listOfEvents addObject:tempArray];
                }
            }
        }
        [self.indexDictionary setObject:listOfEvents forKey:indexPath];
    }
        [CATransaction begin];
        [self.tableView beginUpdates];
    
    if ([self.calendarView.selectedDate isCurrentDateForCalendar:self.calendarView.calendar]) {
        NSIndexPath *ip = [self indexPathForDate:[NSDate date]];
        [self.tableView scrollToRowAtIndexPath:ip
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
        
        [CATransaction setCompletionBlock:^{
        }];
    } else {
        [self.tableView scrollToRowAtIndexPath:scrollToIP
                              atScrollPosition:UITableViewScrollPositionTop
                                    animated:YES];
    }
    [self.tableView endUpdates];
    [CATransaction commit];
    [self.tableView reloadData];
}

- (EventDataClass *)compareEvent:(EKEvent *)event withCellStartDate:(NSDate *)cellStartDate cellEndDate:(NSDate *)cellEndDate
{
    NSInteger selectedDateDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:self.calendarView.selectedDate];
    NSIndexPath *startIP = [self indexPathForDate:event.startDate];
    EventDataClass *eventData = [[EventDataClass alloc]init];
    NSDate *startDate = event.startDate;
    NSInteger startDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:startDate];
    NSInteger eventStartHour = [self.calendarView.calendar component:NSCalendarUnitHour fromDate:startDate];
    NSDate *endDate = event.endDate;
    NSInteger endDay = [self.calendarView.calendar component:NSCalendarUnitDay fromDate:endDate];
    NSInteger startMinutes = 0;
    NSInteger endMinutes = 0;
    if (startDay != selectedDateDay) {
        startMinutes = 0;
        endMinutes  = [self minutesInDate:endDate];
        eventStartHour = 0;
        startIP = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if (endDay !=selectedDateDay) {
        endMinutes = 0;
        startMinutes = [self minutesInDate:startDate];
    } else {
        startMinutes = [self minutesInDate:startDate];
        endMinutes  = [self minutesInDate:endDate];
    }
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
        if (endMinutes ==0) {
            endMinutes =60;
        }
        height = (endMinutes*44)/60;
    } else if (startResult == NSOrderedAscending && endResult == NSOrderedDescending) { //cell is part of bigger event
        startPointY = 0;
        height =44;
    } else if (startResult == NSOrderedDescending && endResult == NSOrderedDescending) {
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
    eventData.event = event;
    eventData.height = [NSNumber numberWithFloat:height];
    eventData.startPointY = [NSNumber numberWithFloat:startPointY];
    eventData.startIP = startIP;
    return eventData;
}

- (void)updateTimeMarkerLocation:(id)sender
{
    NSInteger minutes = [self.calendarView.calendar component:NSCalendarUnitMinute fromDate:[NSDate date]];
    NSInteger hour = [self.calendarView.calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
    CGFloat tableViewHeight = 44*25;
    NSInteger totalMinutes = hour*60+ minutes;
    CGFloat startPointY = (totalMinutes*tableViewHeight)/(25*60);
    CGRect rect = self.currentTimeMarker.frame;
    rect.origin.y = startPointY;
    self.currentTimeMarker.frame = rect;
    self.timeLabel.text = [NSDate getCurrentTimeForCalendar:self.calendarView.calendar];
    rect = self.timeLabel.frame;
    rect.origin.y = startPointY-5;
    self.timeLabel.frame = rect;
    int cellNumber = startPointY/44;
    int blankViewStartPointY = cellNumber*44;
    if (minutes<30) {
        blankViewStartPointY = cellNumber*44-5;
    } else {
        blankViewStartPointY = (cellNumber+1)*44-5;
    }
    rect = self.blankView.frame;
    rect.origin.y = blankViewStartPointY;
    self.blankView.frame = rect;

}

@end
