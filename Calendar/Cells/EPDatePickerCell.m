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
    
    [self setupStartLabel];
    
    [self setupTimeLabel];
  }
  return self;
}

- (void)setupStartLabel
{
  UILabel *startLabel = [UILabel new];
  
  CGRect frame = CGRectZero;
  frame.origin.x = 10;
  frame.size.width = 120;
  frame.size.height = CGRectGetHeight(self.contentView.frame);
  startLabel.frame = frame;
  
  [self.contentView addSubview:startLabel];
  
  self.startLabel = startLabel;
}

- (void)setupTimeLabel
{
  UILabel *timeLabel = [UILabel new];
  
  CGRect frame = CGRectZero;
  frame.origin.x = 140;
  frame.size.width = 160;
  frame.size.height = CGRectGetHeight(self.contentView.frame);
  timeLabel.frame = frame;
  
  [self.contentView addSubview:timeLabel];
  
  self.timeLabel = timeLabel;
}


#pragma mark - IBActions

- (void)timeButtonPressed:(id)sender
{
  [self.datePickerDelegate timePickerButtonWasPressed];
}

- (void)dateButtonPressed:(id)sender
{
  [self.datePickerDelegate datePickerButtonWasPressed];
}


@end
