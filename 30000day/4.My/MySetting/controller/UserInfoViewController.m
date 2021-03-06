//
//  userInfoViewController.m
//  30000天
//
//  Created by wei on 16/1/19.
//  Copyright © 2016年 wei. All rights reserved.
//

#import "UserInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "HeadViewTableViewCell.h"
#import "AccountNumberTableViewCell.h"
#import "MTProgressHUD.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface UserInfoViewController () <UINavigationControllerDelegate,QGPickerViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)NSArray *titleArray;

@property (nonatomic,strong) UIImageView *portraitImageView;//cell上面的imageView的指针
@property (nonatomic,strong) UIImage * editorImage;//经过用户编辑后的图片
@property (nonatomic ,strong) UIImage *copareImage;//用来比较用户是否修改了图片
@property (nonatomic,copy) NSString *headImageURLString;


@property (nonatomic,copy) NSString *nickName;//用来比较用户是否修改了昵称
@property (nonatomic,copy) NSString *currentChooseNickName;//当前用户修改的昵称,如果没有修改那么，其值称为原来的昵称


@property (nonatomic,copy) NSNumber *gender;//用来比较用户是否修改了性别
@property (nonatomic,copy) NSNumber *currentChooseGender;//当前选择的性别


@property (nonatomic,copy) NSString *lastBirthdayString;//用来比较用户是否修改了生日
@property (nonatomic,copy) NSString *currentChooseBirthdayString;//当前选择的生日

@property (nonatomic,copy) NSString *memo;//上次的简介
@property (nonatomic,copy) NSString *currentChooseMemo;//当前用户修改的简介


@property (nonatomic ,strong) UIBarButtonItem *saveButton;

@property (nonatomic,strong) NSIndexPath *selectorIndexPath;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"个人信息";
    self.saveButton = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonClick)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.saveButton.enabled = NO;
    
    self.nickName = STUserAccountHandler.userProfile.nickName;
    self.currentChooseNickName = STUserAccountHandler.userProfile.nickName;
    
    self.gender = STUserAccountHandler.userProfile.gender;
    self.currentChooseGender = STUserAccountHandler.userProfile.gender;
    
    self.lastBirthdayString = STUserAccountHandler.userProfile.birthday;
    self.currentChooseBirthdayString = STUserAccountHandler.userProfile.birthday;
    
    self.headImageURLString = STUserAccountHandler.userProfile.headImg;
    
    self.memo = STUserAccountHandler.userProfile.memo;
    self.currentChooseMemo = STUserAccountHandler.userProfile.memo;
    
    _titleArray = [NSArray arrayWithObjects:@"头像",@"昵称",@"性别",@"生日",nil];
    
    [STNotificationCenter addObserver:self selector:@selector(reloadData) name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];
}

- (void)reloadData {
    
    [self.tableView reloadData];
}

- (void)saveButtonClick {

    if ([Common isObjectNull:self.currentChooseNickName]) {
        
        [self showToast:@"昵称不能为空"];
        return;
    }
    
    if ([Common isObjectNull:self.currentChooseBirthdayString]) {
        
        [self showToast:@"生日不能为空"];
        return;
    }
    
    //上传服务器
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler sendUpdateUserInformationWithUserId:[Common readAppDataForKey:KEY_SIGNIN_USER_UID]
                                                 nickName:self.currentChooseNickName
                                                   gender:self.currentChooseGender
                                                 birthday:self.currentChooseBirthdayString
                                       headImageUrlString:self.headImageURLString
                                                     memo:self.currentChooseMemo
                                                  success:^(BOOL success) {
        
          [self showToast:@"个人信息保存成功"];
          [self.navigationController popViewControllerAnimated:YES];
          [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                      
          NSDateFormatter *date = [[NSDateFormatter alloc] init];
          [date setDateFormat:@"yyyy-MM-dd"];
          NSDate *birthDate = [date dateFromString:self.currentChooseBirthdayString];
          NSTimeInterval dateDiff = [birthDate timeIntervalSinceNow];
          NSInteger age = trunc(dateDiff/(60 * 60 * 24)) / 365;
          age = 0 - age;
          
          if (age < 80) {
                  
                  NSMutableDictionary *userConfigure = [NSMutableDictionary dictionaryWithDictionary:[Common readAppDataForKey:USER_CHOOSE_AGENUMBER]];
                  
                  if (userConfigure == nil) {
                      userConfigure = [NSMutableDictionary dictionary];
                  }
                  
                  [userConfigure setObject:@(NO) forKey:HIGH_ALERT];
                  [Common saveAppDataForKey:USER_CHOOSE_AGENUMBER withObject:userConfigure];//保存到沙盒里
          }
                                                      
    } failure:^(NSError *error) {
        
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        [self showToast:error.userInfo[NSLocalizedDescriptionKey]];
    }];
}

