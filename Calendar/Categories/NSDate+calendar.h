//
//  NSDate+calendar.h
//  Calendar
//
//  Created by Sunayna Jain on 12/9/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (calendar)


+ (NSDate *)calendarStartDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar;

+ (NSDate *)calendarEndDateFromDate:(NSDate*)date ForCalendar:(NSCalendar*)calendar;

+ (NSString *)getOrdinalSuffixForDate: (NSDate*)date forCalendar:(NSCalendar *)calendar;

+ (NSString *)timeAtIndex:(NSInteger)index forDate:(NSDate *)date calendar:(NSCalendar *)calendar;

@end
