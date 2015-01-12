//
//  EPCollectionViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 1/9/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCalendarCollectionView.h"

@protocol EPCollectionViewControllerDelegate <NSObject>

- (void)updateEventsDictionaryWithCompletionBlock:(void(^)(void))completion;
- (void)cellWasSelected;
- (void)setNavigationTitle:(NSString *)title;

@end

@interface EPCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, EPCalendarCollectionViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) EPCalendarCollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSCalendar *calendar;
@property (weak, nonatomic) id <EPCollectionViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDictionary *events;

- (instancetype) initWithCalendar:(NSCalendar *)calendar;
- (void)populateCellsWithEvents;


@end
