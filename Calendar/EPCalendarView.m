//
//  EPCalendarView.m
//  Calendar
//
//  Created by Sunayna Jain on 12/5/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarView.h"
#import  <QuartzCore/QuartzCore.h>
#import "EPCalendarCollectionView.h"
#import "EPCalendarMonthHeader.h"
#import "EPCalendarCell.h"
#import "DateHelper.h"
#import "NSCalendar+dates.h"
#import "NSDate+calendar.h"
#import "EventStore.h"

static NSString * const EPCalendarCellIDentifier = @"CalendarCell";
static NSString * const EPCalendarMonthHeaderIDentifier = @"MonthHeader";

@interface EPCalendarView () <UICollectionViewDelegate, UICollectionViewDataSource, EPCalendarCollectionViewDelegate>

@property (strong, nonatomic) NSCalendar *calendar;
@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

+ (NSCache *) eventsCache;

@end

@implementation EPCalendarView

- (instancetype) initWithCalendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.calendar = calendar;
        NSDate *now = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]]];
        
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
        
        components.month = 6;
        self.toDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
                
        [self initializeFlowLayout];
        [self initializeCollectionView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithCalendar:[NSCalendar currentCalendar]];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    UICollectionView *cv = self.collectionView;
    NSInteger item = cv.numberOfSections/4;
    NSInteger section = cv.numberOfSections/2;
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [self.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (EPCalendarCollectionView *)initializeCollectionView
{
    if (!_collectionView) {
        _collectionView = [[EPCalendarCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[EPCalendarCell class] forCellWithReuseIdentifier:EPCalendarCellIDentifier];
        [_collectionView registerClass:[EPCalendarMonthHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPCalendarMonthHeaderIDentifier];
        [_collectionView reloadData];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)initializeFlowLayout
{
    if (!self.flowLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 64);
        layout.itemSize = CGSizeMake(44, 44);
        layout.minimumLineSpacing = 2.0f;
        layout.minimumInteritemSpacing = 2.0f;
        self.flowLayout = layout;
    }
    return self.flowLayout;
}

- (void)centerCollectionViewToCurrentDateWithCompletion: (void (^)(void))completion;
{
    NSInteger item = 0;
    NSInteger section = self.collectionView.numberOfSections/2;
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [self.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    completion ();
}

- (void)populateCells
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (EPCalendarCell *cell in visibleCells) {
        cell.hasEvents = [self calendarEventsForDate:cell.cellDate] && cell.enabled;
        [cell layoutSubviews];
    }
}

- (void)calendarCollectionViewWillLayoutSubviews:(EPCalendarCollectionView *)collectionView
{
    if (collectionView.contentOffset.y < 0.0f) { //swiping down
        [self appendPastDates];
    }
    
    if (collectionView.contentOffset.y > (collectionView.contentSize.height - CGRectGetHeight(collectionView.bounds))) {
        [self appendFutureDates];
    }
}

- (void)appendPastDates
{
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.month = -6;
    [self shiftDatesByComponents:components];
}


- (void)appendFutureDates
{
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.month = 6;
    [self shiftDatesByComponents:components];
}


- (void)shiftDatesByComponents:(NSDateComponents *)components
{
    UICollectionView *cv = self.collectionView;
    UICollectionViewFlowLayout *cvLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (![visibleCells count]) {
        return;
    }
    NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
    NSInteger fromSection = fromIndexPath.section;
    NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
    UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
    CGPoint fromSectionOrigin = [self convertPoint:fromAttrs.frame.origin fromView:cv];

    self.fromDate= [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromCalendarDate:self.fromDate] options:0]];
    self.toDate= [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromCalendarDate:self.toDate] options:0]];

#if 0

//	This solution trips up the collection view a bit
//	because our reload is reactionary, and happens before a relayout
//	since we must do it to avoid flickering and to heckle the CA transaction (?)
//	that could be a small red flag too

[cv performBatchUpdates:^{
    
    if (components.month < 0) {
        
        [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            cv.numberOfSections - abs(components.month),
            abs(components.month)
        }]];
        
        [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            0,
            abs(components.month)
        }]];
        
    } else {
        
        [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            cv.numberOfSections,
            abs(components.month)
        }]];
        
        [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
            0,
            abs(components.month)
        }]];
    }
    
} completion:^(BOOL finished) {
    
    NSLog(@"%s %x", __PRETTY_FUNCTION__, finished);
    
}];

for (UIView *view in cv.subviews)
[view.layer removeAllAnimations];

#else

[cv reloadData];
[cvLayout invalidateLayout];
[cvLayout prepareLayout];

#endif

