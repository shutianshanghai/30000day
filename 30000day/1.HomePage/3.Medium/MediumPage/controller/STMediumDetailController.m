//
//  STMediumDetailController.m
//  30000day
//
//  Created by GuoJia on 16/8/3.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "STMediumDetailController.h"
#import "STSettingView.h"
#import "STMediumDetailModel.h"
#import "UIImage+WF.h"
#import "MTProgressHUD.h"
#import "STMediumModel+category.h"

@interface STMediumDetailController ()

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) STSettingView *settingView;

@end

@implementation STMediumDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];//配置UI
    [self getWeMediaDetail];//获取详情
}

- (void)getWeMediaDetail {
    
    if (self.isOriginWedia) {//原创的
        
        [STDataHandler sendGetWeMediaDetailWithUserId:STUserAccountHandler.userProfile.userId weMediaId:self.mediumMessageId shareId:nil success:^(STMediumDetailModel *model) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:model.linkUrl]];
                [self.webView loadRequest:request];
            });
            
        } failure:^(NSError *error) {
            [self showToast:[Common errorStringWithError:error optionalString:@"请求服务器失败"]];
        }];
        
    } else {
     
        [STDataHandler sendGetWeMediaDetailWithUserId:STUserAccountHandler.userProfile.userId weMediaId:[self.mediaModel getOriginMediumModel].mediumMessageId shareId:self.mediumMessageId success:^(STMediumDetailModel *model) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:model.linkUrl]];
                [self.webView loadRequest:request];
            });
            
        } failure:^(NSError *error) {
            [self showToast:[Common errorStringWithError:error optionalString:@"请求服务器失败"]];
        }];
    }
}

- (void)configUI {
    //1.title
    self.title = @"自媒体正文";
    
    //2.settingView
    STSettingView *settingView = [[STSettingView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - [STSettingView heightView:self.mediaModel], self.view.width, [STSettingView heightView:self.mediaModel])];
    settingView.delegate = self;
    [settingView cofigViewWithModel:self.mediaModel];
    [self.view addSubview:settingView];
    self.settingView = settingView;
    
    //3.webView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,64, SCREEN_WIDTH, SCREEN_HEIGHT - [STSettingView heightView:self.mediaModel] - 64)];
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:webView];
    self.webView = webView;
    
    //4.lineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - [STSettingView heightView:self.mediaModel], SCREEN_WIDTH, 0.7f)];
    lineView.backgroundColor = RGBACOLOR(200, 200, 200, 1);
    [self.view addSubview:lineView];
    
    //5.rightButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[[UIImage imageNamed:@"icon_more"] imageWithTintColor:LOWBLUECOLOR] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 28.0f, 22.0f);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightButtonAction {
    
    UIAlertController *alertControlller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_first = [UIAlertAction actionWithTitle:@"删除自媒体" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull   action) {
        
        [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
        
        if (self.isOriginWedia) {//原创的
            
            [STDataHandler sendDeleteWemediaUserId:STUserAccountHandler.userProfile.userId shareId:nil wemediaId:self.mediumMessageId success:^(BOOL success) {
                [self showToast:@"删除成功"];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.deleteBock) {
                    self.deleteBock();
                }
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
            } failure:^(NSError *error) {
                [self showToast:[Common errorStringWithError:error optionalString:@"删除失败"]];
            }];
            
        } else {
            
            [STDataHandler sendDeleteWemediaUserId:STUserAccountHandler.userProfile.userId shareId:self.mediumMessageId wemediaId:nil success:^(BOOL success) {
                
                [self showToast:@"删除成功"];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.deleteBock) {
                    self.deleteBock();
                }
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
            } failure:^(NSError *error) {
                [self showToast:[Common errorStringWithError:error optionalString:@"删除失败"]];
            }];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    if ([self.writerId isEqualToNumber:STUserAccountHandler.userProfile.userId]) {//自己发的自媒体才能去删除
        [alertControlller addAction:action_first];
    }
    
    [alertControlller addAction:cancelAction];
    [self presentViewController:alertControlller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
