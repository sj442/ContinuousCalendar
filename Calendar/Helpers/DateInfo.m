//
//  DateInfo.m
//  Calendar
//
//  Created by Sunayna Jain on 12/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "DateInfo.h"

@implementation DateInfo

- (instancetype)initWithIndexpath:(NSIndexPath *)indexpath selectedDate:(NSDate *)selectedDate
{
    self = [super init];
    if (self) {
        self.indexpath  = indexpath;
        self.selectedDate = selectedDate;
    }
    return self;
}

@end
