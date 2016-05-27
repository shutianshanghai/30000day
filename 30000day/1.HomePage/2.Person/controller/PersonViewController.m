//
//  PersonViewController.m
//  30000day
//
//  Created by GuoJia on 16/1/29.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonHeadView.h"
#import "PersonTableViewCell.h"
#import "UserInformationModel.h"
#import "PersonDetailViewController.h"
#import "PersonInformationsManager.h"
#import "NewFriendsViewController.h"
#import "NewFriendManager.h"
#import "AddFriendsViewController.h"
#import "MailListManager.h"
#import "MailListTableViewCell.h"
#import "ChineseString.h"
#import "MTProgressHUD.h"

@interface PersonViewController () <UITableViewDataSource,UITableViewDelegate> {
    
    NSMutableArray *_dataArray;
}

@property (nonatomic,strong) PersonTableViewCell *firstCell;

@property (nonatomic,assign) NSInteger sortTab;

@end

@implementation PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewStyle = STRefreshTableViewGroup;
    
    self.tableView.frame = CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT - 50);
    
    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    
    [self showHeadRefresh:YES showFooterRefresh:NO];
    
    //监听个人信息管理模型发出的通知
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];
    //监听成功添加好友发出的通知
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STUserAddFriendsSuccessPostNotification object:nil];
    //成功移除好友的时候发送的通知
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STUseDidSuccessDeleteFriendSendNotification object:nil];
    //当成功的更新好友的信息（好友的昵称、备注头像）所发出的通知
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STDidSuccessUpdateFriendInformationSendNotification object:nil];
    //成功的切换模式
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STUserDidSuccessChangeBigOrSmallPictureSendNotification object:nil];
    //别人同意加为好友
    [STNotificationCenter addObserver:self selector:@selector(loadCanApplyFriend) name:STDidApplyAddFriendSuccessSendNotification object:nil];
    //通讯录的信息有变
    [STNotificationCenter addObserver:self selector:@selector(reloadMainTableView) name:STDidSaveInFileSendNotification object:nil];
    
    [self reloadData];
    //设置右面的按钮
    UIBarButtonItem *addFriendItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"addFriends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(addFriendsAction)];
    
    self.navigationItem.rightBarButtonItem = addFriendItem;
    
    //有人请求加为好友
    [STNotificationCenter addObserver:self selector:@selector(changeState) name:STDidApplyAddFriendSendNotification object:nil];
}

- (void)changeState {
    
    [Common saveAppIntegerDataForKey:USER_BADGE_NUMBER withObject:1];
    
    self.firstCell.badgeView.hidden = NO;
    
    [[self navigationController] tabBarItem].badgeValue = @"";
} 


- (void)addFriendsAction {
    
    AddFriendsViewController *addfvc = [[AddFriendsViewController alloc] init];
    
    addfvc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:addfvc animated:YES];
}

- (void)reloadData {
    
    [self getMyFriends];
}

//下载可以请求的数据
- (void)loadCanApplyFriend {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    
    [[MailListManager shareManager] synchronizedMailList];
    
    [self reloadData];
}

- (void)reloadMainTableView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
    });
}

- (void)headerRefreshing {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    
    [[MailListManager shareManager] synchronizedMailList];
    
    [self reloadData];
}

