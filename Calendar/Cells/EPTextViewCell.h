//
//  TextViewCell.h
//  CRMStar
//
//  Created by Sunayna Jain on 7/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPTextViewWithPlaceholder.h"

static NSString *EPTextViewCellIdentifier = @"textViewCellIdentifier";

@interface EPTextViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet EPTextViewWithPlaceholder *textView;

+ (UINib *)nib;
- (void)configureCellWithText:(NSString*)text andPlaceHolder:(NSString*)placeHolder;
+ (CGFloat)textViewWidth;

@end
