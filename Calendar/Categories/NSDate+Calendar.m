//
//  NSDate+calendar.m
//  Calendar
//
//  Created by Sunayna Jain on 12/9/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSDate+Calendar.h"

@implementation NSDate (Calendar)

+ (NSDate*)calendarStartDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar
{
  NSDateComponents * dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
                                                            | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
  
  NSInteger year = [dateComponents year];
  NSInteger month = [dateComponents month];
  NSInteger day = [dateComponents day];
  NSInteger startHour = 00;
  NSInteger startMinute =01;
  
  NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
  [startDateComponents setYear:year];
  [startDateComponents setMonth:month];
  [startDateComponents setDay:day];
  [startDateComponents setHour:startHour];
  [startDateComponents setMinute:startMinute];
  
  return [calendar dateFromComponents:startDateComponents];
}

+ (NSDate*)calendarEndDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar
{
  NSDateComponents * dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth
                                                            | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
  NSInteger year = [dateComponents year];
  NSInteger month = [dateComponents month];
  NSInteger day = [dateComponents day];
  NSInteger endHour = 23;
  NSInteger endMinute = 59;
  
  NSDateComponents *endDateComponents = [[NSDateComponents alloc]init];
  [endDateComponents setYear:year];
  [endDateComponents setMonth:month];
  [endDateComponents setDay:day];
  [endDateComponents setHour:endHour];
  [endDateComponents setMinute:endMinute];
  return [calendar dateFromComponents:endDateComponents];
}


+ (NSString*)getOrdinalSuffixForDate: (NSDate*)date forCalendar:(NSCalendar *)calendar{
  NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitDay fromDate:date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateFormat:@"EE MMMM"];
  NSString *monthName = [[[dateFormatter stringFromDate:date] componentsSeparatedByString:@" "] lastObject];
  NSString *weekdayName = [[[dateFormatter stringFromDate:date] componentsSeparatedByString:@" "] firstObject];
  NSInteger day= [components day];
  NSInteger year = [components year];
  NSArray *suffixLookup = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
  if (day % 100 >= 11 && day % 100 <= 13) {
    return [NSString stringWithFormat:@"%ld%@ %@, %ld", (long)day, @"th", monthName, (long)year];
  }
  return [NSString stringWithFormat:@"%@, %ld%@ %@", weekdayName, (long)day, [suffixLookup objectAtIndex:(day % 10)], monthName];
}

+ (NSString *)timeAtIndex:(NSInteger)index forDate:(NSDate *)date calendar:(NSCalendar *)calendar
{
  NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
  NSDateComponents *dateComponents = [[NSDateComponents alloc]init];
  [dateComponents setYear:components.year];
  [dateComponents setMonth: components.month];
  [dateComponents setDay:components.day];
  
  NSString *time;
  NSInteger quotient = index/12;
  NSInteger remainder = index % 12;
  NSInteger hour = 0;
  
  if (quotient == 0 && remainder == 0) { //12 AM
    time = @"12 AM";
    hour =0;
  } else if (quotient ==1 && remainder == 0) { //Noon
    time = @"Noon";
    hour =12;
  } else if (quotient ==0 && remainder>0) { //12.01 AM to 11:59 AM
    time = [NSString stringWithFormat:@"%ld AM", (long)remainder];
    hour = remainder;
  } else if (quotient == 1 && remainder >0) {
    time = [NSString stringWithFormat:@"%ld PM", (long)remainder];
    hour = index;
  } else if (quotient ==2 && remainder ==0) {
    time = @"12 AM";
    hour =24;
  }
  NSString *compoundString = [NSString stringWithFormat:@"%@~%ld", time, (long)hour];
  return compoundString;
}

+ (NSString *)getCurrentTimeForCalendar:(NSCalendar *)calendar
{
  NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  if ((hour>=1 && hour<=9) || (hour>=13 && hour <=21)) {
    [dateFormatter setDateFormat:@"h:mm a"];
  } else {
    [dateFormatter setDateFormat:@"hh:mm a"];
  }
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  return dateString;
}

+ (NSUInteger)numberOfWeeksForMonthOfDate:(NSDate *)date calendar:(NSCalendar *)calendar
{
  NSDate *firstDayInMonth = [calendar dateFromComponents:[calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
  
  NSDate *lastDayInMonth = [calendar dateByAddingComponents:((^{
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = 1;
    dateComponents.day = -1;
    return dateComponents;
  })()) toDate:firstDayInMonth options:0];
  
  NSDate *fromSunday = [calendar dateFromComponents:((^{
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
    dateComponents.weekday = 1;
    return dateComponents;
  })())];
  
  NSDate *toSunday = [calendar dateFromComponents:((^{
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
    dateComponents.weekday = 1;
    return dateComponents;
  })())];
  return 1 + [calendar components:NSCalendarUnitWeekOfMonth fromDate:fromSunday toDate:toSunday options:0].weekOfMonth;
}


+ (NSString *)getMonthYearFromCalendar:(NSCalendar *)calendar date:(NSDate *)date //ex: January 2015
{
  NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
  abbreviatedDateFormatter.calendar = calendar;
  abbreviatedDateFormatter.dateFormat = [[NSDateFormatter class] dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
  NSString *string =[abbreviatedDateFormatter stringFromDate:date];
  return string;
}


- (BOOL)isCurrentDateForCalendar:(NSCalendar *)calendar
{
  NSDate *date = (NSDate *)self;
  NSDate *today = [NSDate date];
  NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
  NSDateComponents *todayComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
  if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) {
    return YES;
  }
  return NO;
}


@end