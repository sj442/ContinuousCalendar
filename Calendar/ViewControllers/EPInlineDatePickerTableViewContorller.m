//
//  inlineDatePickerTVC.m
//  inlineDatePickerTVC
//
//  Created by Sunayna Jain on 6/13/14.
//  Copyright (c) 2014 LittleAuk. All rights reserved.

#import "EPInlineDatePickerTableViewController.h"
#import "EPDatePickerCell.h"
#import "EPTextViewCell.h"
#import "NSDate+Description.h"
#import "UIColor+EH.h"
#import "NSString+EH.h"
#import "EPTextViewWithPlaceholder.h"
#import "UIViewController+EPBackgroundImage.h"

static NSString *EPInlineDatePickerTableViewControllerContactPlaceHolderString = @"Contact";

@interface EPInlineDatePickerTableViewController ()

@property (weak, nonatomic) UIButton *deleteButton;
@property (nonatomic) NSInteger startDatePickerIndex;
@property (nonatomic) NSInteger endDatePickerIndex;
@property (nonatomic) NSInteger startTimeIndex;
@property (nonatomic) NSInteger endTimeIndex;
@property (nonatomic) NSInteger rows;
@property (nonatomic) CGFloat totalViewHeight;

@end

@implementation EPInlineDatePickerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView registerNib:[EPDatePickerCell nib] forCellReuseIdentifier:EPDatePickerCellIdentifier];
  [self.tableView registerNib:[EPTextViewCell nib] forCellReuseIdentifier:EPTextViewCellIdentifier];
  self.rows=2;
  self.startTimeIndex = 0;
  self.endTimeIndex = 1;
  self.startDatePickerIndex = 100;
  self.endDatePickerIndex = 100;
  
  if (!self.startDate) {
    self.startDate = [NSDate date];
  }
  
  if (!self.endDate) {
    self.endDate = [NSDate dateWithTimeInterval:3600 sinceDate:self.startDate];
  }
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenHeight = screenRect.size.height;
  if (screenHeight==568) {
    self.totalViewHeight = 568;
  }
  else {
    self.totalViewHeight = 480;
  }
  [self addBackgroundImageWithY:64];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (self.eventSelected && self.editMode) {
    return 4;
  }
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section==1) {
    return self.rows;
  }
  else if (section==0) {
    return 3;
  }
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if(section<3) {
    return 36;
  }
  return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *headerView;
  if (section<3) {
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 36)];
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,0, 160, headerView.frame.size.height)];
    headerView.backgroundColor = [UIColor primaryColor];
    headerLabel.text = self.sectionTitlesArray[section];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont systemFontOfSize:17];
    [headerView addSubview:headerLabel];
  }
  headerView.alpha = 0.95;
  return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat nameRowHeight=50;
  CGFloat locationRowHeight=50;
  if (indexPath.section==0) {
    
    if (indexPath.row==0 && self.eventSelected && self.name) {
      nameRowHeight= [self.name heightForTextHavingWidth:[EPTextViewCell textViewWidth] font:[UIFont systemFontOfSize:16]] +15+15;
      return nameRowHeight;
    } else if (indexPath.row==1 && self.eventSelected && self.location) {
      locationRowHeight = [self.location heightForTextHavingWidth:[EPTextViewCell textViewWidth] font:[UIFont systemFontOfSize:16]]+15+15;
      return locationRowHeight;
    } else {
      return 50;
    }
  }
  
  if (indexPath.section==1) {
    if (indexPath.row==self.startDatePickerIndex || indexPath.row==self.endDatePickerIndex) {
      return 200;
    }
    else {
      return 50;
    }
  }
  else if (indexPath.section==2) {
    if (self.eventSelected && self.editMode) {
      return MAX(100,self.totalViewHeight-200-nameRowHeight-locationRowHeight-36*3-64);
    }
    else {
      CGFloat descriptionHeight = [self.notes heightForTextHavingWidth:[EPTextViewCell textViewWidth]-20.0 font:[UIFont systemFontOfSize:16]]+40;
      return MAX(100, descriptionHeight);
    }
  }
  return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch (indexPath.section) {
    case 0:
    {
      if (indexPath.row==0) {
        EPTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EPTextViewCellIdentifier];
        [cell configureCellWithText:self.name andPlaceHolder:@"Name"];
        cell.textView.delegate = self;
        self.nameTextView = cell.textView;
        if (self.eventSelected && !self.editMode) {
          self.nameTextView.editable = NO;
        } else {
          self.nameTextView.editable = YES;
        }
        [self setCellAlpha:cell];
        return cell;
      } else if (indexPath.row==1){
        EPTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EPTextViewCellIdentifier];
        [cell configureCellWithText:self.location andPlaceHolder:@"Location"];
        cell.textView.delegate = self;
        self.locationTextView= cell.textView;
        if (self.eventSelected==1 && !self.editMode) {
          self.locationTextView.editable = NO;
        } else {
          self.locationTextView.editable = YES;
        }
        [self setCellAlpha:cell];
        return cell;
      } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"contactCell"];
        if (!cell) {
          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contactCell"];
        }
        [self configureContactCell:cell];
        [self setCellAlpha:cell];
        return cell;
      }
    }
      break;
    case 1:
    {
      EPDatePickerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EPDatePickerCellIdentifier];
      cell.tag = indexPath.row;
      [self configureDatePickerCell:cell];
      [self setCellAlpha:cell];
      return cell;
      break;
    }
    case 2:
    {
      EPTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EPTextViewCellIdentifier];
      [cell configureCellWithText:self.notes andPlaceHolder:@"Notes"];
      cell.textView.delegate = self;
      self.descTextView = cell.textView;
      if (self.eventSelected && !self.editMode) {
        self.descTextView.editable = NO;
        self.descTextView.userInteractionEnabled = NO;
      } else {
        self.descTextView.userInteractionEnabled = YES;
        self.descTextView.editable = YES;
        self.descTextView.scrollEnabled = YES;
      }
      [self setCellAlpha:cell];
      return cell;
      break;
    }
    default:
    {
      static NSString *cellIdentifier = @"deleteCell";
      UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
      if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      }
      [self configureDeleteCell:cell];
      [self setCellAlpha:cell];
      return cell;
      break;
    }
  }
}

