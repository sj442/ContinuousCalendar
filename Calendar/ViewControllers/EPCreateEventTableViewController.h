//
//  NewEventTVC.h
//  inlineDatePickerTVC
//
//  Created by Sunayna Jain on 6/13/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.
//

#import "EPInlineDatePickerTableViewController.h"
#import "EPCalendarViewController.h"

@protocol CreateEventDelegate <NSObject>

- (void)viewWillBeDismissed;

- (void)viewWillBePopped;

@end

@interface EPCreateEventTableViewController : EPInlineDatePickerTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <CreateEventDelegate> delegate;

- (instancetype)initWithEvent:(EKEvent*)event eventName:(NSString*)name location:(NSString*)location notes:(NSString*)notes startDate:(NSDate*)startDate endDate:(NSDate*)endDate;

- (instancetype)initWithDate:(NSDate*)date;

@end
