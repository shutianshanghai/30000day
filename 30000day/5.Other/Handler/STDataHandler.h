//
//  LODataHandler.h
//  30000day
//
//  Created by GuoJia on 15/12/10.
//  Copyright © 2015年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopDetailModel.h"
#import "CompanyModel.h"
#import <CoreLocation/CoreLocation.h>
#import "InformationDetailModel.h"
#import "InformationWriterModel.h"
#import "InformationMySubscribeModel.h"

//当前用户成功添加好友发出的通知
static NSString *const STUserAddFriendsSuccessPostNotification = @"STUserAddFriendsSuccessPostNotification";

//当前用户个人信息改变发出通知
static NSString *const STUserAccountHandlerUseProfileDidChangeNotification = @"STUserAccountHandlerUseProfileDidChangeNotification";

//成功获取好友的时候发送的通知
static NSString *const STUseDidSuccessGetFriendsSendNotification = @"STUseDidSuccessGetFriendsSendNotification";

//成功取消订单会发出通知
static NSString *const STDidSuccessCancelOrderSendNotification = @"STDidSuccessCancelOrderSendNotification";

//成功支付会发出通知
static NSString *const STDidSuccessPaySendNotification = @"STDidSuccessPaySendNotification";

@class STNetError;

@class WeatherInformationModel;

@class SearchConditionModel;

@class MyOrderDetailModel;

@class UserInformationModel;

@interface STDataHandler : NSObject

@property (nonatomic, weak) id delegate;

//********* 发送验证请求 *************/
- (void)getVerifyWithPhoneNumber:(NSString *)phoneNumber
                            type:(NSNumber *)type
                          success:(void (^)(NSString *responseObject))success
                          failure:(void (^)(NSString *error))failure;


//*********** 核对短信验证码是否正确 ********/
- (void)postVerifySMSCodeWithPhoneNumber:(NSString *)phoneNumber
                             smsCode:(NSString *)smsCode
                             success:(void (^)(NSString *mobileToken))success
                             failure:(void (^)(NSError *error))failure;


//************ 修改密码*****************//
- (void)sendUpdateUserPasswordWithMobile:(NSString *)mobile
                             mobileToken:(NSString *)mobileToken
                                password:(NSString *)password
                                 success:(void (^)(BOOL success))success
                                 failure:(void (^)(NSError *error))failure;

//**************通过用户名获取userId通过用户名获取userId**********/
- (void)sendGetUserIdByUserName:(NSString *)userName
                        success:(void (^)(NSNumber *userId))success
                        failure:(void (^)(NSError *error))failure;


//***** 普通登录 *****/
//提醒:登录成功会获取用户的个人信息，首界面应刷新，所以登录成功会发出一个通知
//提醒:并且会循环设置个人健康因素，直到成功
- (NSString *)postSignInWithPassword:(NSString *)password
                           loginName:(NSString *)loginName
                  isPostNotification:(BOOL)isPostNotification
                             success:(void (^)(BOOL success))success
                             failure:(void (^)(NSError *))failure;


//***** 用户注册 *****/
//提醒:注册成功会获取用户的个人信息，首界面应刷新，所以注册成功会发出一个通知
//提醒:并且会循环设置个人健康因素，直到成功
- (void)postRegesiterWithPassword:(NSString *)password
                      phoneNumber:(NSString *)phoneNumber
                         nickName:(NSString *)nickName
                      mobileToken:(NSString *)mobileToken//校验后获取的验证码
                          success:(void (^)(BOOL success))success
                          failure:(void (^)(NSError *))failure;


//**** 获取好友(dataArray存储的是UserInformationModel) *****/
- (void)getMyFriendsWithUserId:(NSString *)userId
                                success:(void (^)(NSMutableArray * dataArray))success
                                failure:(void (^)(NSError *))failure;


//**********搜索某一个用户（里面装的UserInformationModel）**********************/
- (void)sendSearchUserRequestWithNickName:(NSString *)nickName
                            currentUserId:(NSString *)curUserId
                                  success:(void(^)(NSMutableArray *))success
                                  failure:(void (^)(NSError *))failure;


//************添加一个好友(currentUserId:当前用户的userId,nickName:待添加的userId,nickName:待添加的昵称)*************/
- (void)sendAddUserRequestWithcurrentUserId:(NSString *)currentUserId
                                     userId:(NSString *)userId
                                    success:(void(^)(BOOL success))success
                                    failure:(void (^)(NSError *error))failure;
