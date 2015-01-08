//
//  EPCalendarTableviewCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewCell.h"
#import "UIColor+EH.h"

@implementation EPCalendarTableViewCell

-(void)drawRect:(CGRect)rect
{

}

+ (UINib *)nib
{
  return [UINib nibWithNibName:@"EPCalendarTableViewCell" bundle:nil];
}

- (void)layoutSubviews
{
    
}

- (void)awakeFromNib
{
  // Initialization code
  self.layoutAttributes = [NSMutableDictionary dictionary];
  self.events = [NSMutableArray array];
  UILabel *separatorView = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, 50, 10)];
  separatorView.tag =100;
  separatorView.font = [UIFont systemFontOfSize:10];
  separatorView.textColor = [UIColor secondaryColor];
  [self.contentView addSubview:separatorView];
  self.separatorLabel = separatorView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
