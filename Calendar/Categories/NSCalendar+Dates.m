//
//  NSCalendar+dates.m
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSCalendar+Dates.h"

@implementation NSCalendar (Dates)

- (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
  NSDateComponents *selectedDateComponents = [self components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
  
  NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
  
  [dateComponents setYear:selectedDateComponents.year];
  [dateComponents setMonth:selectedDateComponents.month];
  [dateComponents setDay:selectedDateComponents.day];
  return dateComponents;
}


@end
