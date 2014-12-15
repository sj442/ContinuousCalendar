//
//  NSDate+Description.m
//   MBCalendarKit
//
//  Created by Moshe Berman on 4/14/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "NSDate+Description.h"

@implementation NSDate (Description)

- (NSString *)description
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    return [formatter stringFromDate:self];
}

- (NSString *)dayNameOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"ccc"];
    return [[formatter stringFromDate:self] substringToIndex:1];
}

- (NSString *)monthNameOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMMM"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMMM yyyy"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthAbbreviationAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMM yyyy"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthAbbreviationOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMM"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthAndDayOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMMM d"];
    return [formatter stringFromDate:self];
}

- (NSString *)dayOfMonthOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"d"];
    return [formatter stringFromDate:self];
}

- (NSString *)monthAndDayAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    return [formatter stringFromDate:self];
}


- (NSString *)dayOfMonthAndYearOnCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:@"d yyyy"];
    return [formatter stringFromDate:self];
}

- (NSString*)formattedString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yy hh:mm a"];
    return [dateFormatter stringFromDate:self];
}

+ (BOOL)checkIfFirstDate:(NSDate*)firstDate isSmallerThanSecondDate:(NSDate*)secondDate
{
    NSTimeInterval first = [firstDate timeIntervalSince1970];
    NSTimeInterval second = [secondDate timeIntervalSince1970];
    int difference = second-first;
    if (difference>0) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*)getOrdinalSuffix: (NSDate*)date forCalendar:(NSCalendar *)calendar
{
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date];
    NSInteger day= [components day];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"cccc"];
    NSString *weekday = [formatter stringFromDate:date];
	NSArray *suffixLookup = @[@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th"];
    
	if (day % 100 >= 11 && day % 100 <= 13) {
		return [NSString stringWithFormat:@"%@, the %ld%@", weekday, (long)day, @"th"];
	}
	return [NSString stringWithFormat:@"%@, the %ld%@", weekday, (long)day, [suffixLookup objectAtIndex:(day % 10)]];
}

@end
