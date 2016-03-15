//
//  regitViewCtr.m
//  30000天
//
//  Created by wei on 15/11/19.
//  Copyright © 2015年 wei. All rights reserved.
//

#import "SignOutViewController.h"
#import "SignInViewController.h"

@interface SignOutViewController () <QGPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userPwdTxt;

@property (weak, nonatomic) IBOutlet UITextField *ConfirmPasswordTxt;

@property (weak, nonatomic) IBOutlet UITextField *userNickNameTxt;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (weak, nonatomic) IBOutlet UIView *passwordTextSubView;

@property (weak, nonatomic) IBOutlet UIView *niceNameTextSubView;

@end

@implementation SignOutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"闪电注册";
    
    self.passwordTextSubView.layer.borderWidth = 1.0;
    
    self.passwordTextSubView.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.niceNameTextSubView.layer.borderWidth = 1.0;
    
    self.niceNameTextSubView.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.submitBtn.layer.cornerRadius = 6;
    
    self.submitBtn.layer.masksToBounds = YES;
    
    _userNickNameTxt.delegate = self;
    
    self.submitBtn.layer.borderWidth = 0.5;
    
    self.submitBtn.layer.borderColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0].CGColor;
        
    [self.userPwdTxt setDelegate:self];
    
    [self.ConfirmPasswordTxt setDelegate:self];
    
    [self.userNickNameTxt setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)tapAction {
    
    [self.view endEditing:YES];
}

//选择生日
//- (void)chooseBirthday {
//    
//    [self.view endEditing:YES];
//    
//    QGPickerView *picker = [[QGPickerView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - 250, SCREEN_WIDTH, 250)];
//    
//    picker.delegate = self;
//    
//    picker.titleText = @"生日选择";
//    
//    self.birthdayString = @"";
//    
//    //3.赋值
//    [Common getYearArrayMonthArrayDayArray:^(NSMutableArray *yearArray, NSMutableArray *monthArray, NSMutableArray *dayArray) {
//        
//        NSArray *dateArray = [[Common getCurrentDateString] componentsSeparatedByString:@"-"];
//        
//        NSString *monthStr = dateArray[1];
//        
//        NSString *dayStr = dateArray[2];
//        
//        if (monthStr.length == 2 && [[monthStr substringToIndex:1] isEqualToString:@"0"]) {
//            
//            monthStr = [NSString stringWithFormat:@"%@月",[monthStr substringFromIndex:1]];
//            
//        } else {
//            
//            monthStr = [NSString stringWithFormat:@"%@月",monthStr];
//        }
//        
//        if (dayStr.length == 2 && [[dayStr substringToIndex:1] isEqualToString:@"0"]) {
//            
//            dayStr = [NSString stringWithFormat:@"%@日",[dayStr substringFromIndex:1]];
//            
//        } else {
//            
//            dayStr = [NSString stringWithFormat:@"%@日",dayStr];
//        }
//        
//        //显示QGPickerView
//        [picker showOnView:[UIApplication sharedApplication].keyWindow withPickerViewNum:3 withArray:yearArray withArray:monthArray withArray:dayArray selectedTitle:[NSString stringWithFormat:@"%@年",dateArray[0]] selectedTitle:monthStr selectedTitle:dayStr];
//        
//    }];
//  
//}

//#pragma mark -- QGPickerViewDelegate
//
//- (void)didSelectPickView:(QGPickerView *)pickView value:(NSString *)value indexOfPickerView:(NSInteger)index indexOfValue:(NSInteger)valueIndex {
//
//    self.birthdayString = [self.birthdayString stringByAppendingString:value];
//    
//    [self.birthdayButton setTitle:self.birthdayString forState:UIControlStateNormal];
//    
//    if (index == 3) {
//        
//        NSArray *array  = [self.birthdayString componentsSeparatedByString:@"年"];
//        
//        NSArray *array_second = [(NSString *)array[1] componentsSeparatedByString:@"月"];
//        
//        NSArray *array_third = [(NSString *)array_second[1] componentsSeparatedByString:@"日"];
//        
//        //保存之前选择的生日
//        self.birthdayString = [NSString stringWithFormat:@"%@-%@-%@",array[0],[self addZeroWithString:array_second[0]],[self addZeroWithString:array_third[0]]];
//
//    }
//}
//
//- (NSString *)addZeroWithString:(NSString *)string {
//    
//    if ([string length] == 1) {
//        
//        return string = [NSString stringWithFormat:@"0%@",string];
//        
//    } else {
//        
//        return string;
//    }
//}

#pragma mark - 注册验证
- (IBAction)regitF:(UIButton *)sender {
    
    if( [_userPwdTxt.text isEqualToString:@""] ) {
        
        [self showToast:@"密码不能为空"];
        
        return;
    }
    
   if (![_userPwdTxt.text isEqualToString:_ConfirmPasswordTxt.text]){
       
        [self showToast:@"密码不一致，请重新确认"];
        
        return;
    }
    
    BOOL ok= [self isIncludeSpecialCharact:self.userNickNameTxt.text];
    
    if (ok == YES) {
        [self showToast:@"昵称不允许包含特殊字符，请重新输入！"];
    } else {
        [self registerUser];
    }
    
    
}

#pragma mark - 注册
- (void)registerUser {
    
    [self.view endEditing:YES];
    
    //调用注册接口
    [self.dataHandler postRegesiterWithPassword:_userPwdTxt.text
                                    phoneNumber:_PhoneNumber
                                       nickName:_userNickNameTxt.text
                                    mobileToken:self.mobileToken//校验后获取的验证码
                                        success:^(BOOL success) {
                                            
                                           [self showToast:@"注册成功"];
                                            
                                            UIStoryboard *mainStroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                            
                                            UIViewController *controller = mainStroyboard.instantiateInitialViewController;
                                            
                                            UIWindow *window = [UIApplication sharedApplication].keyWindow;
                                            
                                            window.rootViewController = controller;
                                            
                                        }
                                        failure:^(NSError *error) {
                                            
                                            [self showToast:@"注册失败"];
                                            
                                        }];
    
}


- (BOOL) isIncludeSpecialCharact: (NSString *)str {
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @"~￥#&*<>《》()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）——+|《》$_€"]];
    if (urgentRange.location == NSNotFound){
        return NO;
    }
    return YES;
}

#pragma mark - 键盘return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