- (void)updateImage:(UIImage *)image {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler sendUpdateUserHeadPortrait:[Common readAppDataForKey:KEY_SIGNIN_USER_UID] headImage:image success:^(NSString *imageUrl) {
        
        self.headImageURLString = imageUrl;
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        
    } failure:^(NSError *error) {
        
        [self showToast:[error userInfo][NSLocalizedDescriptionKey]];
        [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
    }];
}

#pragma ---
#pragma mark --- UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 5;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 10;
    }
    
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return 105;
        } else {
            return 43;
        }
    }
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 ) {
        
        if (indexPath.row == 0 ) {
            
            HeadViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeadViewTableViewCell"];
            
            if (cell == nil) {
                
                cell = [[[NSBundle mainBundle] loadNibNamed:@"HeadViewTableViewCell" owner:nil options:nil] lastObject];
                
            }
            
            cell.headImageViewURLString = STUserAccountHandler.userProfile.headImg;
            
            //给这连个判断条件赋值
            self.portraitImageView = cell.headImageView;
            self.editorImage = self.portraitImageView.image;
            self.copareImage = self.portraitImageView.image;
            
            return cell;
            
        } else {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            
            if ( cell == nil ) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.textColor = [UIColor blackColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.detailTextLabel.textColor = RGBACOLOR(130, 130, 130, 1);
        
            }
            
            if (indexPath.row == 1) {
              
                cell.detailTextLabel.text = self.currentChooseMemo;
                cell.textLabel.text = @"个性签名";
                
            } else if ( indexPath.row == 2) {
                
                cell.detailTextLabel.text = self.currentChooseNickName;
                cell.textLabel.text = @"昵称";
            
            } else if ( indexPath.row == 3) {
                
                cell.detailTextLabel.text = [self.currentChooseGender isEqual:@1] ? @"男" : @"女";
                cell.textLabel.text = @"性别";
                
            } else if ( indexPath.row == 4) {
                
                cell.detailTextLabel.text = self.currentChooseBirthdayString;
                cell.textLabel.text = @"生日";
            }
            
            return cell;
        }
        
    } else if (indexPath.section == 1) {
    
        AccountNumberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountNumberTableViewCell"];
        if ( cell == nil ) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AccountNumberTableViewCell" owner:nil options:nil] lastObject];
        }
        if (indexPath.row == 0) {
            cell.accountNumberLable.text = @"账号";
            [cell.phoneNumberButton setTitle:STUserAccountHandler.userProfile.userName forState:UIControlStateNormal];
        } else if (indexPath.row == 1) {
            cell.accountNumberLable.text = @"手机号";
            cell.profile = STUserAccountHandler.userProfile;
            [cell setButtonBlock:^{
                [self.navigationController pushViewController:(UIViewController *)[Common getBindController] animated:YES];
            }];
        }
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43)];
    [view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    return view;
}