//***** 更新个人信息 *****/
//提醒：保存成功后会发出通知
- (void)sendUpdateUserInformationWithUserId:(NSNumber *)userId
                                  nickName:(NSString *)nickName
                                    gender:(NSNumber *)gender
                                  birthday:(NSString *)birthday
                        headImageUrlString:(NSString *)headImageUrlString
                                  success:(void (^)(BOOL))success
                                  failure:(void (^)(STNetError *))failure;

//************获取通讯录好友************//
- (void)sendAddressBooklistRequestCompletionHandler:(void(^)(NSMutableArray *,NSMutableArray *,NSMutableArray *))handler;


//***********开始定位操作(sucess是城市的名字)****************/
- (void)startFindLocationSucess:(void (^)(NSString *,NSString *,CLLocationCoordinate2D))sucess
                        failure:(void (^)(NSError *))failure;


//*****************获取天气情况(代码块返回的是天气模型)***********/
- (void)getWeatherInformation:(NSString *)cityName
                        sucess:(void (^)(WeatherInformationModel *))sucess
                       failure:(void (^)(NSError *))failure;


//**********获取用户的天龄(dataArray装的是UserLifeModel模型)**********************/
- (void)sendUserLifeListWithCurrentUserId:(NSNumber *)currentUserId
                                   endDay:(NSString *)endDay//2016-02-19这种模式
                                dayNumber:(NSString *)dayNumber
                                success:(void (^)(NSMutableArray *dataArray))success
                                failure:(void (^)(STNetError *error))failure;


//***********获取健康因子(里面装的是GetFacotorModel数组)***************/
- (void)sendGetFactors:(void (^)(NSMutableArray *dataArray))success
               failure:(void (^)(STNetError *error))failure;


//***********获取每个健康模型的子模型(param:factorsArray装的是GetFactorModel,return:dataArray装GetFactorModel数组)***************/
- (void)sendGetSubFactorsWithFactorsModel:(NSMutableArray *)factorsArray
                                  success:(void (^)(NSMutableArray *dataArray))success
                                  failure:(void (^)(STNetError *error))failure;


//***********获获取某人的健康因子(里面装的是GetFacotorModel数组)***************/
- (void)sendGetUserFactorsWithUserId:(NSNumber *)userId
                   factorsModelArray:(NSMutableArray *)factorsModelArray
                             success:(void (^)(NSMutableArray *dataArray))success
                             failure:(void (^)(STNetError *error))failure;


//********保存某人健康因子到服务器(factorsModelArray存储的是GetFactorModel模型)*********************/
//提醒:如果保存成功,首界面天龄应该改变,保存成功会发出一个通知
- (void)sendSaveUserFactorsWithUserId:(NSNumber *)userId
                    factorsModelArray:(NSMutableArray *)factorsModelArray
                              success:(void (^)(BOOL success))success
                              failure:(void (^)(STNetError *error))failure;


//***********************************更新用户头像*********************/
- (void)sendUpdateUserHeadPortrait:(NSNumber *)userId
                           headImage:(UIImage *)image
                           success:(void (^)(NSString *imageUrl))success
                           failure:(void (^)(NSError *error))failure;

//***********************************获取个人密保问题*********************/
- (void)sendGetSecurityQuestion:(NSNumber *)userId
                       success:(void (^)(NSDictionary *dic))success
                       failure:(void (^)(STNetError *error))failure;

//***********************************获取所有密保问题*********************/
- (void)sendGetSecurityQuestionSum:(void (^)(NSArray *array))sucess
                           failure:(void (^)(STNetError *error))failure;

//***********************************验证个人密保问题*********************/
- (void)sendSecurityQuestionvalidate:(NSNumber *)userId
                        answer:(NSArray *)answerArr
                        success:(void (^)(NSString *successToken))success
                        failure:(void (^)(STNetError *error))failure;

//***********************************密保修改密码*********************/
- (void)sendSecurityQuestionUptUserPwdBySecu:(NSNumber *)userId
                               token:(NSString *)token
                            password:(NSString *)password
                             success:(void (^)(BOOL success))success
                             failure:(void (^)(STNetError *error))failure;

//***********************************修改密码*********************/
- (void)sendChangePasswordWithUserId:(NSNumber *)userId
                            oldPassword:(NSString *)oldPassword
                            newPassword:(NSString *)newPassword
                                success:(void (^)(BOOL success))success
                                failure:(void (^)(NSError *error))failure;

