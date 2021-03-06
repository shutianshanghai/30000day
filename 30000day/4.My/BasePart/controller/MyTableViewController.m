
//
//  MyTableViewController.m
//  30000day
//
//  Created by GuoJia on 16/1/28.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "MyTableViewController.h"
#import "myViewCell.h"
#import "userInfoViewController.h"
#import "SignInViewController.h"
#import "SecurityViewController.h"
#import "SetUpViewController.h"
#import "HealthySetUpViewController.h"
#import "UserHeadViewTableViewCell.h"
#import "LogoutTableViewCell.h"
#import "CDChatManager.h"
#import "MTProgressHUD.h"
#import "MyOrderViewController.h"
#import "JPUSHService.h"
#import "AgreementWebViewController.h"
#import "AboutTableViewController.h"
#import "QuickResponseCodeViewController.h"
#import "QRReaderViewController.h"

@interface MyTableViewController () <UITableViewDataSource,UITableViewDelegate>
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.tableViewStyle = STRefreshTableViewGroup;
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self showHeadRefresh:YES showFooterRefresh:NO];
    self.isShowBackItem = NO;
    
    //监听个人信息管理模型发出的通知
    [STNotificationCenter addObserver:self selector:@selector(reloadData:) name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];
//    [self loadEmail];
}

#pragma ---
#pragma mark --- 上啦刷新和下拉刷新
- (void)headerRefreshing {
    [self loadUserInformation];
}

- (void)reloadData:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)loadUserInformation {
    [self.dataHandler postSignInWithPassword:[Common readAppDataForKey:KEY_SIGNIN_USER_PASSWORD]
                                   loginName:[Common readAppDataForKey:KEY_SIGNIN_USER_NAME]
                          isPostNotification:YES
                            isFromThirdParty:[NSNumber numberWithInteger:[Common readAppIntegerDataForKey:KEY_IS_THIRDPARTY]]
                                        type:[Common readAppDataForKey:KEY_LOGIN_TYPE]
                                     success:^(BOOL success) {
                                         //获取用户的email
//                                         [self loadEmail];
                                         [self.tableView.mj_header endRefreshing];
                                     } failure:^(NSError *error) {
                                         
                                         NSString *errorString = [error userInfo][NSLocalizedDescriptionKey];
                                         if ([errorString isEqualToString:@"账户无效，请重新登录"]) {
                                             [self showToast:@"账户无效"];
                                             [self jumpToSignInViewController];
                                         } else  {
                                             [self showToast:@"网络繁忙，请再次刷新"];
                                         }
                                         [self.tableView.mj_header endRefreshing];
                                     }];
}


//跳到登录控制器
- (void)jumpToSignInViewController {
    SignInViewController *logview = [[SignInViewController alloc] init];
    STNavigationController *navigationController = [[STNavigationController alloc] initWithRootViewController:logview];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)loadEmail {
    
    //获取用户绑定的邮箱
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler sendVerificationUserEmailWithUserId:[Common readAppDataForKey:KEY_SIGNIN_USER_UID] success:^(NSDictionary *verificationDictionary) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([Common isObjectNull:verificationDictionary]) {
                [STUserAccountHandler userProfile].email = @"未绑定邮箱";
            } else {
                [STUserAccountHandler userProfile].email = verificationDictionary[@"email"];
            }
            [self.tableView.mj_header endRefreshing];
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        });
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        });
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma ---
#pragma mark - UITableViewDataSource/UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 2;
    } else if (section == 3) {
        return 2;
    } else if (section == 4) {
        return 1;
    } else if (section == 5) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 105;
        
    } else {
        
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 10;
        
    } else {
        
        return 0.1f;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* ID = @"mainCell";
    myViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"myViewCell" owner:self options:nil] lastObject];
    }
    
    if (indexPath.section == 0) {
        
        UserHeadViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserHeadViewTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserHeadViewTableViewCell" owner:self options:nil] lastObject];
        }
        cell.userProfile = STUserAccountHandler.userProfile;
        return cell;
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            [cell.leftImage setImage:[UIImage imageNamed:@"two_code.png"]];
            [cell.titleLabel setText:@"我的二维码"];
        } else if (indexPath.row == 1) {
            [cell.leftImage setImage:[UIImage imageNamed:@"scanning"]];
            [cell.titleLabel setText:@"扫一扫"];
        } else if (indexPath.row == 2) {
            [cell.leftImage setImage:[UIImage imageNamed:@"scanning"]];
            [cell.titleLabel setText:@"红包"];
        }
         return cell;
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            [cell.leftImage setImage:[UIImage imageNamed:@"securityCenter.png"]];
            [cell.titleLabel setText:@"安全中心"];
        } else if (indexPath.row == 1) {
            [cell.leftImage setImage:[UIImage imageNamed:@"setUp.png"]];
            [cell.titleLabel setText:@"设置"];
        }
        return cell;
        
    } else if (indexPath.section == 3 ) {
        
        if (indexPath.row == 0) {
            [cell.leftImage setImage:[UIImage imageNamed:@"Unknown.png"]];
            [cell.titleLabel setText:@"《用户协议》"];
        } else {
            [cell.leftImage setImage:[UIImage imageNamed:@"xieyi"]];
            [cell.titleLabel setText:@"《隐私保护》"];
        }
        return cell;
    
    } else if (indexPath.section == 4 ) {
            
        [cell.leftImage setImage:[UIImage imageNamed:@"about_us.png"]];
        [cell.titleLabel setText:@"关于30000天"];
        return cell;
    
    } else if (indexPath.section == 5 ) {
        
        LogoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LogoutTableViewCell" owner:self options:nil] lastObject];
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        UserInfoViewController *user = [[UserInfoViewController alloc] init];
        user.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:user animated:YES];
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            QuickResponseCodeViewController *controller = [[QuickResponseCodeViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else if (indexPath.row == 1) {
            QRReaderViewController *controller = [[QRReaderViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            SecurityViewController *stc = [[SecurityViewController alloc] init];
            stc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:stc animated:YES];
        } else if (indexPath.row == 1) {
            SetUpViewController *suc = [[SetUpViewController alloc] init];
            suc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:suc animated:YES];
        }
    } else if (indexPath.section == 3) {
        
        AgreementWebViewController *controller = [[AgreementWebViewController alloc] init];
        if (indexPath.row == 0) {
            controller.type = 0;
        } else {
            controller.type = 1;
        }
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 4) {
        AboutTableViewController *controller = [[AboutTableViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 5) {
        [self cancelAction];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)cancelAction {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定注销？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //***********退出登录  *****/
        [Common removeAppDataForKey:KEY_SIGNIN_USER_UID];
        [Common removeAppDataForKey:KEY_SIGNIN_USER_NAME];
        [Common removeAppDataForKey:KEY_SIGNIN_USER_PASSWORD];
        [Common removeAppDataForKey:KEY_LOGIN_TYPE];
        [Common readAppIntegerDataForKey:KEY_IS_THIRDPARTY];
        
        [[CDChatManager sharedManager] closeWithCallback: ^(BOOL succeeded, NSError *error) {
        }];
        
        //清空推送别名
        [JPUSHService setTags:nil alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags, iAlias);
        }];
        
        SignInViewController *logview = [[SignInViewController alloc] init];
        STNavigationController *navigationController = [[STNavigationController alloc] initWithRootViewController:logview];
        [self presentViewController:navigationController animated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    [STNotificationCenter removeObserver:self name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
