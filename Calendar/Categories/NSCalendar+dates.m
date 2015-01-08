//
//  NSCalendar+dates.m
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "NSCalendar+dates.h"

@implementation NSCalendar (dates)

- (NSDateFormatter *) df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block {
  
  NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
  NSDateFormatter *dateFormatter = threadDictionary[name];
  
  if (!dateFormatter) {
    dateFormatter = block();
    threadDictionary[name] = dateFormatter;
  }
  
  return dateFormatter;
  
}

@end
