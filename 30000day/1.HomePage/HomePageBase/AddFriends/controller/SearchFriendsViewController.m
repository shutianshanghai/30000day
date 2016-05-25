//
//  SearchFriendsViewController.m
//  30000day
//
//  Created by GuoJia on 16/2/17.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "SearchResultTableViewCell.h"
#import "UserInformationModel.h"
#import "NSString+URLEncoding.h"
#import "MTProgressHUD.h"
#import "LZPushManager.h"
#import "NewFriendManager.h"

@interface SearchFriendsViewController () <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchBackgroundView;//搜索框的背景视图

@property (weak, nonatomic) IBOutlet UIView *backgroundView;//模态视图

@property (weak, nonatomic) IBOutlet UITableView *tableView;//主表格视图

@property (nonatomic,strong) NSMutableArray *searchResultArray;//搜索结果数组

@property (nonatomic,assign) BOOL isSearch;//搜索状态

@property (weak, nonatomic) IBOutlet UIView *noResultView;//无搜索结果的时候显示的视图

@property (weak, nonatomic) IBOutlet UITextField *textField;//搜索的textField

@end

@implementation SearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBackgroundView.layer.cornerRadius = 5;
    
    self.searchBackgroundView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    
    [self.backgroundView addGestureRecognizer:tap];
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    self.isSearch = NO;//刚进来的时候不是搜索状态
    
    self.noResultView.hidden = YES;
    
    [self.textField becomeFirstResponder];
}

//点击事件
- (void)tapAction {
    
    [self cancelControllerAndView];
}

//移除本控制器和本视图
- (void)cancelControllerAndView {
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self removeFromParentViewController];
    
    [self.view removeFromSuperview];
    
    [self.view endEditing:YES];
}

//取消按钮点击方法
- (IBAction)cancelAction:(id)sender {
    
    [self cancelControllerAndView];
}

#pragma ---
#pragma mark --- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //意思是如果搜素的string为空那么就是不处于搜索状态，反之亦然
    self.isSearch = [Common isObjectNull:self.textField.text] ? NO : YES;
    
    if (self.isSearch) {
        
        //只要开始搜索先隐藏noResultView
        self.noResultView.hidden = YES;
        
        //只要开始搜索先隐藏backgroundView
        self.backgroundView.hidden = YES;
        
        [self.view endEditing:YES];
        
        //开始搜索
        [STDataHandler sendSearchUserRequestWithNickName:[self.textField.text urlEncodeUsingEncoding:NSUTF8StringEncoding]
                                              currentUserId:[Common readAppDataForKey:KEY_SIGNIN_USER_UID]
                                                    success:^(NSMutableArray *dataArray) {
            
            self.searchResultArray = [NSMutableArray arrayWithArray:dataArray];
            
            self.noResultView.hidden = self.searchResultArray.count ? YES : NO;
            
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            
            self.searchResultArray = [NSMutableArray array];
            
            self.noResultView.hidden = self.searchResultArray.count ? YES : NO;
            
            [self.tableView reloadData];
        }];
        
    } else {
        
        //不是搜索状态隐藏noResultView
        self.noResultView.hidden = YES;
        
        //不是搜索状态显示backgroundView
        self.backgroundView.hidden = NO;
    }
    
    [self.tableView reloadData];
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma ---
#pragma mark --- UITableViewDelegate / UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.isSearch ? self.searchResultArray.count : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *searchResultIdentifier = @"SearchResultTableViewCell";
    
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchResultIdentifier];
    
    if (cell == nil) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:searchResultIdentifier owner:self options:nil] lastObject];
    }
    
    cell.userInformationModel = self.searchResultArray[indexPath.row];
    
    __weak typeof(cell) weakCell = cell;
    
    //点击添加按钮回调
    [cell setAddUserBlock:^(UserInformationModel *userInformationModel){
        
        [self.view endEditing:YES];
        
        [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
        //添加好友,接口, @1请求   @2接受   @3拒绝
        [STDataHandler sendPushMessageWithCurrentUserId:STUserAccountHandler.userProfile.userId
                                                       userId:userInformationModel.userId
                                                    messageType:@1
                                                      success:^(BOOL success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            [NewFriendManager subscribePresenceToUserWithUserProfile:userInformationModel andCallback:^(BOOL succeeded, NSError *error) {
              
            }];

            
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
                [self showToast:@"请求发送成功"];
            
            });
                                                          
                        
        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
                [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                
                weakCell.addButton.hidden = NO;

            });
            
        }];
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 72.1f;
}

- (void)dealloc {
    
    [STNotificationCenter removeObserver:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
