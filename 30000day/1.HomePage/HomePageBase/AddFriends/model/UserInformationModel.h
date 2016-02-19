//
//  SearchUserInformationModel.h
//  30000day
//  当前用户、当前用户的好友、搜索到的用户模型
//  Created by GuoJia on 16/2/19.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInformationModel : NSObject

@property (nonatomic,strong) NSNumber *gender;

@property (nonatomic,strong) NSNumber *userId;

@property (nonatomic,strong) NSNumber *age;

@property (nonatomic,strong) NSNumber *chglife;//今天改变的的 0:不改变 正数:增加的 负数:减少的

@property (nonatomic,strong) NSNumber *totalLife;

@property (nonatomic,copy) NSString *nickName;

@property (nonatomic,copy) NSString *headImg;

@property (nonatomic,strong) NSNumber *lifed;//已经过去的天龄

@end