- (void)setCellAlpha:(UITableViewCell *)cell
{
  cell.backgroundColor = [UIColor clearColor];
  cell.contentView.backgroundColor = [UIColor whiteColor];
  cell.contentView.alpha = 0.9;
}

- (void)configureContactCell:(UITableViewCell*)cell
{
}

- (void)configureDeleteCell:(UITableViewCell*)cell
{
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
  [button setTitle:@"Delete Event" forState:UIControlStateNormal];
  [button addTarget:self
             action:@selector(deleteButtonPressed:)
   forControlEvents:UIControlEventTouchUpInside];
  [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
  [cell addSubview:button];
  self.deleteButton = button;
}

- (void)configureDatePickerCell:(EPDatePickerCell*)cell
{
  if (cell.tag== self.startTimeIndex) {
    cell.startLabel.text = @"Start Time";
    cell.textLabel.textColor = [UIColor blackColor];
    cell.timeLabel.text = [self.startDate formattedString];
    
  } else if (cell.tag == self.endTimeIndex) {
    cell.startLabel.text = @"End Time";
    cell.textLabel.textColor = [UIColor blackColor];
    cell.timeLabel.text = [self.endDate formattedString];
    
  } else if (cell.tag == self.startDatePickerIndex) {
    [self createStartDatePickerForCell:cell];
    
  } else if (cell.tag == self.endDatePickerIndex) {
    [self createEndDatePickerForCell:cell];
  }
}

- (void)deleteButtonPressed:(id)sender
{
  //implemented in subclass
}

#pragma mark-datepicker methods

- (void)createStartDatePickerForCell:(UITableViewCell*)cell
{
  NSArray *subviews = [cell.contentView subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  if (cell.tag == self.startDatePickerIndex) {
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [datePicker addTarget:self action:@selector(startDatePicked:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDate:self.startDate];
    [cell.contentView addSubview:datePicker];
    self.startDatePicker = datePicker;
  }
}

- (void)createEndDatePickerForCell:(UITableViewCell*)cell
{
  NSArray *subviews = [cell.contentView subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  if (cell.tag == self.endDatePickerIndex) {
    UIDatePicker *datePicker  = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [datePicker addTarget:self action:@selector(endDatePicked:) forControlEvents:UIControlEventValueChanged];
    [datePicker setDate:self.endDate];
    [cell.contentView addSubview:datePicker];
    self.endDatePicker = datePicker;
  }
}

- (void)startDatePicked:(id)sender
{
  self.startDate = self.startDatePicker.date;
  NSIndexPath *ip = [NSIndexPath indexPathForRow:self.startDatePickerIndex inSection:1];
  EPDatePickerCell *cell = ((EPDatePickerCell*) [self.tableView cellForRowAtIndexPath:ip]);
  cell.timeLabel.text = [self.startDate formattedString];
  [self.tableView reloadData];
}

- (void)endDatePicked:(id)sender
{
  self.endDate = self.endDatePicker.date;
  NSIndexPath *ip = [NSIndexPath indexPathForRow:self.endDatePickerIndex inSection:1];
  EPDatePickerCell *cell = ((EPDatePickerCell*) [self.tableView cellForRowAtIndexPath:ip]);
  cell.timeLabel.text = [self.endDate formattedString];
  [self.tableView reloadData];
}

- (void)showStartDatePicker
{
  self.startDatePickerIndex = self.startTimeIndex+1;
  self.endTimeIndex = self.endTimeIndex+1;
  NSIndexPath *startDatePickerIP = [NSIndexPath indexPathForRow:self.startDatePickerIndex inSection:1];
  [self.tableView insertRowsAtIndexPaths:@[startDatePickerIP] withRowAnimation:UITableViewRowAnimationFade];
  [self.descTextView resignFirstResponder];
  [self.locationTextView resignFirstResponder];
  [self.nameTextView resignFirstResponder];
  self.rows++;
}

- (void)hideStartDatePicker
{
  NSIndexPath *deleteStartDatePickerIP = [NSIndexPath indexPathForRow:self.startDatePickerIndex inSection:1];
  [self.tableView deleteRowsAtIndexPaths:@[deleteStartDatePickerIP] withRowAnimation:UITableViewRowAnimationFade];
  self.endTimeIndex--;
  self.rows--;
  self.startDatePickerIndex=100;
}

- (void)showEndDatePicker
{
  self.endDatePickerIndex = self.endTimeIndex+1;
  NSIndexPath *endDatePickerIP = [NSIndexPath indexPathForRow:self.endDatePickerIndex inSection:1];
  [self.tableView insertRowsAtIndexPaths:@[endDatePickerIP] withRowAnimation:UITableViewRowAnimationFade];
  [self.descTextView resignFirstResponder];
  [self.locationTextView resignFirstResponder];
  [self.nameTextView resignFirstResponder];
  self.rows++;
}

- (void)hideEndDatePicker
{
  NSIndexPath *deleteEndDatePickerIP = [NSIndexPath indexPathForRow:self.endDatePickerIndex inSection:1];
  [self.tableView deleteRowsAtIndexPaths:@[deleteEndDatePickerIP] withRowAnimation:UITableViewRowAnimationFade];
  self.rows--;
  self.endDatePickerIndex = 100;
}

- (BOOL)checkEventTimesAreValidForStartTime:(NSDate*)startTime andEndTime:(NSDate*)endTime
{
  return [NSDate checkIfFirstDate:startTime isSmallerThanSecondDate:endTime];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.eventSelected && self.editMode==NO) {
    
    //disable selection of rows when event has been selected but editing not enabled
    
  } else if (indexPath.section == 1) {
    [self.tableView beginUpdates];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.tag = indexPath.row;
    if (selectedCell.tag == self.endTimeIndex && self.startDatePickerIndex!=100) {
      [self hideStartDatePicker];
      [self showEndDatePicker];
    } else if (selectedCell.tag == self.startTimeIndex && self.endDatePickerIndex !=100) {
      [self hideEndDatePicker];
      [self showStartDatePicker];
    } else if (selectedCell.tag == self.startTimeIndex) {
      if (self.startDatePickerIndex !=100) {
        [self hideStartDatePicker];
      } else {
        [self showStartDatePicker];
      }
    } else if (selectedCell.tag == self.endTimeIndex) {
      if (self.endDatePickerIndex !=100) {
        [self hideEndDatePicker];
      } else {
        [self showEndDatePicker];
      }
    }
    [self.tableView endUpdates];
  } else if (indexPath.section==0 && indexPath.row==2) {
      }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if (textView==self.nameTextView || textView==self.locationTextView) {
    if([text isEqualToString:@"\n"]) {
      [textView resignFirstResponder];
      return NO;
    }
  }
  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
  if (textView==self.nameTextView || textView==self.locationTextView) {
    if (self.startDatePickerIndex!=100) {
      [self.tableView beginUpdates];
      [self hideStartDatePicker];
      [self.tableView endUpdates];
    }
    if (self.endDatePickerIndex!=100) {
      [self.tableView beginUpdates];
      [self hideEndDatePicker];
      [self.tableView endUpdates];
    }
  }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
  if (textView==self.descTextView) {
    self.notes = self.descTextView.text;
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView //when desc textView editing begins, the tableview acrolls up first, then collapse the datepicker
{
  if (self.startDatePickerIndex!=100) {
    [self.tableView beginUpdates];
    [self hideStartDatePicker];
    [self.tableView endUpdates];
  }
  if (self.endDatePickerIndex!=100) {
    [self.tableView beginUpdates];
    [self hideEndDatePicker];
    [self.tableView endUpdates];
  }
}

@end
