//
//  EPTwoWeekCollectionViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCalendarTableViewController.h"

@protocol EPTwoWeekCollectionViewControllerDelegate <NSObject>

- (void)updateEventsDictionaryWithCompletionBlock:(void(^)(void))completion;

- (void)eventWasSelected;

- (void)tableViewClosed;

- (void)scrollCollectionViewBy:(CGFloat)distance;

- (void)resetToOriginalPosition;

@end

@interface EPTwoWeekCollectionViewController : UIViewController <EPTableViewDelegate>

- (instancetype)initWithCalendar:(NSCalendar *)calendar;

@property (strong, nonatomic) NSDate *selectedDate;

@property (strong, nonatomic) NSMutableDictionary *events;


@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSCalendar *calendar;

@property (strong, nonatomic) EPCalendarTableViewController *tableViewController;

@property BOOL fromCreateEvent;

@property (weak, nonatomic) id <EPTwoWeekCollectionViewControllerDelegate> weekDelegate;

- (void)updateToolBar;

@end
