//
//  DaysOfAgeOption.m
//  30000day
//
//  Created by wei on 16/5/9.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "DaysOfAgeOption.h"

#define CELLHEIGHT ((SCREEN_HEIGHT - 188) / 2.0f) / 2;

@implementation DaysOfAgeOption

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *perfectImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(perfectImageViewTapAction:)];
    [self.perfectImageView addGestureRecognizer:perfectImageViewTap];
    
    UITapGestureRecognizer *promoteImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoteImageViewTapAction:)];
    [self.promoteImageView addGestureRecognizer:promoteImageViewTap];
    self.imageHeight.constant = CELLHEIGHT;
}

- (void)perfectImageViewTapAction:(UITapGestureRecognizer *)tap {
    
    if (self.shareButtonBlock) {
        
        self.shareButtonBlock(1,self);
        
    }
    
}

- (void)promoteImageViewTapAction:(UITapGestureRecognizer *)tap {
    
    if (self.shareButtonBlock) {
        
        self.shareButtonBlock(2,self);
        
    }
    
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    [self annimateRemoveFromSuperView];

}


- (void)annimateRemoveFromSuperView {
    
    self.oneLeft.constant = -100;
    
    self.twoRight.constant = -100;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
}

- (void)animateWindowsAddSubView {
    
    CGFloat x = (SCREEN_WIDTH - 200) / 3;
    
    CGFloat y = CELLHEIGHT;
    
    [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self.perfectImageView setFrame:CGRectMake(x, SCREEN_HEIGHT - y, 100, 100)];
    
    [self.promoteImageView setFrame:CGRectMake(SCREEN_WIDTH - x - 100, SCREEN_HEIGHT - y, 100, 100)];
    
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
    
    self.oneLeft.constant = x;
    
    self.twoRight.constant = x;
  
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        [self layoutIfNeeded];
        
    } completion:nil];
    
}


@end
