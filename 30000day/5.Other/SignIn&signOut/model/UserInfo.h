//
//  UserInfo.h
//  30000天
//
//  Created by 30000天_001 on 15/7/29.
//  Copyright (c) 2015年 30000天_001. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic ,copy) NSString *UserID;//用户id

@property (nonatomic ,copy) NSString *LoginName;//账号

@property (nonatomic ,copy) NSString *LoginPassword;//密码

@property (nonatomic ,copy) NSString *SkinName;//***

@property (nonatomic ,copy) NSString *NickName;//昵称

@property (nonatomic ,copy) NSString *Gender;//性别

@property (nonatomic ,copy) NSString *Email;//邮箱

@property (nonatomic ,copy) NSString *Birthday;//出生日期

@property (nonatomic ,copy) NSString *Address;//地址

@property (nonatomic ,copy) NSString *Life;//天龄

@property (nonatomic ,copy) NSString *HeadImg;//头像

@property (nonatomic ,copy) NSString *Name;//真实姓名

@property (nonatomic ,copy) NSString *Age;//年龄

@property (nonatomic ,copy) NSString *RoleID;//角色

@property (nonatomic ,copy) NSString *PhoneNumber;//手机号码

@property (nonatomic ,copy) NSString *RegDate;//注册时间

@property (nonatomic ,copy) NSString *A1;//问题1

@property (nonatomic ,copy) NSString *A2;//问题2

@property (nonatomic ,copy) NSString *A3;//问题3

@property (nonatomic ,copy) NSString *Q1;//答案1

@property (nonatomic ,copy) NSString *Q2;//答案2

@property (nonatomic ,copy) NSString *Q3;//答案3

//@property (nonatomic ,copy) NSString *RegDate;//注册日期
@property (nonatomic ,assign) NSInteger isfirstlog;

@property (nonatomic ,copy)NSArray* friendsArray;

+(UserInfo *)userWithUserInfo:(UserInfo*)user;

@end