//***********************************添加密保*********************/
- (void)sendChangeSecurityWithUserId:(NSNumber *)userId
                         qidArray:(NSArray *)qidArray
                         answerArray:(NSArray *)answerArray
                             success:(void (^)(BOOL success))success
                             failure:(void (^)(NSError *error))failure;


//***********************************统计环境因素*********************/
- (void)sendStatUserLifeWithUserId:(NSNumber *)userId
                        dataString:(NSString *)data
                           success:(void (^)(BOOL success))success
                           failure:(void (^)(NSError *error))failure;


//***********************************绑定邮箱*********************/
- (void)sendUploadUserSendEmailWithUserId:(NSNumber *)userId
                              emailString:(NSString *)email
                                  success:(void (^)(BOOL success))success
                                  failure:(void (^)(NSError *error))failure;


//***********************************验证邮箱*********************/
- (void)sendVerificationUserEmailWithUserId:(NSNumber *)userId
                                  success:(void (^)(NSDictionary *verificationDictionary))success
                                  failure:(void (^)(NSError *error))failure;

//*********************************获取商家详细的数据*******************/
- (void)sendCompanyDetailsWithProductId:(NSString *)productId
                                    Success:(void (^)(ShopDetailModel *model))success
                                    failure:(void (^)(NSError *error))failure;

//*********************************获取城市地铁数据*******************/
- (void)sendCitySubWayWithCityId:(NSString *)cityId
                                Success:(void (^)(NSMutableArray *))success
                                failure:(void (^)(NSError *error))failure;


//*********************************根据筛选条件来获取所有的商品列表*******************/
- (void)sendShopListWithSearchConditionModel:(SearchConditionModel *)conditionModel
                                    isSearch:(BOOL)isSearch
                                  pageNumber:(NSInteger)pageNumber
                                     Success:(void (^)(NSMutableArray *))success
                                     failure:(void (^)(NSError *error))failure;

//*********************************获取评论列表*******************/
- (void)sendfindCommentListWithProductId:(NSInteger)productId
                                    type:(NSInteger)type
                                     pId:(NSInteger)pId
                                  userId:(NSInteger)userId
                         Success:(void (^)(NSMutableArray *success))success
                         failure:(void (^)(NSError *error))failure;

//*********************************评论*************************/
- (void)sendsaveCommentWithProductId:(NSString *)productId
                                type:(NSInteger)type
                              userId:(NSString *)userId
                              remark:(NSString *)remark
                          numberStar:(NSInteger)numberStar
                              picUrl:(NSString *)picUrl
                                 pId:(NSString *)pId
                                 Success:(void (^)(BOOL success))success
                                 failure:(void (^)(NSError *error))failure;

//*********************************点赞*************************/
- (void)sendPointPraiseOrCancelWithCommentId:(NSString *)commentId
                                 isClickLike:(BOOL)isClickLike
                                     Success:(void (^)(BOOL success))success
                                     failure:(void (^)(NSError *error))failure;


//*********************************商品详情评论*************************/
- (void)sendsaveCommentWithDefaultShowCount:(NSInteger)sendsaveComment
                                     Success:(void (^)(NSMutableArray *success))success
                                     failure:(void (^)(NSError *error))failure;


//*********************************获取后台数据表格跟新版本信息*************************/
- (void)sendSearchTableVersion:(void (^)(NSMutableArray *success))success
                       failure:(void (^)(NSError *error))failure;


//*********************************店长推荐*************************/
- (void)sendShopOwnerRecommendWithCompanyId:(NSString *)companyId
                                      count:(NSInteger)count
                                     Success:(void (^)(NSMutableArray *success))success
                                     failure:(void (^)(NSError *error))failure;

//*********************************平台推荐*************************/
- (void)sendPlatformRecommendWithProductTypeId:(NSString *)ProductTypeId
                                         count:(NSInteger)count
                                       Success:(void (^)(NSMutableArray *success))success
                                       failure:(void (^)(NSError *error))failure;

//*********************************商店*************************/
- (void)sendfindCompanyInfoByIdWithCompanyId:(NSString *)companyId
                                    Success:(void (^)(CompanyModel *success))success
                                    failure:(void (^)(NSError *error))failure;

