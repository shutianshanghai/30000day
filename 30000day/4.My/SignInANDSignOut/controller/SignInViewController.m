//
//  SignInViewController.m
//  30000天
//
//  Created by 30000天_001 on 14-8-21.
//  Copyright (c) 2014年 30000天_001. All rights reserved.
//

#import "SignInViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TextFieldCellTableViewCell.h"
#import "SMSVerificationViewController.h"
#import "ChooseVerifyWayViewController.h"
#import "UserProfile.h"

@interface SignInViewController () {
    
    CGFloat textH;
    
}

@property (nonatomic, copy) NSString *cityName;

@property (nonatomic, copy) NSString *str;

@property (nonatomic,strong)UITableView* tableview;

@property (nonatomic,strong)NSMutableArray *userlognamepwd;

@property (nonatomic,assign)CGRect selectedTextFieldRect;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;

    self.navigationItem.title = @"登录";
    
    self.textSubView.layer.borderWidth = 1.0;
    
    self.textSubView.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.sina.layer.borderWidth = 1.0;
    
    self.sina.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.sina.layer.cornerRadius = 6;
    
    self.sina.layer.masksToBounds = YES;
    
    self.qq.layer.borderWidth = 1.0;
    
    self.qq.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.qq.layer.cornerRadius = 6;
    
    self.qq.layer.masksToBounds = YES;
    
    self.water.layer.borderWidth = 1.0;
    
    self.water.layer.borderColor = [UIColor colorWithRed:214.0/255 green:214.0/255.0 blue:214.0/255 alpha:1.0].CGColor;
    
    self.water.layer.cornerRadius = 6;
    
    self.water.layer.masksToBounds = YES;
    
    self.loginBtn.layer.cornerRadius = 6;
    
    self.loginBtn.layer.masksToBounds = YES;
    
    [self.lockPassWord addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    
    [self.lockPassWord addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    _userNameTF.tag = 1;
    
    _userPwdTF.tag = 2;
    
    [self textFielddidload];
}

#pragma mark - 加载历史记录
- (void)textFielddidload {
    
    [self.userNameTF setDelegate:self];
    
    [self.userPwdTF setDelegate:self];
    
    _userlognamepwd = [NSMutableArray arrayWithArray:[Common readAppDataForKey:USER_ACCOUNT_ARRAY]];
    
    if (_userlognamepwd.count > 0) {
        
        _tableview = [[UITableView alloc]init];
        
        _tableview.hidden = YES;
        
        [self.view addSubview:_tableview];
        
        _tableview.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableview attribute:NSLayoutAttributeWidth relatedBy:0 toItem:self.userNameTF attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableview attribute:NSLayoutAttributeLeft relatedBy:0 toItem:self.userNameTF attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableview attribute:NSLayoutAttributeTop relatedBy:0 toItem:self.userNameTF attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        _userNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableview attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:132]];
        
        _userNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [_tableview.layer setCornerRadius:8.0];
        
        [_tableview setDelegate:self];
        
        [_tableview setDataSource:self];
        
        _tableview.layer.borderWidth = 0.5;
        
        _tableview.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 找回密码
- (IBAction)findPwd:(UIButton *)sender {
    
    ChooseVerifyWayViewController *controller = [[ChooseVerifyWayViewController alloc] init];

    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 登录
- (IBAction)signInButtonClick:(UIButton *)sender {
    
    [self beginSignIn];
}

//开始登录
- (void)beginSignIn {
    
    if ([Common isObjectNull:_userNameTF.text]) {
        
        [self showToast:@"请完善账号"];
        
        return;
    }
    
    if ([Common isObjectNull:_userPwdTF.text]) {
        
        [self showToast:@"请完善密码"];
        
        return;
    }
    
    [self showHUDWithContent:@"正在登录" animated:YES];
    
    [self.view endEditing:YES];
    
    [self.dataHandler postSignInWithPassword:_userPwdTF.text
                                   loginName:_userNameTF.text
                                     success:^(BOOL success) {
                                         
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         
                                         [self hideHUD:YES];
                                         
                                     } failure:^(NSError *error) {
                                         
                                         [self hideHUD:YES];
                                         
                                         [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
                                         
                                     }];
}


#pragma mark - 账号密码历史记录tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _userlognamepwd.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = _userlognamepwd[indexPath.row];
    
    NSString *log = [dic objectForKey:KEY_SIGNIN_USER_NAME];
    
    TextFieldCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
    
    if (cell == nil) cell=[[NSBundle mainBundle]loadNibNamed:@"TextFieldCellTableViewCell" owner:self options:nil][0];
    
    UIButton *deletebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [deletebtn setTitle:@"x" forState:UIControlStateNormal];
    
    [deletebtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [deletebtn setTag:indexPath.row];
    
    [deletebtn addTarget:self action:@selector(deletebt:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell addSubview:deletebtn];
    
    deletebtn.translatesAutoresizingMaskIntoConstraints=NO;

    [cell addConstraint:[NSLayoutConstraint constraintWithItem:deletebtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:deletebtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:deletebtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    
    [cell addConstraint:[NSLayoutConstraint constraintWithItem:deletebtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    cell.textLabel.text = log;
    
    return cell;
}

- (void)deletebt:(UIButton *)sender {
    
    [_userlognamepwd removeObjectAtIndex:sender.tag];
    
    [Common saveAppDataForKey:USER_ACCOUNT_ARRAY withObject:_userlognamepwd];
    
    [_tableview reloadData];
    
    if (_userlognamepwd.count == 0) {
        
        [_tableview removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = _userlognamepwd[indexPath.row];
    
    NSString *log = [dic objectForKey:KEY_SIGNIN_USER_NAME];
    
    NSString *pass = [dic objectForKey:KEY_SIGNIN_USER_PASSWORD];
    
    _userNameTF.text = log;
    
    _userPwdTF.text = pass;
    
    _tableview.hidden = YES;
}

#pragma mark - 键盘的代理方法以及键盘消失的方法
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.lockPassWord.hidden = NO;
    
    if (textField.tag == 1) {
        
        _tableview.hidden=NO;
        
        textH=self.tableview.frame.size.height;
        
    } else {
        
        textH=0;
    }
    
    self.selectedTextFieldRect=textField.frame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag) {
        
        _tableview.hidden = YES;
        
    }
    
    self.lockPassWord.hidden = YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField.tag) {
        
        _userPwdTF.text=@"";
    }
    //可以设置在特定条件下才允许清除内容
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.userNameTF) {
        
        [self.userNameTF resignFirstResponder];
        
        [self.userPwdTF becomeFirstResponder];
        
    } else {
        
        [self.view endEditing:YES];
        
        //开始登录
        [self beginSignIn];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

- (void)touchDown:(UIButton *)sender {
     
    [sender setBackgroundImage:[UIImage imageNamed:@"DisplayPassword.png"] forState:UIControlStateNormal];
    
    [self.userPwdTF setSecureTextEntry:NO];
}

-(void)touchUpInside:(UIButton *)sender{
    
    [sender setBackgroundImage:[UIImage imageNamed:@"hidePassword.png"] forState:UIControlStateNormal];
    
    [self.userPwdTF setSecureTextEntry:YES];
}

#pragma mark - 跳转注册
- (IBAction)regitView:(UIButton *)sender {
    
    SMSVerificationViewController *controller = [[SMSVerificationViewController alloc] init];
    
    controller.isSignOut = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
