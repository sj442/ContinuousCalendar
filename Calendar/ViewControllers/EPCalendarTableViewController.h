//
//  EPCalendarTableViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPWeekCalendarView.h"
#import "EPCalendarView.h"


@interface EPCalendarTableViewController : UIViewController <CalendarTableViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UILabel *dayLabel;
@property (weak, nonatomic) EPWeekCalendarView *calendarView;

@property (strong, nonatomic) NSArray *dataItems;

- (void)drawEventsOnTableView;


@end
