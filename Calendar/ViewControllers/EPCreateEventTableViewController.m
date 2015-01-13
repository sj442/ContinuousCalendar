//
//  NewEventTVC.m
//  inlineDatePickerTVC
//
//  Created by Sunayna Jain on 6/13/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.

#import "EPCreateEventTableViewController.h"
#import "EPDatePickerCell.h"
#import "NSDate+Description.h"
#import "EventStore.h"
#import "UIColor+EH.h"
#import "UIViewController+EPBackgroundImage.h"

@implementation EPCreateEventTableViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self setupEventStore];
    [self addSaveButton];
    [self addCancelButton];
  }
  return self;
}

- (id)initWithDate:(NSDate*)date
{
  self = [super init];
  if (self) {
    self.startDate = [NSDate dateWithTimeInterval:3600*10 sinceDate:date]; //10 am
    self.endDate = [NSDate dateWithTimeInterval:3600*11 sinceDate:date]; //11 am
  }
  return self;
}

- (id)initWithEvent:(EKEvent*)event eventName:(NSString*)name location:(NSString*)location notes:(NSString*)notes startDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
  self = [super init];
  if (self) {
    [self addEditButton];
    self.event = event;
    self.name = name;
    self.location = location;
    self.notes = notes;
    self.startDate = startDate;
    self.endDate = endDate;
  }
  return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationController.navigationBar.tintColor = [UIColor primaryColor];
  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor primaryColor]}];
  self.sectionTitlesArray = @[@"Details", @"Time", @"Description"];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark-Navigation bar methods

- (void)addEditButton
{
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(editButtonPressed:)];
}

- (void)addCancelButton
{
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(cancelPressed:)];
}

- (void)addSaveButton
{
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:self
                                                                           action:@selector(savePressed:)];
  self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark-action methods

- (void)viewTapped:(id)sender
{
  if ([self.descTextView isFirstResponder]) {
    [self.descTextView resignFirstResponder];
  }
}

- (void)cancelPressed:(id)sender
{
  if (self.eventSelected==1) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self.delegate viewWillBeDismissed];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)editButtonPressed:(UIBarButtonItem*)sender
{
  if ([sender.title isEqualToString:@"Edit"]) {
    self.title = @"Edit Event";
    sender.title = @"Save";
    self.editMode= YES;
    [self.tableView reloadData];
    return;
  } else if (self.eventSelected && [sender.title isEqualToString:@"Save"]) {
    [self saveObjects];
    
    self.editMode = NO;
    if (self.name.length==0) {
      UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Cannot save event"
                                                          message:@"event must have a title"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
      [alertview show];
    } else {
      if (self.startDatePicker) {
        self.startDate = self.startDatePicker.date;
      }
      if (self.endDatePicker) {
        self.endDate = self.endDatePicker.date;
      }
      self.event.title = self.name;
      self.event.location = self.location;
      self.event.startDate = self.startDate;
      self.event.endDate = self.endDate;
      self.event.notes = self.notes;
      if ([self checkEventTimesAreValidForStartTime:self.startDate endTime:self.endDate]) {
        [self saveEditedEvent:self.event];
      } else {
        [self eventTimesInvalidAlertView];
      }
    }
  }
}

- (void)savePressed:(id)sender
{
  [self saveObjects];
  
  if (self.name.length==0) {
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Cannot save event"
                                                        message:@"event must have a title"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertview show];
  } else {
    if (!self.startDatePicker && !self.startDate) {
      self.startDate = [NSDate date];
    } else if (self.startDatePicker) {
      self.startDate = self.startDatePicker.date;
    }
    if (!self.endDatePicker && !self.endDate) {
      self.endDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    }
    else if (self.endDatePicker){
      self.endDate = self.endDatePicker.date;
    }
    if (![self checkEventTimesAreValidForStartTime:self.startDate endTime:self.endDate]) {
      [self eventTimesInvalidAlertView];
    } else {
      [self createCalendarEventwithName:self.name
                               location:self.location
                            description:self.notes
                              startDate:self.startDate
                                endDate:self.endDate];
      [self.delegate viewWillBeDismissed];
      [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
  }
}

- (void)deleteButtonPressed:(id)sender
{
  [[[UIAlertView alloc] initWithTitle:@"Delete Confirmation"
                              message:@"Are you sure you want to delete this event?"
                             delegate:self
                    cancelButtonTitle:@"Cancel"
                    otherButtonTitles:@"Ok", nil] show];
}

- (void)saveEditedEvent:(EKEvent *)event
{
  NSError *error;
  [self.localEventStore saveEvent:event
                             span:EKSpanThisEvent
                           commit:YES
                            error:&error];
  [self.delegate viewWillBePopped];
  if (!error) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  else {
    NSLog(@"error %@", error);
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)saveEvent:(EKEvent*)event
{
  NSError *error;
  [self.localEventStore saveEvent:event
                             span:EKSpanThisEvent
                           commit:YES
                            error:&error];
  
  [self.delegate viewWillBePopped];
  
  if (!error) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  else {
    NSLog(@"error %@", error);
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)saveObjects
{
  self.name = self.nameTextView.text;
  self.location = self.locationTextView.text;
  self.notes = self.descTextView.text;
}

- (void)createCalendarEventwithName:(NSString*)name location:(NSString*)location description:(NSString*)notes startDate:(NSDate*)startDate endDate:(NSDate*)endDate
{
  EKEvent *newEvent = [EKEvent eventWithEventStore:self.localEventStore];
  newEvent.title = name;
  newEvent.startDate = self.startDate;
  newEvent.endDate = self.endDate;
  newEvent.timeZone = [NSTimeZone localTimeZone];
  newEvent.location = location;
  newEvent.notes = self.notes;
  newEvent.calendar = [self.localEventStore defaultCalendarForNewEvents];
  [self saveEvent:newEvent];
}

- (void)setupEventStore
{
  self.localEventStore = [EventStore sharedInstance].eventStore;
}

#pragma mark-UIAlertView Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex==1) {
    [self popViewControllerAndDissmissAlertView:alertView AndClickedButtonIndex:buttonIndex WithCompletionHandler:^(NSError *error)
     {
       if (error) {
         NSLog(@"error deleting event:%@", [error description]);
       }
       [self.navigationController popViewControllerAnimated:YES];
     }];
    
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)popViewControllerAndDissmissAlertView:(UIAlertView*)alertView AndClickedButtonIndex:(NSInteger)buttonIndex  WithCompletionHandler:(void (^)(NSError *error))completionHandler
{
  [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
  NSError *error;
  [self.localEventStore removeEvent:self.event
                               span:EKSpanThisEvent
                              error:&error];
  completionHandler(error);
}

-(BOOL)checkEventTimesAreValidForStartTime:(NSDate*)startTime endTime:(NSDate*)endTime
{
  return [NSDate checkIfFirstDate:startTime isSmallerThanSecondDate:endTime];
}

- (void)eventTimesInvalidAlertView
{
  [[[UIAlertView alloc] initWithTitle:@"Error!"
                              message:@"End time cannot be smaller than start time"
                             delegate:self
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil] show];
}

@end
