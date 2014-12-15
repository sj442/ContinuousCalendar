//
//  EPCalendarWeekCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/11/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

//
//  EPCalendarCell.m
//  Calendar
//
//  Created by Sunayna Jain on 12/4/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPCalendarWeekCell.h"
#import "UIColor+EH.h"


@interface EPCalendarWeekCell ()

+ (NSCache *) imageCache;
+ (id) cacheKeyForCalendarDate:(EPCalendarDate)date;
+ (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block;


@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIView *dotview;

@end

@implementation EPCalendarWeekCell
@synthesize imageView = _imageView;
@synthesize overlayView = _overlayView;
@synthesize dotview = _dotview;

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void) setDate:(EPCalendarDate)date {
    _date = date;
    [self setNeedsLayout];
}

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsLayout];
}
- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.image = [[self class] fetchObjectForKey:[[self class] cacheKeyForCalendarDate:self.date] withCreator:^{
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.window.screen.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        
        CGContextFillRect(context, self.bounds);
        
        UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
        CGRect textBounds = (CGRect){ 0.0f, 10.0f, 44.0f, 24.0f };
        
        if (!self.isSelected) {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        } else {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        }
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByCharWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        
        [[NSString stringWithFormat:@"%lu", (unsigned long) self.date.day] drawInRect:textBounds withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle}];
    
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }];
    self.overlayView.hidden = !(self.selected || self.highlighted) ;
    self.dotview.hidden = !self.hasEvents;
}

- (UIView *)dotview
{
    if (!_dotview) {
        _dotview =  [[UIView alloc]initWithFrame:CGRectMake(17, 40, 10, 10)];
        _dotview.layer.cornerRadius = 5;
        _dotview.clipsToBounds = YES;
        _dotview.backgroundColor = [UIColor primaryColor];
        [self.contentView addSubview:_dotview];
    }
    return _dotview;
}

- (UIView *) overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
        _overlayView.layer.cornerRadius = _overlayView.bounds.size.width/2;
        _overlayView.clipsToBounds = YES;
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor blackColor];
        _overlayView.alpha = 0.25f;
        [self.contentView addSubview:_overlayView];
    }
    return _overlayView;
}

- (UIImageView *) imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

+ (NSCache *) imageCache {
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });
    return cache;
}

+ (id) cacheKeyForCalendarDate:(EPCalendarDate)date {
    return @(date.day);
}

+ (id) fetchObjectForKey:(id)key withCreator:(id(^)(void))block {
    id answer = [[self imageCache] objectForKey:key];
    if (!answer) {
        answer = block();
        [[self imageCache] setObject:answer forKey:key];
    }
    return answer;
}


@end

