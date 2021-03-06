//
//  XHEmotionSectionBar.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionSectionBar.h"

#define kXHStoreManagerItemWidth 50
#define kXHEmotionStoreButtonMargin 10

@interface XHEmotionSectionBar ()

/**
 *  是否显示表情商店的按钮
 */
@property (nonatomic, assign) BOOL isShowEmotionStoreButton; // default is YES

@property (nonatomic, weak) UIScrollView *sectionBarScrollView;

@property (nonatomic, weak) UIButton *storeManagerItemButton;

@property (nonatomic, strong) UIButton *selectionButton;

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation XHEmotionSectionBar

- (void)sectionButtonClicked:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didSelecteEmotionManager:atSection:)]) {
        
        NSInteger section = sender.tag;
        
        if (section < self.emotionManagers.count) {
            
            [self.delegate didSelecteEmotionManager:[self.emotionManagers objectAtIndex:section] atSection:section];
            
        }
    }
    
    [self changeButtonBackgroundColorWithSelectionButton:sender];
}

- (void)changeButtonBackgroundColorWithSelectionButton:(UIButton *)selectionButton {
    
    for (UIButton *button in self.buttonArray) {
        
        if (button.tag == selectionButton.tag) {
            
            button.backgroundColor = RGBACOLOR(230, 230, 230, 1);
            
        } else {
            
            button.backgroundColor = RGBACOLOR(247, 247, 247, 1);
        }
    }
}

- (void)storeButtonClicked:(UIButton*)sender{
    if([self.delegate respondsToSelector:@selector(didSelectEmotionStoreButton:)]){
        [self.delegate didSelectEmotionStoreButton:sender];
    }
}

- (UIButton *)createdButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, kXHStoreManagerItemWidth, CGRectGetHeight(self.bounds));
    [button addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor colorWithRed:73.f/255 green:124.f/255 blue:200.f/255 alpha:1] forState:UIControlStateNormal];
    return button;
}

- (void)reloadData {
    if (!self.emotionManagers.count)
        return;
    
    [self.sectionBarScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.buttonArray = [[NSMutableArray alloc] init];
    
    for (XHEmotionManager *emotionManager in self.emotionManagers) {
        
        NSInteger index = [self.emotionManagers indexOfObject:emotionManager];
        
        UIButton *sectionButton = [self createdButton];
        
        sectionButton.tag = index;
        
//        [sectionButton setTitle:emotionManager.emotionName forState:UIControlStateNormal];
        
        [sectionButton setImage:[[UIImage imageNamed:emotionManager.emotionBottomButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        
        sectionButton.imageEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12);

//        sectionButton.titleLabel.font = [UIFont systemFontOfSize:14];
        
        CGRect sectionButtonFrame = sectionButton.frame;
        
        sectionButtonFrame.origin.x = index * (CGRectGetWidth(sectionButtonFrame));
        
        sectionButton.frame = sectionButtonFrame;
        
        [self.buttonArray addObject:sectionButton];
        
        [self.sectionBarScrollView addSubview:sectionButton];
    }
    //配置第一个按钮
    [self changeButtonBackgroundColorWithSelectionButton:[self.buttonArray firstObject]];
    
    [self.sectionBarScrollView setContentSize:CGSizeMake(self.emotionManagers.count * kXHStoreManagerItemWidth, CGRectGetHeight(self.bounds))];
}

#pragma mark - Lefy cycle

- (void)setup {
    if (!_sectionBarScrollView) {
        CGFloat scrollWidth = CGRectGetWidth(self.bounds);
        if (self.isShowEmotionStoreButton) {
            scrollWidth -= kXHStoreManagerItemWidth;
        }
        UIScrollView *sectionBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, CGRectGetHeight(self.bounds))];
        [sectionBarScrollView setScrollsToTop:NO];
        sectionBarScrollView.showsVerticalScrollIndicator = NO;
        sectionBarScrollView.showsHorizontalScrollIndicator = NO;
        sectionBarScrollView.pagingEnabled = NO;
        [self addSubview:sectionBarScrollView];
        _sectionBarScrollView = sectionBarScrollView;
    }
    
    if (self.isShowEmotionStoreButton) {
        UIButton *storeManagerItemButton = [self createdButton];
        
        CGRect storeManagerItemButtonFrame = storeManagerItemButton.frame;
        
        storeManagerItemButtonFrame.origin.x = CGRectGetWidth(self.bounds) - kXHStoreManagerItemWidth;
        
        storeManagerItemButton.frame = storeManagerItemButtonFrame;
        
        storeManagerItemButton.backgroundColor = RGBACOLOR(83, 128, 196, 1);
        
        [storeManagerItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [storeManagerItemButton setTitle:@"发送" forState:UIControlStateNormal];
        
        [storeManagerItemButton addTarget:self action:@selector(storeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:storeManagerItemButton];
        
        _storeManagerItemButton = storeManagerItemButton;
    }
}

- (instancetype)initWithFrame:(CGRect)frame showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isShowEmotionStoreButton = isShowEmotionStoreButtoned;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotionManagers = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
