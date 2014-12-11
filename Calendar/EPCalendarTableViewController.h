//
//  EPCalendarTableViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarTableViewDelegate <NSObject>


@end

@interface EPCalendarTableViewController : UIViewController

@property (weak, nonatomic) id <CalendarTableViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataItems;

@property (weak, nonatomic) UIView *labelView;

@end
