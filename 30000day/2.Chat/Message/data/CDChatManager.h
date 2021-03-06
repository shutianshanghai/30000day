//
//  CDChatManager.h
//  LeanChat
//
//  Created by lzw on 15/1/21.
//  Copyright (c) 2015年 LeanCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVIMConversation+Custom.h"
#import "CDMacros.h"

/**
 *  未读数改变了。通知去服务器同步 installation 的badge
 */
static NSString *const kCDNotificationUnreadsUpdated = @"UnreadsUpdated";

/**
 *  消息到来了，通知聊天页面和最近对话页面刷新
 */
static NSString *const kCDNotificationMessageReceived = @"MessageReceived";

/**
 *  消息到达对方了，通知聊天页面更改消息状态
 */
static NSString *const kCDNotificationMessageDelivered = @"MessageDelivered";

/**
 *  对话的元数据变化了，通知页面刷新
 */
static NSString *const kCDNotificationConversationUpdated = @"ConversationUpdated";

/**
 *  聊天服务器连接状态更改了，通知最近对话和聊天页面是否显示红色警告条
 */
static NSString *const kCDNotificationConnectivityUpdated = @"ConnectStatus";

typedef void (^CDRecentConversationsCallback)(NSArray *conversations, NSInteger totalUnreadCount,  NSError *error);


/**
 *  核心的聊天管理类
 */
@interface CDChatManager : NSObject

/*!
 * AVIMClient 实例
 */
@property (nonatomic, strong) AVIMClient *client;

/**
 *  即 openClient 时的 clientId
 */
@property (nonatomic, strong, readonly) NSString *clientId;

/**
 *  是否和聊天服务器连通
 */
@property (nonatomic, assign, readonly) BOOL connect;

/**
 *  当前正在聊天的 conversationId
 */
@property (nonatomic, strong) NSString *chattingConversationId;

/**
 *  获取单例
 */
+ (instancetype)sharedManager;

/**
 *  打开一个聊天终端，登录服务器
 *  @param clientId 可以是任何的字符串。可以是 "123"，也可以是 uuid。应用内需唯一，不推荐 name，因为 name 会改变。固定不变的 id 是最好的。
 *  @param callback 回调。当网络错误或签名错误会发生 error 回调。
 */
- (void)openWithClientId:(NSString *)clientId callback:(AVIMBooleanResultBlock)callback;

/**
 *  关闭一个聊天终端，注销的时候使用
 */
- (void)closeWithCallback:(AVIMBooleanResultBlock)callback;

/**
 *  根据 conversationId 获取对话
 *  @param convid   对话的 id
 *  @param callback
 */
- (void)fecthConversationWithConversationId:(NSString *)conversationId callback:(AVIMConversationResultBlock)callback;

#pragma mark ---- 新加的
/**
 *  获取单聊对话
 *  @param otherId  对方的 clientId
 *  @param callback
 */
- (void)fetchConversationWithOtherId:(NSString *)otherId attributes:(NSDictionary *)attributes callback:(AVIMConversationResultBlock)callback;

/**
 *  已知参与对话 members，获取群聊对话
 *  @param members  成员，clientId 数组
 *  @param callback
 */
- (void)fetchConversationWithMembers:(NSArray *)members callback:(AVIMConversationResultBlock)callback;

/*!
 *  获取我在其中的群聊对话
 *  @param networkFirst 是否网络优先
 *  @param block        对话数组回调
 */
- (void)findGroupedConversationsWithNetworkFirst:(BOOL)networkFirst block:(AVIMArrayResultBlock)block;

/**
 *  创建对话
 *  @param members  初始成员
 *  @param type     单聊或群聊
 *  @param unique   是否唯一，如果有相同 members 的成员且要求唯一的话，将不创建返回原来的对话。
 *  @param attributes 回话的自定义字典
 *  @param callback 对话回调
 *  @attention  Always consider unique params.
 */
- (void)createConversationWithMembers:(NSArray *)members type:(CDConversationType)type unique:(BOOL)unique attributes:(NSDictionary *)attributes callback:(AVIMConversationResultBlock)callback;

/**
 *  将对话缓存在内存中
 *  @param conversationIds  需要缓存的对话 ids
 *  @param callback
 */
- (void)cacheConversationsWithIds:(NSMutableSet *)conversationIds callback:(AVIMBooleanResultBlock)callback;

/**
 *  根据对话 id 查找内存中的对话
 *  @param ConversationId 对话 id
 *  @return conversation 对象
 */
- (AVIMConversation *)lookupConversationById:(NSString *)conversationId;

/**
 *  统一的发送消息接口
 *  @param message      富文本消息
 *  @param conversation 对话
 *  @param block
 */
- (void)sendMessage:(AVIMTypedMessage*)message conversation:(AVIMConversation *)conversation callback:(AVIMBooleanResultBlock)block;

/**
 *  查询时间戳之前的历史消息
 *  @param conversation 需要查询的对话
 *  @param timestamp    起始时间戳
 *  @param limit        条数
 *  @param block        消息数组回调
 */
- (void)queryTypedMessagesWithConversation:(AVIMConversation *)conversation timestamp:(int64_t)timestamp limit:(NSInteger)limit block:(AVIMArrayResultBlock)block;
/**
 *  查找最近我参与过的对话
 *  @param block 对话数组回调
 */
- (void)findRecentConversationsWithBlock:(CDRecentConversationsCallback)block;

/**
 *  在 ApplicationDelegate 中的 application:didRemoteNotification 调用，来记录推送时的 convid，这样点击弹框打开后进入相应的对话
 *  @param userInfo
 *  @return 是否检测到 convid 做了处理
 */
- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * 退出对话并删除
 */
- (void)deleteAndDeleteConversation:(AVIMConversation *)conversation callBack:(void (^)(BOOL successed,NSError *error))callBack;

@end
