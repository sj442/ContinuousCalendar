//
//  DatePickerCell.m
//  CRMStar
//
//  Created by Sunayna Jain on 5/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPDatePickerCell.h"

@implementation EPDatePickerCell

+ (UINib*)nib
{
  return [UINib nibWithNibName:@"EPDatePickerCell" bundle:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    UILabel *startLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, CGRectGetHeight(self.contentView.frame))];
    [self.contentView addSubview:startLabel];
    self.startLabel = startLabel;
    
    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(140, 0, 160, CGRectGetHeight(self.contentView.frame))];
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}


- (void)timeButtonPressed:(id)sender
{
  [self.datePickerDelegate timePickerButtonWasPressed];
}

- (void)dateButtonPressed:(id)sender
{
  [self.datePickerDelegate datePickerButtonWasPressed];
}


@end
