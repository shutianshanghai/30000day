//
//  ThirdPartyLandingViewController.m
//  30000day
//
//  Created by wei on 16/5/3.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "ThirdPartyLandingViewController.h"
#import "MTProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "STTabBarViewController.h"

#define IdentityCount 60

@interface ThirdPartyLandingViewController () <UITextFieldDelegate> {
    int count;
}

@property (nonatomic) NSTimer *timer;
@property (nonatomic,assign)CGRect selectedTextFieldRect;
@property (nonatomic,copy) NSString *mobileToken;//校验后获取的验证码

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *sms;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIButton *smsBtn;
- (IBAction)nextBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *textSubView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *temporarilyButton;
@property (weak, nonatomic) IBOutlet UILabel *loginTypeLable;
@property (weak, nonatomic) IBOutlet UIImageView *loginImageView;
@property (weak, nonatomic) IBOutlet UILabel *loginName;
@property (weak, nonatomic) IBOutlet UIView *loginSupView;
@property (weak, nonatomic) IBOutlet UILabel *promptLable;

@end

@implementation ThirdPartyLandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"手机绑定";
    if (self.isConceal) {
        self.temporarilyButton.hidden = YES;
        self.loginSupView.hidden = YES;
    }
    
    if ([self.type isEqualToString:KEY_GUEST]) {
        self.loginSupView.hidden = YES;
    }
    
    [self.phoneNumber setDelegate:self];
    [self.sms setDelegate:self];
    [self.passWord setDelegate:self];
    
    self.textSubView.layer.borderWidth = 1.0;
    self.textSubView.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.nextBtn.layer.cornerRadius = 6;
    self.nextBtn.layer.masksToBounds = YES;
    
    self.loginTypeLable.text = self.type;
    [self.loginImageView sd_setImageWithURL:[NSURL URLWithString:self.url]];
    self.loginName.text = self.name;
}

#pragma mark - 绑定
- (IBAction)nextBtn:(UIButton *)sender {
    
    if ([Common isObjectNull:self.phoneNumber.text]) {
        [self showToast:@"手机号码不能为空"];
        return;
    }
    
    if ([Common isObjectNull:self.sms.text]) {
        [self showToast:@"验证码不能为空"];
        return;
    }
    
    if ([Common isObjectNull:self.passWord.text]) {
        [self showToast:@"密码不能为空"];
        return;
    }
    
    if ([self.type isEqualToString:KEY_GUEST]) {//游客
        
        if ([Common isObjectNull:self.uid]) {
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            [self showToast:@"访客信息获取失败,请重新登录"];
            return;
        }
        
    } else if ([self.type isEqualToString:KEY_QQ] || [self.type isEqualToString:KEY_SINA] || [self.type isEqualToString:KEY_WECHAT]) {//第三方登录
        if ([Common isObjectNull:self.uid] || [Common isObjectNull:self.name] || [Common isObjectNull:self.url]) {
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            [self showToast:@"第三方信息获取失败，请重新授权"];
            return;
        }
    }
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler postVerifySMSCodeWithPhoneNumber:self.phoneNumber.text smsCode:self.sms.text success:^(NSString *mobileToken) {
        
        [STDataHandler sendBindRegisterWithMobile:self.phoneNumber.text nickName:self.name accountNo:self.uid password:self.passWord.text headImg:self.url type:self.type success:^(NSString *success) {
            
            if (success.boolValue) {
                
                NSNumber *number = @0;
                NSString *password = nil;
                NSString *loginName = nil;
                if ([self.type isEqualToString:KEY_GUEST]) {
                    number = @2;
                    loginName = self.uid;
                } else if ([self.type isEqualToString:KEY_QQ] || [self.type isEqualToString:KEY_SINA] || [self.type isEqualToString:KEY_WECHAT]) {
                    number = @1;
                    loginName = self.uid;
                } else {
                    password = self.passWord.text;
                    loginName = [Common readAppDataForKey:KEY_SIGNIN_USER_NAME];
                }
                
                [self.dataHandler postSignInWithPassword:password
                                               loginName:loginName
                                      isPostNotification:YES
                                        isFromThirdParty:number
                                                    type:self.type
                                                 success:^(BOOL success) {
                                                    
                                                     [Common saveAppDataForKey:KEY_LOGIN_TYPE withObject:self.type];
                                                     [self textFiledResignFirst];
                                                     [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                     
                                                     if (!self.isConceal) {
                                                         [self.tabBarController setSelectedIndex:0];
                                                         [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                                         [self.navigationController popViewControllerAnimated:NO];
                                                     } else {
                                                         [self.navigationController popViewControllerAnimated:YES];
                                                     }

                                                 } failure:^(NSError *error) {
                                                     [self textFiledResignFirst];
                                                     [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                     [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                                 }];
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self textFiledResignFirst];
                    [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                    [self showToast:@"绑定/注册失败"];
                });
            }
            
        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                [self showToast:@"服务器繁忙"];
            });
        }];
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            [self showToast:@"验证失败"];
        });
    }];
}

