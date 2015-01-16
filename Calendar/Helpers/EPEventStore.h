//
//  EventStore.h
//  Calendar
//
//  Created by Sunayna Jain on 12/9/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventStore : NSObject

@property (strong, nonatomic) EKEventStore *eventStore;

+ (instancetype)sharedInstance;


@end
