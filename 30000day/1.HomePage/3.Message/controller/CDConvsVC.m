//
//  CDConvsVC.m
//  LeanChat
//
//  Created by lzw on 15/4/10.
//  Copyright (c) 2015年 LeanCloud. All rights reserved.
//

#import "CDConvsVC.h"
#import "CDUtils.h"
#import "CDIMService.h"
#import "CDChatVC.h"

@interface CDConvsVC () <CDChatListVCDelegate>

@end

@implementation CDConvsVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"消息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatListDelegate = self;
    
    self.tableView.contentInset =  UIEdgeInsetsMake(64, 0, 50, 0);
}

#pragma mark - CDChatListVCDelegate

- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv {
    
    [[CDIMService service] pushToChatRoomByConversation:conv fromNavigationController:viewController.navigationController];

}

- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount {
    if (totalUnreadCount > 0) {
        
        if (totalUnreadCount >= 100) {
            
            [[self navigationController] tabBarItem].badgeValue = @"99+";
            
        } else {
            
            [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
            
        }
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadCount];
        
    } else {
        
        [[self navigationController] tabBarItem].badgeValue = nil;
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
    }
    
    if (self.unreadMessageChange) {
        
        self.unreadMessageChange(totalUnreadCount);
    }
}



//- (UIImage *)defaultAvatarImageView {
//    UIImage *defaultAvatarImageView = [UIImage imageNamed:@"avator"];
//    defaultAvatarImageView = [CDUtils roundImage:defaultAvatarImageView toSize:CGSizeMake(100, 100) radius:5];
//    return defaultAvatarImageView;
//}

@end
