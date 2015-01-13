//
//  EPCalendarCollectionViewController.h
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPCreateEventTableViewController.h"
#import "EPTwoWeekCollectionViewController.h"
#import "EPCollectionViewController.h"

@interface EPCalendarViewController : UIViewController <EPCollectionViewControllerDelegate, EPTwoWeekCollectionViewControllerDelegate>

@end
