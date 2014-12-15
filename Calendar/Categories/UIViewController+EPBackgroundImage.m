//
//  UIViewController+EPBackgroundImage.m
//  CRMStar
//
//  Created by Edward Paulosky on 11/8/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "UIViewController+EPBackgroundImage.h"

@implementation UIViewController (EPBackgroundImage)

- (void)addBackgroundImage
{
    UIImageView *backgroundImageView = [UIImageView new];
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame);
    backgroundImageView.frame = frame;
    backgroundImageView.image = [UIImage imageNamed:@"conquerbackground.jpg"];
    
    if ([self.view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.view;
        tableView.backgroundColor = [UIColor clearColor];
        UIView *view = [UIView new];
        view.frame = tableView.frame;
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:backgroundImageView];
        tableView.backgroundView = view;
    } else {
        [self.view insertSubview:backgroundImageView atIndex:0];
    }
}

- (void)addBackgroundImageWithY:(CGFloat)y
{
    UIImageView *backgroundImageView = [UIImageView new];
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = y;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationController.navigationBar.frame);
    backgroundImageView.frame = frame;
    backgroundImageView.image = [UIImage imageNamed:@"conquerbackground.jpg"];
    
    if ([self.view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.view;
        tableView.backgroundColor = [UIColor clearColor];
        UIView *view = [UIView new];
        view.frame = tableView.frame;
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:backgroundImageView];
        tableView.backgroundView = view;
    } else {
        [self.view insertSubview:backgroundImageView atIndex:0];
    }
}

@end
