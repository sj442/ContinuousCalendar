//
//  EPCalendarTableviewCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/15/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarTableViewCell.h"

@implementation EPCalendarTableViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"EPCalendarTableViewCell" bundle:nil];
}

- (void)layoutSubviews
{
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
