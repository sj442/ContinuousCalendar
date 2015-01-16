//
//  TextViewCell.m
//  CRMStar
//
//  Created by Sunayna Jain on 7/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPTextViewCell.h"

@implementation EPTextViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    EPTextViewWithPlaceholder *textView = [[EPTextViewWithPlaceholder alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.contentView.frame)-20, CGRectGetHeight(self.contentView.frame))];
    [self.contentView addSubview:textView];
    self.textView = textView;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addTextViewConstraints];
  }
  return self;
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

- (void)addTextViewConstraints
{
  [self.contentView removeConstraints:self.contentView.constraints];
  UITextView *tv = self.textView;
  NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(tv);
  NSArray *one = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10.0-[tv]-10.0-|" options:0 metrics:nil views:viewsDictionary];
  NSArray *two = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tv]-|" options:0 metrics:nil views:viewsDictionary];
  [self.contentView addConstraints:one];
  [self.contentView addConstraints:two];
}

@end
