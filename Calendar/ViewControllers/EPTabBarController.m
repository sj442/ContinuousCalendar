//
//  EPTabBarController.m
//  Calendar
//
//  Created by Sunayna Jain on 1/7/15.
//  Copyright (c) 2015 Enhatch. All rights reserved.
//

#import "EPTabBarController.h"
#import "EPCalendarViewController.h"

@interface EPTabBarController ()

@end

@implementation EPTabBarController

- (void)viewDidLoad
{
  [super viewDidLoad];
  EPCalendarViewController *vc = [[EPCalendarViewController alloc]init];
  UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:vc];
  UITabBarItem *calendar = [[UITabBarItem alloc]initWithTitle:@"Calendar" image:nil selectedImage:nil];
  navC.tabBarItem = calendar;
  self.viewControllers = @[navC];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

@end