NSInteger toSection = [self.calendar components:NSCalendarUnitMonth fromDate:[self dateForFirstDayInSection:0] toDate:fromSectionOfDate options:0].month;
UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];

[cv setContentOffset:(CGPoint) {
    cv.contentOffset.x,
    cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
}];

}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateFromCalendarDate:self.fromDate] toDate:[self dateFromCalendarDate:self.toDate] options:0].month;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7 * [self numberOfWeeksForMonthOfDate:[self dateForFirstDayInSection:section]];
}

- (NSDate *) dateForFirstDayInSection:(NSInteger)section
{
    return [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = section;
        return dateComponents;
    })()) toDate:[self dateFromCalendarDate:self.fromDate] options:0];
}

- (NSUInteger) numberOfWeeksForMonthOfDate:(NSDate *)date
{
    NSDate *firstDayInMonth = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
    
    NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 1;
        dateComponents.day = -1;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    
    NSDate *fromSunday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
        dateComponents.weekday = 1;
        return dateComponents;
    })())];
    
    NSDate *toSunday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
        dateComponents.weekday = 1;
        return dateComponents;
    })())];
    
    return 1 + [self.calendar components:NSCalendarUnitWeekOfMonth fromDate:fromSunday toDate:toSunday options:0].weekOfMonth;
}

- (EPCalendarCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EPCalendarCellIDentifier forIndexPath:indexPath];
    cell.selected = NO;
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
    EPCalendarDate firstDayPickerDate = [self calendarDateFromDate:firstDayInMonth];
    NSUInteger weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday;
    
    NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = indexPath.item - (weekday - 1);
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    cell.cellDate = cellDate;
    cell.hasEvents = NO;
    EPCalendarDate cellPickerDate = [self calendarDateFromDate:cellDate];
    cell.date = cellPickerDate;
    cell.enabled = ((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
    EPCalendarDate today = [self calendarDateFromDate:[NSDate date]];
    cell.selected = ([self.selectedDate isEqualToDate:cellDate] || ((cellPickerDate.year == today.year) && (cellPickerDate.month == today.month) && (cellPickerDate.day == today.day)));
    return cell;
}

- (BOOL)calendarEventsForDate:(NSDate *)date
{
    EKEventStore *eventStore = [[EventStore sharedInstance] eventStore];
    //get EKEvents
    NSDate *startDate = [NSDate calendarStartDateFromDate:date ForCalendar:self.calendar]; //starting from 12:01 am
    NSDate *endDate = [NSDate calendarEndDateFromDate:date ForCalendar:self.calendar]; // ending at 11:59 pm
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    if (events.count>0) {
        [[[self class] eventsCache] setObject:events forKey:date];
        return YES;
    }
    return NO;
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]);
    [self willChangeValueForKey:@"selectedDate"];
    NSArray *events = [[[self class] eventsCache] objectForKey:cell.cellDate];
    self.selectedIndexPath = indexPath;
    [self.delegate dataItems:events];
    _selectedDate = cell
    ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]]
    : nil;
    [self didChangeValueForKey:@"selectedDate"];
}

- (void) setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    [self.collectionView reloadData];
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        EPCalendarMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPCalendarMonthHeaderIDentifier forIndexPath:indexPath];
        
        NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:@"calendarMonthHeader" withConstructor:^{
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.calendar = self.calendar;
            dateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
            return dateFormatter;
        }];
        
        NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
        monthHeader.textLabel.text = [dateFormatter stringFromDate:formattedDate];
        
        return monthHeader;
    }
    return nil;
}

- (NSDate *) dateFromCalendarDate:(EPCalendarDate)dateStruct
{
    return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *) dateComponentsFromPickerDate:(EPCalendarDate)dateStruct
{
    NSDateComponents *components = [NSDateComponents new];
    components.year = dateStruct.year;
    components.month = dateStruct.month;
    components.day = dateStruct.day;
    return components;
}

- (EPCalendarDate) calendarDateFromDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return (EPCalendarDate) {
        components.year,
        components.month,
        components.day
    };
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    NSLog(@"velocity %f", velocity.y);
//    if (fabsf(velocity.y)<1.0f) {
//        UICollectionView *cv = (UICollectionView *)scrollView;
//        NSArray *visibleCells = [cv visibleCells];
//        for (EPCalendarCell *cell in visibleCells) {
//            cell.hasEvents = [self calendarEventsForDate:cell.cellDate];
//            NSArray *events = [[[self class] eventsCache] objectForKey:cell.cellDate];
//            NSLog(@"0 events count %d", events.count);
//        }
//        [self.collectionView reloadData];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self populateCells];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma  mark - Events cache

+ (NSCache *) eventsCache {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });
    return cache;
}

@end
