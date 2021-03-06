//
//  MailListViewController.m
//  30000day
//
//  Created by wei on 16/2/2.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "MailListViewController.h"
#import "MailListTableViewCell.h"
#import "ChineseString.h"
#import "ShareAnimatonView.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

#import "UMSocial.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "MTProgressHUD.h"
#import "MailListManager.h"
#import "NewFriendManager.h"
#import "UserInformationModel.h"


#define requestDataCount 100

@interface MailListViewController () <UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UMSocialUIDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *indexArray; //里面装的NSSting(A,B,C,D.......)
@property (nonatomic ,strong) NSMutableArray *chineseStringArray; //该数组里面装的是chineseString这个模型
@property (nonatomic ,strong) NSMutableArray *chineseStringSumArray; //所有联系人
@property (nonatomic ,strong) NSMutableArray *chineseStringNewArray; //用来装每次请求数据的模型
@property (nonatomic ,assign) int requestIndex; //记录循环次数(满requestDataCount 等于1)
@property (nonatomic ,assign) int chineseStringArrayRequestIndex; //记录循环次数
@property (nonatomic ,assign) int subDataArrayRequestIndex; //记录循环次数
@property (nonatomic ,assign) int subDataArrayRequestDataIndex; //记录循环次数（用于请求数据）
@property (nonatomic ,strong) NSMutableArray *phoneNumberArray;
@property (nonatomic ,assign) BOOL isfirstReques;
@property (nonatomic ,assign) NSInteger sumLXR;          //所有联系人数量
@property (nonatomic ,assign) NSInteger addRequestCount; //累加请求数量

@end

@implementation MailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"所有联系人";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];

    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        [self footerRereshing];
        
    }];

    [self.view addSubview:self.tableView];
    
    self.isfirstReques = YES;

    [self synchronizedMailList];
}

- (void)footerRereshing {
    
    [self requestData:[self zhuzhuangData:self.phoneNumberArray]];

}

//同步数据
- (void)synchronizedMailList {
    
    NSString *isFirstStartString = [Common readAppDataForKey:FIRSTSTART];

    if ([Common isObjectNull:isFirstStartString]) {
        
        [Common saveAppDataForKey:FIRSTSTART withObject:@"1"];
        //提示用户
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"匹配手机通讯录" message:@"30000天将上传手机通讯录至30000天服务器匹配及推荐朋友。\n（上传通讯录仅用于匹配，不会保存资料，亦不会用作它用）" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self loadData];
        }];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        
        [self loadData];
    }
}

- (void)loadData {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler sendAddressBooklistRequestCompletionHandler:^(NSMutableArray *chineseStringArray,NSMutableArray *sortArray,NSMutableArray *indexArray,BOOL isAllow) {
        
        if (!isAllow) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未开启权限" message:@"如需查看通讯录联系人,请打开通讯录权限" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
            UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    
                    NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    
                    [[UIApplication sharedApplication] openURL:url];
                    
                }
                
            }];
            
            [alert addAction:actionCancel];
            
            [alert addAction:actionConfirm];
            
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            if([Common isObjectNull:chineseStringArray] || chineseStringArray.count == 0) return;
            
            self.chineseStringSumArray = [NSMutableArray array];
            self.chineseStringSumArray = chineseStringArray;
            
            self.chineseStringArray = [NSMutableArray array];
            
            self.indexArray = [NSMutableArray arrayWithArray:indexArray];
            
            NSMutableArray *phoneNumberArray = [NSMutableArray array];

            for (int i = 0 ; i < chineseStringArray.count ; i++) {
                
                NSMutableArray *subDataArray = chineseStringArray[i];
                NSMutableArray *phoneArray = [NSMutableArray array];
                
                for (int j = 0; j < subDataArray.count; j++) {
                    
                    ChineseString *chineseString = subDataArray[j];
                    NSString *phoneNumber = chineseString.phoneNumber;
                    
                    if ([[phoneNumber substringToIndex:1] isEqualToString:@"+"]) {
                        
                        phoneNumber = [phoneNumber substringFromIndex:4];
                    }
                    
                    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    NSMutableDictionary *phoneNumberDictionary = [NSMutableDictionary dictionary];
                    [phoneNumberDictionary addParameter:phoneNumber forKey:@"mobile"];
                    [phoneArray addObject:phoneNumberDictionary];
                    
                    self.sumLXR ++;
                }
                
                [phoneNumberArray addObject:phoneArray];
            }
            
            self.phoneNumberArray = phoneNumberArray;

            [self requestData:[self zhuzhuangData:phoneNumberArray]];
            
        }
        
    }];
    
}


