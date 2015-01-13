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

- (void)checkNavigationTitle:(NSString *)title;
- (void)updateEventsDictionaryWithCompletionBlock:(void(^)(void))completion;
- (void)eventWasSelected;

@end

@interface EPTwoWeekCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, TableViewDelegate>

- (instancetype)initWithCalendar:(NSCalendar *)calendar;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSDate *referenceDate;
@property (strong, nonatomic) NSMutableDictionary *events;
@property BOOL fromCreateEvent;
@property (strong, nonatomic) EPCalendarTableViewController *tableViewController;

@property (strong, nonatomic) UICollectionViewFlowLayout *weekFlowLayout;
@property (strong, nonatomic) NSCalendar *calendar;

@property (weak, nonatomic) id <EPTwoWeekCollectionViewControllerDelegate> weekDelegate;

@end
