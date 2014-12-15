//
//  inlineDatePickerTVC.h
//  inlineDatePickerTVC
//
//  Created by Sunayna Jain on 6/13/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface EPInlineDatePickerTableViewController : UITableViewController<UITextViewDelegate, UIScrollViewDelegate>

@property NSInteger sections;
@property (strong, nonatomic) NSArray *sectionTitlesArray;
@property (weak, nonatomic) UITextView *nameTextView;
@property (weak, nonatomic) UITextView *locationTextView;
@property (weak, nonatomic) UITextView *descTextView;
@property (weak, nonatomic) UIDatePicker *startDatePicker;
@property (weak, nonatomic) UIDatePicker *endDatePicker;
@property (strong, nonatomic) EKEvent *event;
@property (strong, nonatomic) EKEventStore *localEventStore;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) NSCalendar *calendar;
@property (assign, nonatomic) BOOL contactPlaceHolder;
@property BOOL eventSelected;
@property BOOL editMode;

@end
