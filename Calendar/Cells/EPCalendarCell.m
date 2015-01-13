//
//  EPCalendarCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.

#import "EPCalendarCell.h"
#import "UIColor+EH.h"

@interface EPCalendarCell ()

+ (NSCache *) imageCache;
+ (id) cacheKeyForCalendarDate:(EPCalendarDate)date;
+ (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block;

@property (nonatomic, readonly, strong) UIImageView *imageView;
@property CGFloat width;
@property CGFloat height;

@end

@implementation EPCalendarCell
@synthesize imageView = _imageView;
@synthesize overlayView = _overlayView;
@synthesize dotview = _dotview;

#pragma mark - Layout methods

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor whiteColor];
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  if (!_dotview) {
    _dotview =  [[UIView alloc]initWithFrame:CGRectMake(self.width/2-5, self.height-10, 10, 10)];
    _dotview.layer.cornerRadius = 5;
    _dotview.clipsToBounds = YES;
    _dotview.backgroundColor = [UIColor primaryColor];
    [self.contentView addSubview:_dotview];
    _dotview.hidden = YES;
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.backgroundColor = [UIColor whiteColor];
  self.imageView.image = [[self class] fetchObjectForKey:[[self class] cacheKeyForCalendarDate:self.date] withCreator:^{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    CGRect textBounds = (CGRect){ 0.0f, self.height/2-12, self.width, 24.0f };
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByCharWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    [[NSString stringWithFormat:@"%lu", (unsigned long) self.date.day] drawInRect:textBounds withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle}];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
  }];
  self.imageView.alpha = self.enabled ? 1.0f : 0.0f;
  self.overlayView.hidden = !(self.selected && self.enabled) ;
  self.dotview.hidden = !self.hasEvents;
}

- (void)refreshDotViews
{
  self.dotview.hidden = !self.hasEvents;
}

- (UIView *)overlayView
{
  if (!_overlayView) {
    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(self.width/2-13, self.height/2-13, 26, 26)];
    _overlayView.layer.cornerRadius = _overlayView.bounds.size.width/2;
    _overlayView.clipsToBounds = YES;
    _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _overlayView.backgroundColor = [UIColor blackColor];
    _overlayView.alpha = 0.25f;
    [self.contentView addSubview:_overlayView];
  }
  return _overlayView;
}

- (UIImageView *)imageView
{
  if (!_imageView) {
    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _imageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_imageView];
  }
  return _imageView;
}

- (void)setDate:(EPCalendarDate)date
{
  _date = date;
  [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled
{
  _enabled = enabled;
  [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
  [super setHighlighted:highlighted];
  [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected
{
  [super setSelected:selected];
  [self setNeedsLayout];
}

#pragma mark - Image Cache

+ (NSCache *)imageCache
{
  static NSCache *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [NSCache new];
  });
  return cache;
}

+ (id)cacheKeyForCalendarDate:(EPCalendarDate)date
{
  return @(date.day);
}

+ (id)fetchObjectForKey:(id)key withCreator:(id(^)(void))block
{
  id answer = [[self imageCache] objectForKey:key];
  if (!answer) {
    answer = block();
    [[self imageCache] setObject:answer forKey:key];
  }
  return answer;
}

@end