//获取我的好友
- (void)getMyFriends {

    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    
    [STDataHandler getMyFriendsWithUserId:[NSString stringWithFormat:@"%@",STUserAccountHandler.userProfile.userId] order:[NSString stringWithFormat:@"%d",(int)self.sortTab] success:^(NSMutableArray *dataArray) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            _dataArray = dataArray;
            
            //给这个好友管理器赋值
            [PersonInformationsManager shareManager].informationsArray = dataArray;
            
            [self.tableView reloadData];
            
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

- (PersonTableViewCell *)firstCell {
    
    if (!_firstCell) {
        
        _firstCell = [[NSBundle mainBundle] loadNibNamed:@"PersonTableViewCell" owner:nil options:nil][2];
        
        _firstCell.badgeView.hidden = [Common readAppIntegerDataForKey:USER_BADGE_NUMBER] ? NO : YES;
        
        [[self navigationController] tabBarItem].badgeValue = [Common readAppBoolDataForkey:USER_BADGE_NUMBER] ? @"" : nil;
    }
    return _firstCell;
}

#pragma ---
#pragma mark ----- UITableViewDelegate/UITableViewDatasource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
     
        static NSString *headViewIndentifier = @"PersonHeadView";
        
        PersonHeadView *view = (PersonHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headViewIndentifier];
        
        if (view == nil) {
            
            view = [[[NSBundle mainBundle] loadNibNamed:headViewIndentifier owner:self options:nil] lastObject];
        }
        
        view.titleLabel.text = [NSString stringWithFormat:@"当前共有 %ld 位自己人哦！",(unsigned long)_dataArray.count];
        
        view.titleLabel.hidden = NO;
        
        [view setChangeStateBlock:^(UIButton *changeStatusButton) {
            
            [self.tableView reloadData];
            
            [STNotificationCenter postNotificationName:STUserDidSuccessChangeBigOrSmallPictureSendNotification object:nil];
            
        }];
        
        if (self.sortTab) {
        
            [view.sortButton setTitle:@"升序" forState:UIControlStateNormal];
            
            view.sortButton.selected = YES;
        
        } else {
            
            [view.sortButton setTitle:@"降序" forState:UIControlStateNormal];
        
            view.sortButton.selected = NO;
        }

        [view setSortButtonBlock:^(UIButton *button) {
            
            if (button.isSelected) {
                
                button.selected = NO;
                
                self.sortTab = 0;
                
                [button setTitle:@"降序" forState:UIControlStateNormal];
                
            } else {
                
                button.selected = YES;
                
                self.sortTab = 1;
                
                [button setTitle:@"升序" forState:UIControlStateNormal];
            }
            
            [self reloadData];
            
        }];

        
        if ([Common readAppIntegerDataForKey:IS_BIG_PICTUREMODEL]) {
            
            [view.changeStatusButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
            
            [view.changeStatusButton setTitle:@" 列表" forState:UIControlStateNormal];
            
        } else {
            
            [view.changeStatusButton setImage:[UIImage imageNamed:@"bigPicture.png"] forState:UIControlStateNormal];
            
            [view.changeStatusButton setTitle:@" 大图" forState:UIControlStateNormal];
        }
        
        return view;
        
    } else if(section == 1) {
        
        static NSString *headViewIndentifier = @"PersonHeadView";
        
        PersonHeadView *view = (PersonHeadView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headViewIndentifier];
        
        if (view == nil) {
            
            view = [[[NSBundle mainBundle] loadNibNamed:headViewIndentifier owner:self options:nil] lastObject];
        }
        
        view.titleLabel.text = @"可添加的好友";
        
        view.titleLabel.hidden = NO;
        
        view.changeStatusButton.hidden = YES;
        
        view.sortButton.hidden = YES;
        
        NSMutableArray *registerArray = [[[MailListManager shareManager] getModelArray] firstObject];
        
        if (registerArray.count) {
            
            return view;
            
        } else {
            
            return nil;
        }
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 44;
        
    } else if (section == 1) {
        
        NSMutableArray *registerArray = [[[MailListManager shareManager] getModelArray] firstObject];
        
        if (registerArray.count) {
            
            return 30.0f;
            
        } else {
            
            return 0.01f;
        }
    }
    
    return 25.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else if (section == 1) {
      
        NSMutableArray *registerArray = [[[MailListManager shareManager] getModelArray] firstObject];
        
        return registerArray.count;
        
    } else {
        
       return _dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 72.1f;
        
    } else if(indexPath.section == 1) {
        
        return 44.0f;
        
    } else {
        
        if ([Common readAppIntegerDataForKey:IS_BIG_PICTUREMODEL]) {
            
            return SCREEN_WIDTH + 75.0f;
            
        } else {
            
            return 72.1f;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        return self.firstCell;
        
    } else if (indexPath.section == 1) {
      
        MailListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailListTableViewCell"];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MailListTableViewCell" owner:self options:nil] lastObject];
        }
        
        NSMutableArray *registerArray = [[[MailListManager shareManager] getModelArray] firstObject];
        
        ChineseString *chineseString = registerArray[indexPath.row];
        
        cell.dataModel = chineseString;
        
        //按钮点击回调
        [cell setInvitationButtonBlock:^(UIButton *button) {
            
            if (button.tag) {
                
                //添加好友
                //添加好友,接口, @1请求   @2接受   @3拒绝
                if ([Common isObjectNull:STUserAccountHandler.userProfile.userId] || [Common isObjectNull:chineseString.userId]) {
                    
                    [self showToast:@"对方或自己的id为空"];
                    
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
                                                                   
                                                                   [NewFriendManager subscribePresenceToUserWithUserProfile:model andCallback:^(BOOL succeeded, NSError *error) {
                                                                       
                                                                       if (succeeded) {
                                                                           
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               
                                                                               [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                               
                                                                               [self showToast:@"请求发送成功"];
                                                                               
                                                                           });
                                                                           
                                                                       } else {
                                                                           
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               
                                                                               [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                                               
                                                                               [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                                                               
                                                                           });
                                                                       }

                                                                   }];
                                                                   
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
                
            }
        }];
        
        return cell;
        
    } else {
        
        if (![Common readAppIntegerDataForKey:IS_BIG_PICTUREMODEL]) {//小图
            
            static NSString *identifier = @"PersonTableViewCell";
            
            PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonTableViewCell" owner:nil options:nil][0];
            }
            
            cell.informationModel = _dataArray[indexPath.row];
            
            return cell;
            
        } else {//大图
            
            static NSString *identifier_big = @"PersonTableViewCell_big";
            
            PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier_big];
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonTableViewCell" owner:nil options:nil][1];
            }
            cell.informationModel_second = _dataArray[indexPath.row];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        NewFriendsViewController *controller = [[NewFriendsViewController alloc] init];
        
        controller.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:controller animated:YES];
        
        self.firstCell.badgeView.hidden = YES;
        
        [Common saveAppIntegerDataForKey:USER_BADGE_NUMBER withObject:0];
        
        [[self navigationController] tabBarItem].badgeValue = nil;
        
    } else if(indexPath.section == 1) {
        
        
    } else {
        
        PersonDetailViewController *controller = [[PersonDetailViewController alloc] init];
        
        controller.hidesBottomBarWhenPushed = YES;
        
        UserInformationModel *model = _dataArray[indexPath.row];
        
        controller.friendUserId = model.userId;
        
        controller.informationModel = model;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    [STNotificationCenter removeObserver:self name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STUserAddFriendsSuccessPostNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STUseDidSuccessDeleteFriendSendNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STDidSuccessUpdateFriendInformationSendNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STUserDidSuccessChangeBigOrSmallPictureSendNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STDidApplyAddFriendSuccessSendNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STDidSaveInFileSendNotification object:nil];
    
    _dataArray = nil;
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
