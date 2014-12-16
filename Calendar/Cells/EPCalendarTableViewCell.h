//
//  EPCalendarTableviewCell.h
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *EPCalendarTableViewCellIdentifier = @"CalendarTableViewCellIdentifier";

@interface EPCalendarTableViewCell : UITableViewCell

+ (UINib *)nib;

@property (weak, nonatomic) UILabel *separatorView;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSMutableArray *events;
@property  BOOL hasEvents;

@end
