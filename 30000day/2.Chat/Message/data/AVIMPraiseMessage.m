//
//  AVIMPraiseMessage.m
//  30000day
//
//  Created by GuoJia on 16/9/27.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "AVIMPraiseMessage.h"

@implementation AVIMPraiseMessage

+ (void)load {
    [self registerSubclass];
}

/*!
 子类实现此方法用于返回该类对应的消息类型
 @return 消息类型
 */
+ (AVIMMessageMediaType)classMediaType {
    return AVIMMessageMediaPraise;
}

@end
