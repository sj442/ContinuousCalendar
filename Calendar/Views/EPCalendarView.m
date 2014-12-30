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
#import "UIColor+EH.h"


static NSString * const EPCalendarCellIDentifier = @"CalendarCell";
static NSString * const EPCalendarMonthHeaderIDentifier = @"MonthHeader";

@interface EPCalendarView () <UICollectionViewDelegate, UICollectionViewDataSource, EPCalendarCollectionViewDelegate>

@property (assign, nonatomic) EPCalendarDate fromDate;
@property (assign, nonatomic) EPCalendarDate toDate;

+ (NSCache *) eventsCache;

@end

@implementation EPCalendarView

- (instancetype) initWithCalendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.calendar = calendar;
        self.selectedDate = [NSDate date];
        self.backgroundColor = [UIColor whiteColor];
        NSDate *now = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]]];
        
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        self.fromDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
        
        components.month = 6;
        self.toDate = [self calendarDateFromDate:[self.calendar dateByAddingComponents:components toDate:now options:0]];
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
    
    [self initializeFlowLayout];
    [self initializeCollectionView];
    
    self.collectionView.frame = self.bounds;
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (EPCalendarCollectionView *)initializeCollectionView
{
    if (!_collectionView) {
        _collectionView = [[EPCalendarCollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.layer.shadowColor =[UIColor whiteColor].CGColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.myDelegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[EPCalendarCell class] forCellWithReuseIdentifier:EPCalendarCellIDentifier];
        [_collectionView registerClass:[EPCalendarMonthHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:EPCalendarMonthHeaderIDentifier];
        [_collectionView reloadData];
        
        UIPanGestureRecognizer *pan = _collectionView.panGestureRecognizer;
        [pan addTarget:self action:@selector(collectionViewPanned:)];
    }
    return _collectionView;
}

- (void)collectionViewPanned:(UIPanGestureRecognizer *)pan
{
    if (fabsf([pan velocityInView:self].y)>500.0f) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded && fabsf([pan velocityInView:self].y)<500.0f) {
        [self populateCells];
    }
}

- (UICollectionViewFlowLayout *)initializeFlowLayout
{
    if (!self.flowLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 44);
        layout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds)/8, CGRectGetHeight(self.bounds)/8);
        layout.minimumLineSpacing = 2.0f;
        layout.minimumInteritemSpacing = 2.0f;
        self.flowLayout = layout;
    }
    return self.flowLayout;
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
    
    [cv reloadData];
    [cvLayout invalidateLayout];
    [cvLayout prepareLayout];
    
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((EPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath]).enabled;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EPCalendarCell *cell = ((EPCalendarCell *)[self.collectionView cellForItemAtIndexPath:indexPath]);
    if (!cell.enabled) {
        return;
    }
    [self willChangeValueForKey:@"selectedDate"];
    self.selectedIndexPath = indexPath;
    _selectedDate = cell
    ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]]
    : nil;
    [self didChangeValueForKey:@"selectedDate"];
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    [self.delegate moveupTableView];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    [self.collectionView reloadData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        EPCalendarMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EPCalendarMonthHeaderIDentifier forIndexPath:indexPath];
        
        NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:@"calendarMonthHeader" withConstructor:^{
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.calendar = self.calendar;
            dateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"LLL" options:0 locale:[NSLocale currentLocale]];
            return dateFormatter;
        }];
        
        NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
        NSDateComponents *formattedDateComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:formattedDate];
        NSUInteger weekday = [formattedDateComponents weekday];
        NSDateFormatter *abbreviatedDateFormatter = [[NSDateFormatter alloc]init];
        abbreviatedDateFormatter.calendar = self.calendar;
        abbreviatedDateFormatter.dateFormat = [dateFormatter.class dateFormatFromTemplate:@"yyyyLLLL" options:0 locale:[NSLocale currentLocale]];
        NSString *navtitle =[abbreviatedDateFormatter stringFromDate:formattedDate];
        [self.delegate setNavigationTitle:navtitle];
        
        NSString *monthHeaderString = [dateFormatter stringFromDate:formattedDate];
        monthHeader.textLabel.text = [monthHeaderString uppercaseString];
        CGRect frame = monthHeader.textLabel.frame;
        frame.origin.x = 5+CGRectGetWidth(self.bounds)/7*(weekday-1);
        frame.size.width = 50;
        monthHeader.textLabel.frame = frame;
        monthHeader.textLabel.textColor = [UIColor primaryColor];
        monthHeader.textLabel.textAlignment = NSTextAlignmentLeft;
        return monthHeader;
    }
    return nil;
}

- (NSDate *)dateFromCalendarDate:(EPCalendarDate)dateStruct
{
    return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *)dateComponentsFromPickerDate:(EPCalendarDate)dateStruct
{
    NSDateComponents *components = [NSDateComponents new];
    components.year = dateStruct.year;
    components.month = dateStruct.month;
    components.day = dateStruct.day;
    return components;
}

- (EPCalendarDate)calendarDateFromDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return (EPCalendarDate) {
        components.year,
        components.month,
        components.day
    };
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self populateCells];
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

- (void)collectionViewTappedAtPoint:(CGPoint)point
{
    NSIndexPath *ip = [self.collectionView indexPathForItemAtPoint:point];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:ip];
}

- (void)populateCells
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (EPCalendarCell *cell in visibleCells) {
        cell.hasEvents = [self calendarEventsForDate:cell.cellDate] && cell.isEnabled;
        [cell layoutSubviews];
    }
}

- (void)populateCellsWithEvents
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (EPCalendarCell *cell in visibleCells) {
        cell.hasEvents = [self calendarEventsForDate:cell.cellDate] && cell.isEnabled;
        [cell layoutSubviews];
    }
}

@end
