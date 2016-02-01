//
//  LODataHandler.h
//  LianjiaOnlineApp
//
//  Created by GuoJia on 15/12/10.
//  Copyright © 2015年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LONetError;

@class STBaseViewController;

@interface LODataHandler : NSObject

@property (nonatomic, weak) STBaseViewController *delegate;

//***** 发送验证请求 *****/
- (NSString *)postLoginVerifyCode:(NSString *)code
                      phoneNumber:(NSString *)phonenumber
                          picCode:(NSString *)piccode
                          success:(void (^)(id responseObject))success
                          failure:(void (^)(LONetError *))failure;
//***** 普通登录 *****/
- (NSString *)postLoginWithPassword:(NSString *)password
                        phoneNumber:(NSString *)phonenumber
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(LONetError *))failure;
//***** 用户注册 *****/
- (NSString *)postRegesiterWithPassword:(NSString *)password
                            phoneNumber:(NSString *)phonenumber
                                picCode:(NSString *)piccode
                             verifyCode:(NSString *)verifycode
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(LONetError *))failure;
//***** 忘记密码 *****/
- (NSString *)postChangePasswordWithPassword:(NSString *)password
                            phoneNumber:(NSString *)phonenumber
                             verifyCode:(NSString *)verifycode
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(LONetError *))failure;
//***** 忘记密码 *****/
- (NSString *)getRecordCountIfSuccess:(void (^)(id responseObject))success
                                     failure:(void (^)(LONetError *))failure;


@end