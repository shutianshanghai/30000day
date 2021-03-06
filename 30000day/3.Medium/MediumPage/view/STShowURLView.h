//
//  STShowURLView.h
//  30000day
//
//  Created by GuoJia on 16/9/20.
//  Copyright © 2016年 GuoJia. All rights reserved.
//  显示链接（标题、图片、副标题）【如果副标题为空的话，那么显示附表的label会被隐藏，主标题的label剧中】

#import <UIKit/UIKit.h>
@class STShowURLModel;

@interface STShowURLView : UIView

- (void)showURLViewWithShowURLModel:(STShowURLModel *)showURLModel;
+ (CGFloat)heighOfShowURLView:(STShowURLModel *)showURLModel;
@property (nonatomic,copy) void (^tapBlock)(STShowURLModel *showURLModel);

@end

@interface STShowURLModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *imageURLString;//显示图片地址
@property (nonatomic,copy) NSString *URLString;//链接地址
@property (nonatomic,copy) NSString *subTitle;//新加的，副标题

@end
