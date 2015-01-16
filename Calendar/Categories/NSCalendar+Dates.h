//
//  NSCalendar+dates.h
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar (Dates)

- (NSDateFormatter *) df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block;

@end
