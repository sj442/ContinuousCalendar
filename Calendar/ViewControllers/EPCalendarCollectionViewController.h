//
//  EPCalendarCollectionViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCalendarTableViewController.h"
#import "EPCalendarView.h"
#import "EPWeekCalendarView.h"

@interface EPCalendarCollectionViewController : UIViewController <CalendarViewDelegate, UICollectionViewDelegate, CalendarWeekViewDelegate>

@property (weak, nonatomic) IBOutlet EPCalendarView *calendarView;

@end
