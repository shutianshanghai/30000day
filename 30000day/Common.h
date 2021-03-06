//
//  Common.h
//  30000day
//
//  Created by GuoJia on 16/2/2.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ThirdPartyLandingViewController;

@interface Common : NSObject

+ (BOOL)isUserLogin;//判断客户端过去是否登录过
+ (BOOL) isObjectNull : (id) obj;

+ (void)saveAppDataForKey : (NSString *) key  withObject : (id) value;
+ (id)readAppDataForKey : (NSString *) key;
+ (void)removeAppDataForKey:(NSString *)key ;

+ (void)saveAppIntegerDataForKey : (NSString *) key  withObject : (NSInteger) value;
+ (NSInteger)readAppIntegerDataForKey : (NSString *) key;

+ (BOOL)readAppBoolDataForkey:(NSString *)key;
+ (void) saveAppBoolDataForKey : (NSString *) key  withObject : (BOOL) value;


/**
 * 获取NSDated的时间字符串
 * @Param   NSDate类型的对象
 * @return  @"2016-12-12"
 */
+ (NSString *)getDateStringWithDate:(NSDate *)date;

/**
 * 获取NSDate对象
 * @Param   formatterString比如:@"yyyy-MM-dd",dateString:比如"2016-12-05"
 * @return  获取NSDate对象
 */
+ (NSDate *)getDateWithFormatterString:(NSString *)formatterString dateString:(NSString *)dateString;

/**
 *  @param  timeNumber long类型的数字
 *
 *  @return  @"2015-12-12"
 **/
+ (NSString *)getDateStringWithTimeInterval:(long)timeNumber;

/**
 * 给定一个数字string（长度为1）前面加个0,比如: 1 ----> 01
 *
 */
+ (NSString *)addZeroWithString:(NSString *)numberString;

/**
 * 给定一个string,比如: @"yyyy-MM-dd HH:mm" ---->NSDateFormatter
 *
 */
+ (NSDateFormatter *)dateFormatterWithFormatterString:(NSString *)formatterString;


+ (UIImage *)imageWithColor:(UIColor *)color;

//专门用来检查URL是否正确的
+ (NSString *)urlStringWithDictionary:(NSMutableDictionary *)dictinary withString:(NSString *)subApi;

//用于搜索好友
+ (NSString *)urlStringWithDictionarySearch:(NSMutableDictionary *)dictinary withString:(NSString *)subApi;

//剪切字符串，吧市、自治区、省
+ (NSString *)deletedStringWithParentString:(NSString *)sting;

/**
 *  通过输入一个date来返回星期几
 */
+ (NSString *)weekdayStringFromDate:(NSDate*)inputDate;

+ (NSString *)getChineseCalendarWithDate:(NSDate *)date;

+ (CGFloat)heightWithText:(NSString *)text width:(CGFloat)width fontSize:(CGFloat)fontSize;

+ (CGFloat)widthWithText:(NSString *)text height:(CGFloat)height fontSize:(CGFloat)fontSize;

//添加预约按钮
+ (UIButton *)addAppointmentBackgroundView:(UIView *)superView title:(NSString *)title selector:(SEL)selector controller:(UIViewController *)controller;

//15.00  -> ￥15.00(红色)
+ (NSMutableAttributedString *)attributedStringWithPrice:(CGFloat)price;

/** 判断是否在某一天天之内 */
+ (void)dayNumberWithinNumber:(NSInteger)number inputDate:(NSDate *)inputDate completion:(void(^)(NSInteger day))completion;


+ (NSError *)errorWithString:(NSString *)errorString;
//表示如果该error的NSLocalizedDescriptionKey存在那么返回NSLocalizedDescriptionKey，如果不不存在返回optionalString
+ (NSString *)errorStringWithError:(NSError *)error optionalString:(NSString *)optionalString;

+ (NSString *)keyChainValue;//获取设备唯一标识符
+ (BOOL)needBind;//是否需要绑定

//获取绑定控制器
+ (ThirdPartyLandingViewController *)getBindController;
//推出UIAlertController类型控制器
+ (void)presentBindControllerWithSuperController:(UIViewController *)superController;

//如果超过一万的话的显示:xx.x万 显示一位小数
//如果16879 1.6万
//11478 1.1万
// 10263 1万
+ (NSString *)getNumberString:(NSNumber *)numberString;

//检查是否是手机和电话号码
+ (BOOL)isMobile:(NSString *)mobileNumbel;

@end
