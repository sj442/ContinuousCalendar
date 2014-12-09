//
//  NSDate+calendar.m
//  Calendar
//
//  Created by Sunayna Jain on 12/9/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSDate+calendar.h"

@implementation NSDate (calendar)

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

@end
