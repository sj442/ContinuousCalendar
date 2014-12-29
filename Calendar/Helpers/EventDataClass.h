//
//  EventDataClass.h
//  Calendar
//
//  Created by Sunayna Jain on 12/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventDataClass : NSObject

- (instancetype)initWithHeight:(NSNumber *)height startPointY:(NSNumber *)startPointY event:(EKEvent *)event isStartIP:(NSNumber *)isStartIP sameStartDate:(NSNumber *)sameStartDate;

@property (strong, nonatomic) NSNumber *isStartIP;
@property (strong, nonatomic) NSNumber *sameStartDate;
@property (strong, nonatomic) EKEvent *event;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSNumber *startPointY;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSDate *selectedDate;

@end