#pragma mark - 暂不绑定
- (IBAction)notBind:(UIButton *)sender {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    
    if ([Common isObjectNull:self.type]) {//为空表示是非第三方、访客
        
        [self textFiledResignFirst];
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        [self.tabBarController setSelectedIndex:0];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self.navigationController popViewControllerAnimated:NO];
        
    } else {//不为空表示第三方、访客
        
        [STDataHandler sendCheckRegisterForThirdParyWithAccountNo:self.uid type:self.type success:^(NSString *success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (success.boolValue) {
                    [self signInWithUid:self.uid];
                } else {
                    
                    if ([self.type isEqualToString:KEY_GUEST]) {//游客
                        
                    } else if ([self.type isEqualToString:KEY_QQ] || [self.type isEqualToString:KEY_SINA] || [self.type isEqualToString:KEY_WECHAT]) {//第三方登录
                        
                        if ([Common isObjectNull:self.uid] || [Common isObjectNull:self.name] || [Common isObjectNull:self.url]) {
                            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                            [self showToast:@"第三方信息获取失败，请重新授权"];
                            return;
                        }
                    }
                    
                    [STDataHandler sendRegisterForThirdParyWithAccountNo:self.uid nickName:self.name headImg:self.url type:self.type success:^(NSString *success) {
                        
                        if (success.boolValue) {
                            [self signInWithUid:self.uid];
                        }
                        
                    } failure:^(NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                        });
                    }];
                }
            });
            
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            });
        }];
    }
}

- (void)signInWithUid:(NSString *)loginName {
    
    NSNumber *number = @1;//默认是第三方登录
    if ([self.type isEqualToString:KEY_GUEST]) {
        number = @2;//访客登录
    }
    
    [self.dataHandler postSignInWithPassword:nil
                                   loginName:loginName
                          isPostNotification:YES
                            isFromThirdParty:number
                                        type:self.type
                                     success:^(BOOL success) {
                                         
                                         [Common saveAppDataForKey:KEY_LOGIN_TYPE withObject:self.type];
                                         
                                         [self textFiledResignFirst];
                                         [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                         [self.tabBarController setSelectedIndex:0];
                                         [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                         [self.navigationController popViewControllerAnimated:NO];
                                         
                                     } failure:^(NSError *error) {
                                         
                                         [self textFiledResignFirst];
                                         [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                         [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                         
                                     }];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 1) {
        
        [self.phoneNumber resignFirstResponder];
        [self.passWord resignFirstResponder];
        [self.sms becomeFirstResponder];
        
    } else if(textField.tag == 2) {
        
        [self.phoneNumber resignFirstResponder];
        [self.passWord becomeFirstResponder];
        [self.sms resignFirstResponder];
        
    } else {
        
        [self.phoneNumber resignFirstResponder];
        [self.passWord resignFirstResponder];
        [self.sms resignFirstResponder];
        [self nextBtn:nil];
    }
    
    return YES;
}

#pragma mark - 短信验证 smsBtn倒计时
- (IBAction)smsVerificationBtn:(id)sender {
    
    if (self.phoneNumber.text == nil || [self.phoneNumber.text isEqualToString:@""]) {
        
        [self showToast:@"请输入手机号"];
        return;
    }

    //调用短信验证接口
    [STDataHandler getVerifyWithPhoneNumber:self.phoneNumber.text
                                          type:@(3)
                                       success:^(NSString *responseObject) {
                                           
                                           count = IdentityCount;
                                           _smsBtn.enabled = NO;
                                           [_smsBtn setTitle:[NSString stringWithFormat:@"%i秒后重发",count--] forState:UIControlStateNormal];
                                           _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatAction) userInfo:nil repeats:YES];
                                           
                                           //检查手机号是否已经注册
                                           [STDataHandler sendcheckRegisterForMobileWithmobile:self.phoneNumber.text success:^(NSString *success) {
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                   if (success.boolValue) {
                                                       
                                                       [self.promptLable setText:@"该手机号已被注册，继续操作将绑定至当前账号"];
                                                       [self.promptLable setTextColor:[UIColor redColor]];
                                                       
                                                   } else {
                                                       
                                                       [self.promptLable setText:@"为了您的账号安全，建议您绑定手机号"];
                                                       [self.promptLable setTextColor:[UIColor blackColor]];
                                                   }
                                               });
                                           } failure:^(NSError *error) {

                                           }];
                                       } failure:^(NSString *error) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self showToast:error];
                                           });
                                       }];
}

- (void)repeatAction {
    [_smsBtn setTitle:[NSString stringWithFormat:@"%i秒后重发",count--] forState:UIControlStateNormal];
    if (count == -1) {
        _smsBtn.enabled = YES;
        [_smsBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        count = IdentityCount;
        [_timer invalidate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self textFiledResignFirst];
}

- (void)textFiledResignFirst {

    [self.phoneNumber resignFirstResponder];
    [self.sms resignFirstResponder];
    [self.passWord resignFirstResponder];
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
