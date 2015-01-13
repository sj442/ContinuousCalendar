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

@protocol TableViewDelegate <NSObject>

- (void)eventWasSelected;

@end

@interface EPCalendarTableViewController : UIViewController <CalendarTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSArray *dataItems;
@property (strong, nonatomic) NSCalendar *calendar;
@property BOOL fromCreateEvent;

@property (weak, nonatomic) id <TableViewDelegate> tableViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)refreshTableView;

@end
