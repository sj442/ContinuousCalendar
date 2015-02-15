//
//  EPCalendarTableviewCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewCell.h"

@implementation EPCalendarTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    self.layoutAttributes = [NSMutableDictionary dictionary];
    
    self.events = [NSMutableArray array];
    
    [self setupSeparatorView];
    
    self.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
  }
  return self;
}

- (void)setupSeparatorView
{
  UILabel *separatorView = [UILabel new];
  
  CGRect frame = CGRectZero;
  frame.origin.x = 5;
  frame.origin.y = 1;
  frame.size.width = 50;
  frame.size.height = 10;
  separatorView.frame = frame;
  
  separatorView.tag = 100;
  
  separatorView.font = [UIFont systemFontOfSize:10];
  
  separatorView.textColor = [UIColor grayColor];
  
  [self.contentView addSubview:separatorView];
  
  self.separatorLabel = separatorView;

}

@end
