//
//  EPCalendarCollectionViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCalendarView.h"
#import "EPCalendarTableViewController.h"


@interface EPCalendarCollectionViewController : UIViewController <CalendarTableViewDelegate>

@property (strong, nonatomic) EPCalendarView *calendarView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIView *collectionViewContainer;

@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;

@property BOOL didMoveUp;

@end
