//
//  DatePickerCell.h
//  CRMStar
//
//  Created by Sunayna Jain on 5/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *EPDatePickerCellIdentifier = @"datePickerCell";

@protocol EPDatePickerDelegate <NSObject>

- (void)datePickerButtonWasPressed;
- (void)timePickerButtonWasPressed;

@end

@interface EPDatePickerCell : UITableViewCell

@property (weak) id <EPDatePickerDelegate> datePickerDelegate;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property BOOL fromTaskList;

@end
