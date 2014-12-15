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


+ (NSString*)getOrdinalSuffixForDate: (NSDate*)date forCalendar:(NSCalendar *)calendar{
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitDay fromDate:date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMMM"];
    NSString *monthName = [dateFormatter stringFromDate:date];
    NSInteger day= [components day];
    NSInteger year = [components year];
    NSArray *suffixLookup = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
    if (day % 100 >= 11 && day % 100 <= 13) {
        return [NSString stringWithFormat:@"%ld%@ %@, %ld", (long)day, @"th", monthName, (long)year];
    }
    return [NSString stringWithFormat:@"%ld%@ %@, %ld",(long)day, [suffixLookup objectAtIndex:(day % 10)], monthName, (long)year];
}

@end
