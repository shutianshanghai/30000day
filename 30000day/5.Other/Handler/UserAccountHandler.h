//
//  UserAccountHandler.h
//  30000day
//  处理用户账号相关的模型
//  Created by GuoJia on 16/2/2.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

//extern NSString *const UserAccountHandlerUseProfileDidChangeNotification;

@interface UserAccountHandler : NSObject

@property (nonatomic ,strong, readonly) UserInfo *userInfo;//保存在处理器里面的用户信息

@property (nonatomic ,strong ,readonly) NSMutableArray *lastUserAccountArray;//之前保存用户登录的账号和密码

+ (UserAccountHandler *)shareUserAccountHandler;

//获取用户的各种信息(注意:该用户之前登录过才能获取数据)
- (void)getUserInfo;

/**
 *   保存用户上次登录的账号
 *   同时也会更新用户信息
 **/
- (void)saveUserAccountWithModel:(UserInfo *)userProfile;

//退出登录
- (void)logout;


@end