//*********************************商店下的商品*************************/
- (void)sendFindProductsByIdsWithCompanyId:(NSString *)companyId
                             productTypeId:(NSString *)productTypeId
                                   Success:(void (^)(NSMutableArray *success))success
                                   failure:(void (^)(NSError *error))failure;

//*********************************获取可预约的场地*************************/
- (void)sendFindOrderCanAppointmentWithUserId:(NSNumber *)userId
                                    productId:(NSNumber *)productId
                                         date:(NSString *)date
                                      Success:(void (^)(NSMutableArray *success))success
                                      failure:(void (^)(NSError *error))failure;

//*********************************提交订单*************************/
- (void)sendCommitOrderWithUserId:(NSNumber *)userId
                        productId:(NSNumber *)productId
                      contactName:(NSString *)contactName
               contactPhoneNumber:(NSString *)contactPhoneNumber
                             date:(NSString *)date
                           remark:(NSString *)remark
                   uniqueKeyArray:(NSMutableArray *)timeModelArray
                          Success:(void (^)(NSString *orderNumber))success
                          failure:(void (^)(NSError *error))failure;

//**************根据类型获取订单 0->表示全部类型 1->表示已付款 2->表示未付款 返回数组里装的是MyOrderModel************/
- (void)sendFindOrderUserId:(NSNumber *)userId
                       type:(NSNumber *)type
                    success:(void (^)(NSMutableArray *success))success
                    failure:(void (^)(NSError *error))failure;

//**************根据类型获取订单，返回的是MyOrderDetailModel************/
- (void)sendFindOrderDetailOrderNumber:(NSString *)orderNumber
                    success:(void (^)(MyOrderDetailModel *detailModel))success
                    failure:(void (^)(NSError *error))failure;

//*****************************************根据类型查资讯************/
- (void)sendsearchInfomationsWithWriterId:(NSString *)writerId
                             infoTypeCode:(NSString *)infoTypeCode
                                 sortType:(NSInteger)sortType
                                  success:(void (^)(NSMutableArray *success))success
                                  failure:(void (^)(NSError *error))failure;

//**************取消订单,会出发通知:STDidSuccessPaySendNotification************/
- (void)sendCancelOrderWithOrderNumber:(NSString *)orderNumber
                               success:(void (^)(BOOL success))success
                               failure:(void (^)(NSError *error))failure;

//*****************************************获取资讯详情*********************/
- (void)sendInfomationDetailWithInfoId:(NSString *)infoId
                               success:(void (^)(InformationDetailModel *informationDetailModel))success
                               failure:(void (^)(NSError *error))failure;

//*****************************************资讯点赞*********************/
- (void)sendPointOrCancelPraiseWithUserId:(NSNumber *)userId
                                   busiId:(NSString *)busiId
                              isClickLike:(NSInteger)isClickLike
                                 busiType:(NSInteger)busiType
                                  success:(void (^)(BOOL success))success
                                  failure:(void (^)(NSError *error))failure;

//*****************************************作者主页*********************/
- (void)senSearchWriterInfomationsWithWriterId:(NSString *)writerId
                                        userId:(NSString *)userId
                                       success:(void (^)(InformationWriterModel *success))success
                                       failure:(void (^)(NSError *error))failure;

//*****************************************订阅*********************/
- (void)sendSubscribeWithWriterId:(NSString *)writerId
                           userId:(NSString *)userId
                          success:(void (^)(BOOL success))success
                          failure:(void (^)(NSError *error))failure;

//*****************************************取消订阅*********************/
- (void)sendCancelSubscribeWriterId:(NSString *)writerId
                             userId:(NSString *)userId
                            success:(void (^)(BOOL success))success
                            failure:(void (^)(NSError *error))failure;

//*****************************************我的订阅*********************/
- (void)sendMySubscribeWithUserId:(NSString *)userId
                          success:(void (^)(NSMutableArray *success))success
                          failure:(void (^)(NSError *error))failure;

//*****************************************根据userId来获取个人信息模型*********************/
- (void)sendUserInformtionWithUserId:(NSNumber *)userId
                          success:(void (^)(UserInformationModel *model))success
                          failure:(void (^)(NSError *error))failure;

//*****************************************查找作者*********************/
- (void)sendSearchWriterListWithWriterName:(NSString *)writerName
                                    userId:(NSString *)userId
                          success:(void (^)(NSMutableArray *success))success
                          failure:(void (^)(NSError *error))failure;

@end