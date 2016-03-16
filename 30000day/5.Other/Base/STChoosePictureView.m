//
//  STChoosePictureView.m
//  30000day
//
//  Created by GuoJia on 16/3/15.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "STChoosePictureView.h"
#import "AppointmentCollectionViewCell.h"

@interface STChoosePictureCollectionCell : UICollectionViewCell

@property (nonatomic,strong)NSIndexPath *indexPath;

@property (nonatomic,copy) void (^buttonClickBlock)(NSIndexPath *indexPath);

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UIButton *button;

@end

@implementation STChoosePictureCollectionCell

- (void)drawRect:(CGRect)rect {
    
    [self configUI];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)configUI {
    
    for (UIView *view in self.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]] || [view isKindOfClass:[UIButton class]] ) {
            
            [view removeFromSuperview];
        }
    }
    //1.设置imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    self.imageView.backgroundColor = [UIColor orangeColor];
    
    self.imageView = imageView;
    
    [self addSubview:imageView];
    
    //2.button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(self.width - 21, 5 , 20, 20);
    
    button.layer.cornerRadius = 10;
    
    button.layer.masksToBounds = YES;
    
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    button.layer.borderWidth = 1.0f;
    
    [button setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.button = button;
    
    [self addSubview:button];
}

- (void)cancelButtonAction {
    
    if (self.buttonClickBlock) {
        
        self.buttonClickBlock(self.indexPath);
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.imageView.backgroundColor = [UIColor whiteColor];
    
    self.layer.cornerRadius = 5;
    
    self.layer.masksToBounds = YES;
}

@end

@interface STChoosePictureView () <UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation STChoosePictureView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self configUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self configUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(5,5,self.width - 10,self.height - 10);
}

- (void)configUI {
    
    for (UIView *view in self.subviews) {
        
        if ([view isKindOfClass:[UICollectionView class]]) {
            
            [view removeFromSuperview];
        }
    }
    
    //1.设置FlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 0;
    
    layout.minimumLineSpacing = 0;
    
    layout.itemSize = CGSizeMake(60,60);
    
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    layout.headerReferenceSize = CGSizeMake(0.5f, 0.5f);
    
    layout.footerReferenceSize = CGSizeMake(0.5f, 0.5f);
    
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //2.设置表格视图
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5,5,self.width - 10,self.height - 10) collectionViewLayout:layout];
    
    [collectionView setCollectionViewLayout:layout animated:YES];
    
    collectionView.backgroundColor = [UIColor redColor];
    
    [collectionView registerClass:[STChoosePictureCollectionCell class] forCellWithReuseIdentifier:@"STChoosePictureCollectionCell"];
    
    collectionView.delegate = self;
    
    collectionView.dataSource = self;
    
    collectionView.backgroundColor = [UIColor whiteColor];
    
    collectionView.showsHorizontalScrollIndicator = YES;
    
    self.collectionView = collectionView;
    
    [self addSubview:collectionView];
}

#pragma ---
#pragma mark --- UICollectionViewDataSource/UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.imageArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STChoosePictureCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STChoosePictureCollectionCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[STChoosePictureCollectionCell alloc] init];
    }
    
    cell.imageView.image = self.imageArray[indexPath.section];
    
    cell.indexPath = indexPath;
    
    //删除按钮点击回调
    [cell setButtonClickBlock:^(NSIndexPath *indexPath) {
        
        if (self.imageArray.count > indexPath.section ) {
            
            if ([self.delegate respondsToSelector:@selector(choosePictureView:cancelButtonDidClickAtIndex:)]) {
                
                [self.delegate choosePictureView:self cancelButtonDidClickAtIndex:indexPath.section];

            }
        }
    }];
    
    return cell;
}

- (void)setImageArray:(NSMutableArray *)imageArray {
    
    _imageArray = imageArray;
    
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(choosePictureView:didClickCellAtIndex:)]) {
        
        [self.delegate choosePictureView:self didClickCellAtIndex:indexPath.section];
        
    }
}

@end