//
//  TextViewCell.m
//  CRMStar
//
//  Created by Sunayna Jain on 7/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPTextViewCell.h"

@implementation EPTextViewCell

+ (UINib *)nib
{
    return [UINib nibWithNibName:@"EPTextViewCell" bundle:nil];
}

+ (CGFloat)textViewWidth
{
    return 300;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithText:(NSString *)text andPlaceHolder:(NSString *)placeHolder
{
    [self.textView setPlaceholderText:placeHolder];
    self.textView.font = [UIFont systemFontOfSize:16];

    if (text.length>0) {
        self.textView.text = text;
        [self.textView setPlaceHolderLabelHidden:YES];
    } else {
        [self.textView setPlaceHolderLabelHidden:NO];
    }
}

@end
