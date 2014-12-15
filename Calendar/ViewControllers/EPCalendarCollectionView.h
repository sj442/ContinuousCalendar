//
//  EPCalendarCollectionView.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EPCalendarCollectionView;

@protocol EPCalendarCollectionViewDelegate <UICollectionViewDelegate>

-(void)calendarCollectionViewWillLayoutSubviews: (EPCalendarCollectionView *)collectionView;

- (void)collectionViewTappedAtPoint:(CGPoint)point;

@end

@interface EPCalendarCollectionView : UICollectionView

@property (weak, nonatomic) id <EPCalendarCollectionViewDelegate> myDelegate;


@end
