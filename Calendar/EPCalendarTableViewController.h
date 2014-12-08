//
//  EPCalendarTableViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarTableViewDelegate <NSObject>

- (void)moveUpTableView;
- (void)moveDownTableView;
@end

@interface EPCalendarTableViewController : UITableViewController

@property (weak, nonatomic) id <CalendarTableViewDelegate> delegate;

@property BOOL didMoveUp;

@end