- (NSMutableArray *)zhuzhuangData:(NSArray *)array {

    NSMutableArray *newPhoneArray = [NSMutableArray array];
    
    NSMutableArray *chineseStringArray = [NSMutableArray array];
    
    int jj = 0;
    
    for (int i = self.chineseStringArrayRequestIndex; i < array.count; i++) {
         
        NSMutableArray *subDataArray = array[i];
         
        NSMutableArray *phoneArray = [NSMutableArray array];
        
        NSMutableArray *chineseArray = self.chineseStringSumArray[i];
        
        NSMutableArray *chineseSumArray = [NSMutableArray array];
         
        for (int j = self.subDataArrayRequestIndex; j < subDataArray.count; j++) {
            
            if (self.addRequestCount == self.sumLXR) {
                
                return newPhoneArray;
                
            }
     
            [chineseSumArray addObject:chineseArray[j]];
         
            [phoneArray addObject:subDataArray[j]];
         
            self.requestIndex ++;
            
            self.addRequestCount ++;
            
            jj = j;
             
            if (self.requestIndex == requestDataCount) {
                 
                if (j + 1 ==  subDataArray.count) {
                     
                    self.chineseStringArrayRequestIndex = i + 1;
                    
                     
                } else {
                     
                    self.chineseStringArrayRequestIndex = i;
                    self.subDataArrayRequestIndex = j + 1;
                     
                }

                break;
            }
             
        }
     
        [newPhoneArray addObject:phoneArray];
        
        [chineseStringArray addObject:chineseSumArray];

        
        if (jj + 1 ==  subDataArray.count) {
            
            self.subDataArrayRequestIndex = 0;
            
            self.isfirstReques = NO;
            
        }

        if (self.requestIndex == requestDataCount) {
         
            self.requestIndex = 0;
             
            break;
        }
     
    }
    
    self.chineseStringNewArray = chineseStringArray;
    
    return newPhoneArray;
    
}

- (void)requestData:(NSArray *)array {

    if (array.count == 0) {
        
        [self.tableView.mj_footer endRefreshing];
        
        return;
        
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [STDataHandler sendcheckAddressBookWithMobileOwnerId:STUserAccountHandler.userProfile.userId.stringValue addressBookJson:jsonString success:^(NSArray *addressArray) {
        
        for (int i = 0 ; i < addressArray.count; i++) {
            
            NSMutableArray *subDataArray = self.chineseStringNewArray[i];
            NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:addressArray[i]];
            NSArray *array = [NSArray arrayWithArray:dictionary[@"addressBookList"]];
            
            for (int j = 0; j < subDataArray.count; j++) {
                
                NSDictionary *dictionary = (NSDictionary *)array[j];
                ChineseString *chineseString = subDataArray[j];
                chineseString.status = [dictionary[@"status"] integerValue];
                
                if ([dictionary[@"status"] integerValue] == 1) {
                    
                    chineseString.userId = dictionary[@"userId"];
                    //[registerArray addObject:chineseString];
                    
                } else if([dictionary[@"status"] integerValue] == 2){
                    
                    //[friendArray addObject:chineseString];
                }

            }
            
        }
        
        
        //将每次上啦加载过多的数据加载到chineseStringArray
        NSArray *firstChineseStringArray = [self.chineseStringNewArray firstObject];
        
        NSMutableArray *chineseArray = [self.chineseStringArray lastObject];
        
        NSInteger index = 0;
        
        if (self.chineseStringArray.count != 0) {
            
            index = self.chineseStringArray.count - 1;
            
        }
        
        NSArray *chineseSumArray = self.chineseStringSumArray[index];
        
        if (chineseSumArray.count != chineseArray.count) {
            
            for (int i = 0; i < firstChineseStringArray.count; i++) {
                
                [chineseArray addObject:firstChineseStringArray[i]];
                
            }
            
            int cIndex = 0;
            
            if (chineseArray.count != 0) {
                
                cIndex = 1;
                
            }
            
            for (int i = cIndex; i < self.chineseStringNewArray.count; i++) {
                
                [self.chineseStringArray addObject:self.chineseStringNewArray[i]];
                
            }
            
        } else {
            
            for (int i = 0; i < self.chineseStringNewArray.count; i++) {
                
                [self.chineseStringArray addObject:self.chineseStringNewArray[i]];
                
            }
        }

        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            
            [self footerRereshing];
            
        });
        
    } failure:^(NSError *error) {
        
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        [self.tableView.mj_footer endRefreshing];
        [self showToast:[Common errorStringWithError:error optionalString:@"获取通讯录信息失败"]];
        
    }];


}

