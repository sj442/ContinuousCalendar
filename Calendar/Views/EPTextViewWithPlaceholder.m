//
//  TextViewWithPlaceholder.m
//  CRMStar
//
//  Created by Sunayna Jain on 7/7/14.
//  Copyright (c) 2014 Enhatch. All rights reserved.
//

#import "EPTextViewWithPlaceholder.h"

@interface EPTextViewWithPlaceholder ()

@property (weak, nonatomic) UILabel *placeholderLabel;

@end

@implementation EPTextViewWithPlaceholder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpTextView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpTextView];
    }
    return self;
}

- (void)setUpTextView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    [self addPlaceholderLabelToTextView];
}

- (void)addPlaceholderLabelToTextView
{
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
    CGRect frame = placeholderLabel.frame;
    frame.origin.x = 4;
    frame.origin.y = 6;
    placeholderLabel.frame = frame;
    placeholderLabel.userInteractionEnabled = NO;
    placeholderLabel.font = [UIFont systemFontOfSize:16];
    placeholderLabel.textColor = [UIColor colorWithWhite: 0.80 alpha:1];
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel = placeholderLabel;
    [self addSubview:placeholderLabel];
}

- (void)textDidChange:(NSNotification *)notification
{
    if ([self.text length] ==0 || [self.text isEqualToString:@"\n"]) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

# pragma mark - Public Methods

- (void)setPlaceholderText:(NSString *)text
{
    self.placeholderLabel.text = text;
    [self.placeholderLabel sizeToFit];
}

-(void)setPlaceHolderLabelHidden:(BOOL)hidden
{
    self.placeholderLabel.hidden = hidden;
}

@end
