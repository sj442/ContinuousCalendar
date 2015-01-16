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
    // Initialization code
    self.layoutAttributes = [NSMutableDictionary dictionary];
    self.events = [NSMutableArray array];
    UILabel *separatorView = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 50, 10)];
    separatorView.tag = 100;
    separatorView.font = [UIFont systemFontOfSize:10];
    separatorView.textColor = [UIColor grayColor];
    [self.contentView addSubview:separatorView];
    self.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0);
    self.separatorLabel = separatorView;
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}


@end