#pragma ---
#pragma mark --- UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.chineseStringArray.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *array = self.chineseStringArray[section];
     
    return array.count;
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSRange range = NSMakeRange(0, self.chineseStringArray.count);

    return [self.indexArray subarrayWithRange:range];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *key = [self.indexArray objectAtIndex:section];
        
    return key;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = RGBACOLOR(230, 230, 230, 1);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 20)];
    label.text = [self.indexArray objectAtIndex:section];
    label.textColor = [UIColor darkGrayColor];
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MailListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailListTableViewCell"];
    
    if (cell == nil) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MailListTableViewCell" owner:self options:nil] lastObject];
    }
    
    ChineseString *chineseString;

    NSMutableArray *array = self.chineseStringArray[indexPath.section];
        
    chineseString = array[indexPath.row];
    
    cell.dataModel = chineseString;
  
    //按钮点击回调
    [cell setInvitationButtonBlock:^(UIButton *button) {
        
        [self.view endEditing:YES];
        
        if (button.tag) {
            
            NSLog(@"%ld",chineseString.userId.integerValue);
            
            //添加好友
            //添加好友,接口, @1请求   @2接受   @3拒绝
            if ([Common isObjectNull:STUserAccountHandler.userProfile.userId] || [Common isObjectNull:chineseString.userId]) {
                
                [self showToast:@"对方或自己的ID为空"];
                
                return;
            }
            
            if ([[NSString stringWithFormat:@"%@",STUserAccountHandler.userProfile.userId] isEqualToString:[NSString stringWithFormat:@"%@",chineseString.userId]]) {
                
                [self showToast:@"不能添加自己"];
                
                return;
            }
            
            [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
            [STDataHandler sendPushMessageWithCurrentUserId:STUserAccountHandler.userProfile.userId
                                                     userId:chineseString.userId
                                                messageType:@1
                                                    success:^(BOOL success) {
                                                        
                                                        [STDataHandler sendUserInformtionWithUserId:chineseString.userId success:^(UserInformationModel *model) {
                                                            
                                                            if ([Common isObjectNull:[UserInformationModel errorStringWithModel:model userProfile:STUserAccountHandler.userProfile]]) {
                                                                
                                                                if ([model.friendSwitch isEqualToString:@"1"]) {//打开的
                                                                    
                                                                    [NewFriendManager drictRefresh:model andCallback:^(BOOL succeeded, NSError *error) {
                                                                        
                                                                        if (succeeded) {
                                                                            
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                
                                                                                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                                
                                                                                [self showToast:@"好友添加成功"];
                                                                                
                                                                                [STNotificationCenter postNotificationName:STDidApplyAddFriendSuccessSendNotification object:nil];
                                                                            });
                                                                            
                                                                        } else {
                                                                            
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                
                                                                                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                                
                                                                                [self showToast:@"消息发送失败"];
                                                                                
                                                                            });
                                                                        }
                                                                        
                                                                    }];
                                                                    
                                                                } else {//等于0，获取没设置
                                                                    
                                                                    [NewFriendManager subscribePresenceToUserWithUserProfile:model andCallback:^(BOOL succeeded, NSError *error) {
                                                                        
                                                                        if (succeeded) {
                                                                            
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                
                                                                                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                                
                                                                                [self showToast:@"请求发送成功"];
                                                                                
                                                                            });
                                                                            
                                                                        } else {
                                                                            
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                
                                                                                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                                
                                                                                [self showToast:error.userInfo[NSLocalizedDescriptionKey]];
                                                                                
                                                                            });
                                                                        }
                                                                    }];
                                                                    
                                                                }
                                                                
                                                            } else {
                                                                
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    
                                                                    [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                    
                                                                    [self showToast:[UserInformationModel errorStringWithModel:model userProfile:STUserAccountHandler.userProfile]];
                                                                });
                                                            }
                                                            
                                                        } failure:^(NSError *error) {
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                
                                                                [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                                                
                                                            });
                                                            
                                                        }];
                                                        
                                                    } failure:^(NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                            
                                                            [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                                            
                                                        });
                                                        
                                                    }];
            
        } else {
            
            [self showShareAnimatonView:indexPath];
        }
    }];
    
    return cell;
}

