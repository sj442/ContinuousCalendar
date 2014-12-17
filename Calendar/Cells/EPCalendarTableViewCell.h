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

@property (weak, nonatomic) UILabel *separatorLabel;
@property (strong, nonatomic) NSNumber *startHour;
@property (strong, nonatomic) NSNumber *endHour;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableDictionary *layoutAttributes;
@property NSInteger eventsCount;

@end
