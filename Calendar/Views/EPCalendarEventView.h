//
//  EPCalendarEventView.h
//  Calendar
//
//  Created by Sunayna Jain on 12/18/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface EPCalendarEventView : UIButton

@property (strong, nonatomic) EKEvent *event;

@end
