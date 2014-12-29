//
//  EventDataClass.m
//  Calendar
//
//  Created by Sunayna Jain on 12/29/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EventDataClass.h"

@implementation EventDataClass

- (instancetype)initWithHeight:(NSNumber *)height startPointY:(NSNumber *)startPointY event:(EKEvent *)event isStartIP:(NSNumber *)isStartIP sameStartDate:(NSNumber *)sameStartDate
{
    self = [super init];
    if (self) {
        self.isStartIP = isStartIP;
        self.sameStartDate = sameStartDate;
        self.height = height;
        self.startPointY = startPointY;
    }
    return self;
}

@end
