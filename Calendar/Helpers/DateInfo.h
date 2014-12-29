//
//  DateInfo.h
//  Calendar
//
//  Created by Sunayna Jain on 12/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateInfo : NSObject

@property (strong, nonatomic) NSIndexPath *indexpath;
@property (strong, nonatomic) NSDate *selectedDate;

- (instancetype)initWithIndexpath:(NSIndexPath *)indexpath selectedDate:(NSDate *)selectedDate;

@end
