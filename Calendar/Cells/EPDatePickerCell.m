//
//  DatePickerCell.m
//  CRMStar
//
//  Created by Sunayna Jain on 5/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPDatePickerCell.h"

@implementation EPDatePickerCell

+(UINib*)nib
{
    return [UINib nibWithNibName:@"EPDatePickerCell" bundle:nil];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


-(void)timeButtonPressed:(id)sender
{
    [self.datePickerDelegate timePickerButtonWasPressed];
}

-(void)dateButtonPressed:(id)sender
{
    [self.datePickerDelegate datePickerButtonWasPressed];
}

@end
