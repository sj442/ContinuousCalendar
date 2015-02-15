//
//  EPCalendarTableViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EPTableViewDelegate <NSObject>

- (void)eventWasSelected;

@end

@interface EPCalendarTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSDate *selectedDate;

@property (strong, nonatomic) NSArray *dataItems;

@property (strong, nonatomic) NSCalendar *calendar;

@property (weak, nonatomic) UITableView *tableView;

@property BOOL fromCreateEvent;

@property (weak, nonatomic) id <EPTableViewDelegate> tableViewDelegate;

- (void)refreshTableView;

@end