//nickName birthday
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            [self chooseActionSheet];
            
        } else if (indexPath.row == 1) {
          
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"个性签名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textfile = [alert textFieldAtIndex:0];
            [textfile setText:self.currentChooseMemo];
            [alert show];
            
        } else if(indexPath.row == 2) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textfile = [alert textFieldAtIndex:0];
            [textfile setText:self.currentChooseNickName];
            [alert show];
            
        } else if(indexPath.row == 3) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择性别"message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女", nil];
            [alertView show];
            
        } else if(indexPath.row == 4) {
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提醒" message:@"修改生日会被当做新用户，将导致历史数据丢失，是否继续" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               
                [self chooseBirthday];
            }];
            
            UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:continueAction];
            [alertView addAction:cancelAlert];
            [self.navigationController presentViewController:alertView animated:YES completion:nil];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectorIndexPath = indexPath;//保存选中的indexPath
}

//选择生日
- (void)chooseBirthday {

    [self.view endEditing:YES];

    QGPickerView *picker = [[QGPickerView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - 250, SCREEN_WIDTH, 250)];
    picker.delegate = self;
    picker.titleText = @"生日选择";
    
    NSDateFormatter *formatter = [Common dateFormatterWithFormatterString:@"yyyy-MM-dd"];
    NSDate *bithdayDate = [formatter dateFromString:STUserAccountHandler.userProfile.birthday];
    
    [picker showDataPickView:[UIApplication sharedApplication].keyWindow WithDate:bithdayDate datePickerMode:UIDatePickerModeDate minimumDate:[NSDate dateWithTimeIntervalSinceNow:-(200.00000*365.00000*24.000000*60.00000*60.00000)] maximumDate:[NSDate date]];
}

#pragma mark -- QGPickerViewDelegate

- (void)didSelectPickView:(QGPickerView *)pickView selectDate:(NSDate *)selectorDate {
    
    NSDateFormatter *formatter = [Common dateFormatterWithFormatterString:@"yyyy-MM-dd"];
    
    self.currentChooseBirthdayString = [formatter stringFromDate:selectorDate];
    
    //判断保存按钮是否可用
    [self judgeSaveButtonCanUse];
    
    [self.tableView reloadData];
}

#pragma mark --- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( self.selectorIndexPath.section == 0 && buttonIndex != 0 ) {
        
        
        if (self.selectorIndexPath.row == 1 ) {
            
            UITextField *textfield = [alertView textFieldAtIndex:0];
            
            self.currentChooseMemo = textfield.text;
        }
        
        if (self.selectorIndexPath.row == 2 ) {
            
            UITextField *textfield = [alertView textFieldAtIndex:0];
            
            self.currentChooseNickName = textfield.text;
        }
        if (self.selectorIndexPath.row == 3 ) {
            
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"男"]) {
                
                self.currentChooseGender = @1;
                
            } else {
                
                self.currentChooseGender = @0;
                
            }
        }

        [self.tableView reloadData];
        
        //判断按钮是否可用
        [self judgeSaveButtonCanUse];
    }
    
}

- (void)chooseActionSheet {
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *pickCtrl = [[UIImagePickerController alloc] init];
    //设置代理
    pickCtrl.delegate = self;
    //设置允许编辑
    pickCtrl.allowsEditing = YES;
    if (buttonIndex == 0) {//拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
            pickCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        //显示图片选择器
        [self presentViewController:pickCtrl animated:YES completion:nil];
    }else if (buttonIndex == 1){//从手机中选取照片
        pickCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //显示图片选择器
        [self presentViewController:pickCtrl animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];

    self.editorImage = image;
    
    //判断按钮是否可用
    [self judgeSaveButtonCanUse];
    
    self.portraitImageView.image = image;
    
    //保存headImage字段
    [self updateImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//判断保存按钮是否可用
- (void)judgeSaveButtonCanUse {
    
    if ([self.nickName isEqualToString:self.currentChooseNickName] &&
        [self.gender isEqual:self.currentChooseGender] &&
        [self.lastBirthdayString isEqualToString:self.currentChooseBirthdayString] && [self.editorImage isEqual:self.portraitImageView.image] && [self.memo isEqualToString:self.currentChooseMemo]) {
        
        self.saveButton.enabled = NO;
        
    } else {
        
        self.saveButton.enabled = YES;
    }
}

- (void)dealloc {
    
    [STNotificationCenter removeObserver:self];
}

@end
