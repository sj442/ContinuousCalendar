//
//  EventStore.m
//  Calendar
//
//  Created by Sunayna Jain on 12/9/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPEventStore.h"

@implementation EventStore

@synthesize eventStore = _eventStore;

+ (instancetype)sharedInstance
{
    static EventStore *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[EventStore alloc] init];
        }
    });
    return sharedInstance;
}

- (EKEventStore*)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}


@end