//显示分享界面
- (void)showShareAnimatonView:(NSIndexPath *)indexPath {
    
    ShareAnimatonView *shareAnimationView = [[[NSBundle mainBundle] loadNibNamed:@"ShareAnimatonView" owner:self options:nil] lastObject];
    
    //封装的动画般推出视图
    [ShareAnimatonView animateWindowsAddSubView:shareAnimationView];
    
    //按钮点击回调
    [shareAnimationView setShareButtonBlock:^(NSInteger tag,ShareAnimatonView *animationView) {
        
        [ShareAnimatonView annimateRemoveFromSuperView:animationView];
        
        //NSString *shareString = [NSString stringWithFormat:@"我的预期寿命有%@天，击败了%@%%的人，你呢？守护我爱的人，30000天。",[Common readAppDataForKey:DAYS_AGE],[Common readAppDataForKey:DEFEATDATA]];
        NSString *shareString = @"我戒掉了熬夜，每天睡到自然醒还能看日出，只因用了30000天app";
        
        if (tag == 8) {
         
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = @"http://www.30000day.com";
            [self showToast:@"已经复制到剪贴板"];
            
        } else if (tag == 7) {//发送短信
            
            if ([MFMessageComposeViewController canSendText] ) {

                //调用短信接口
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                
                picker.messageComposeDelegate = self;
                
                ChineseString *chineseSting = ((NSMutableArray *)self.chineseStringArray[indexPath.section])[indexPath.row];
                
                picker.recipients = [NSArray arrayWithObject:chineseSting.phoneNumber];
                
                picker.body = @"守护我爱的人，30000天。人生短暂，快来加入吧!http://www.30000day.com";
                
                if (picker) {
                    
                    [self presentViewController:picker animated:YES completion:nil];
                }
                
            } else {
                
                [self showToast:@"该设备不支持短信功能"];
            }
            
        } else if (tag == 6) {//发送邮件
            
//            if ([MFMailComposeViewController canSendMail]) {
//                
//                MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
//                
//                controller.mailComposeDelegate = self;
//                
//                [controller setSubject:@"My Subject"];
//                
//                [controller setMessageBody:shareString isHTML:NO];
//                
//                if (controller) {
//                    
//                    [self presentViewController:controller animated:YES completion:nil];
//                }
//                
//            } else {
//                
//                [self showToast:@"该设备没有设置邮箱账号"];
//            }
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.shutian.ttd";
            [self showToast:@"已经复制到剪贴板"];
            
        } else if (tag == 5) {
            [UMSocialData defaultData].extConfig.qqData.title = @"30000天";
            [[UMSocialControllerService defaultControllerService] setShareText:[NSString stringWithFormat:@"%@,%@",shareString,@"苹果http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1086080481&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8 安卓http://a.app.qq.com/o/simple.jsp?pkgname=com.shutian.ttd"] shareImage:[UIImage imageNamed:@"sharePicture"] socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
        }  else if (tag == 4) {
            
            [UMSocialData defaultData].extConfig.qqData.title = @"30000天";
            [[UMSocialControllerService defaultControllerService] setShareText:shareString shareImage:[UIImage imageNamed:@"sharePicture"] socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
        } else if (tag == 3) {
            
            [UMSocialData defaultData].extConfig.qzoneData.title = @"30000天";
            [[UMSocialControllerService defaultControllerService] setShareText:shareString shareImage:[UIImage imageNamed:@"sharePicture"] socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQzone].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
        } else if (tag == 2 ) {
            
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"30000天";
            [[UMSocialControllerService defaultControllerService] setShareText:shareString shareImage:[UIImage imageNamed:@"sharePicture"] socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            //[UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://xxxx";
            
        } else if (tag == 1 ) {
            
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareString;
            [[UMSocialControllerService defaultControllerService] setShareText:@"30000天" shareImage:[UIImage imageNamed:@"sharePicture"] socialUIDelegate:self];        //设置分享内容和回调对象
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
        }
    }];
}

#pragma mark ---- MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled: {
            
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        case MessageComposeResultFailed:// send failed
            
            [self showToast:@"短信发送失败"];
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case MessageComposeResultSent: {
            
            [self showToast:@"短信发送成功"];
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        default:
            
            break;
    }
}

#pragma mark ---- MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    if (result == MFMailComposeResultSent) {
        
        [self showToast:@"邮件发送成功"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (result == MFMailComposeResultCancelled) {
        
         [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (result == MFMailComposeResultFailed) {
        
        [self showToast:@"邮件发送失败"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (result == MFMailComposeResultSaved) {
        
        [self showToast:@"邮件已经保存"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark --- UMSocialUIDelegate

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess) {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}


@end
