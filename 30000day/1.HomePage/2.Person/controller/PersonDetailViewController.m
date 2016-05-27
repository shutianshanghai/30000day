//
//  PersonDetailViewController.m
//  30000day
//
//  Created by GuoJia on 16/2/29.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "PersonDetailViewController.h"
#import "PersonTableViewCell.h"
#import "ActivityIndicatorTableViewCell.h"
#import "ChartTableViewCell.h"
#import "UserLifeModel.h"
#import "CDChatVC.h"
#import "CDIMService.h"
#import "UIImageView+WebCache.h"
#import "UserInformationModel.h"
#import "UIImage+WF.h"
#import "MTProgressHUD.h"
#import "PersonSettingViewController.h"
#import "PersonInformationsManager.h"

@interface PersonDetailViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) float totalLifeDayNumber;

@property (nonatomic,strong) NSMutableArray *allDayArray;

@property (nonatomic,strong) NSMutableArray *dayNumberArray;

@property (weak, nonatomic) IBOutlet UIView *backgoudView;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (nonatomic,strong) ActivityIndicatorTableViewCell *indicatorCell;

@end

@implementation PersonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详细资料";
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    self.backgoudView.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    self.backgoudView.layer.borderWidth = 0.5f;
    
    self.rightButton.layer.cornerRadius = 5;
    self.rightButton.layer.masksToBounds = YES;
    
    //右边按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[[UIImage imageNamed:@"icon_more"] imageWithTintColor:LOWBLUECOLOR] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, 0, 28.0f, 22.0f);
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [button addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self reloadData];
    
    [STNotificationCenter addObserver:self selector:@selector(reloadTableViewData) name:STDidSuccessUpdateFriendInformationSendNotification object:nil];
}

- (ActivityIndicatorTableViewCell *)indicatorCell {
    
    if (!_indicatorCell) {
        
        _indicatorCell = [[[NSBundle mainBundle] loadNibNamed:@"ActivityIndicatorTableViewCell" owner:nil options:nil] lastObject];
    }
    
    return _indicatorCell;
}

- (void)rightButtonAction {
    
    PersonSettingViewController *controller = [[PersonSettingViewController alloc] init];
    
    controller.friendUserId = self.friendUserId;
    
    controller.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadTableViewData {
    
    [self.tableView reloadData];
    
}

- (void)reloadData {

    //获取用户天龄
    [self getUserLifeList];
    
    //获取用户击败的用户
    [self getDefeatDataWithUserId:STUserAccountHandler.userProfile.userId];
}

- (void)getUserLifeList {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    
    [Common dayNumberWithinNumber:7 inputDate:[[Common dateFormatterWithFormatterString:@"yyyy-MM-dd"] dateFromString:self.informationModel.birthday] completion:^(NSInteger day) {//获取用户的生日和当前天数比较，如果在7点以内比对结果拉取数据，若果超过按照7天拉取
        
        //1.获取用户的天龄
        [STDataHandler sendUserLifeListWithCurrentUserId:self.friendUserId endDay:[Common getDateStringWithDate:[NSDate date]] dayNumber:[NSString stringWithFormat:@"%d",(int)day] success:^(NSMutableArray *dataArray) {
            
            UserLifeModel *lastModel = [dataArray lastObject];
            
            self.totalLifeDayNumber = [lastModel.curLife floatValue];
            
            //算出数组
            NSMutableArray *allDayArray = [NSMutableArray array];
            
            NSMutableArray *dayNumberArray = [NSMutableArray array];
            
            if (dataArray.count > 1 ) {
                
                for (int  i = 0; i < dataArray.count ; i++ ) {
                    
                    UserLifeModel *model = dataArray[i];
                    
                    [allDayArray addObject:model.curLife];
                    
                    NSArray *array = [model.createTime componentsSeparatedByString:@"-"];
                    
                    NSString *string = array[2];
                    
                    NSString *newString = [[string componentsSeparatedByString:@" "] firstObject];
                    
                    [dayNumberArray addObject:newString];
                    
                }
                
                self.allDayArray = [NSMutableArray arrayWithArray:[[allDayArray reverseObjectEnumerator] allObjects]];
                
                self.dayNumberArray = [NSMutableArray arrayWithArray:[[dayNumberArray reverseObjectEnumerator] allObjects]];
                
            } else {
                
                UserLifeModel *model = [dataArray firstObject];
                
                if (model) {
                    
                    [allDayArray addObject:model.curLife];
                    
                    [allDayArray addObject:model.curLife];
                    
                    NSArray *array = [model.createTime componentsSeparatedByString:@"-"];
                    
                    NSString *string = array[2];
                    
                    NSString *newString = [[string componentsSeparatedByString:@" "] firstObject];
                    
                    [dayNumberArray addObject:newString];
                    
                    [dayNumberArray addObject:newString];
                    
                    self.allDayArray = [NSMutableArray arrayWithArray:[[allDayArray reverseObjectEnumerator] allObjects]];
                    
                    self.dayNumberArray = [NSMutableArray arrayWithArray:[[dayNumberArray reverseObjectEnumerator] allObjects]];
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            });
            
        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            });
        }];
 
    }];
}

//根据用户id去获取打败的数据
- (void)getDefeatDataWithUserId:(NSNumber *)userId {
    
    [STDataHandler sendGetDefeatDataWithUserId:userId success:^(NSString *dataString) {
        
        NSString *string = [[[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId] showNickName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.indicatorCell.titleLabel.text = [NSString stringWithFormat:@"%@的总天龄已经击败%.1f%%用户",string,[dataString floatValue] * 100];
        });
    
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)buttonClickAction:(id)sender {
    
    if ([Common isObjectNull:[UserInformationModel errorStringWithModel:[[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId] userProfile:STUserAccountHandler.userProfile]]) {
        
        //查询conversation
        [[CDChatManager manager] fetchConversationWithOtherId:[NSString stringWithFormat:@"%@",self.friendUserId] attributes:[UserInformationModel attributesDictionay:[[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId] userProfile:STUserAccountHandler.userProfile] callback:^(AVIMConversation *conversation, NSError *error) {
            
            if ([self filterError:error]) {
                
                [[CDIMService service] pushToChatRoomByConversation:conversation fromNavigationController:self.navigationController];
                
            }
        }];
        
    } else {
        
        [self showToast:[UserInformationModel errorStringWithModel:[[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId] userProfile:STUserAccountHandler.userProfile]];
    }
}

#pragma --
#pragma mark ---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
      
        static NSString *identifier = @"PersonTableViewCell";
        
        PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            
            cell = [[NSBundle mainBundle] loadNibNamed:@"PersonTableViewCell" owner:nil options:nil][0];
        }
        
        cell.imageRight_first.hidden = YES;
        
        cell.progressView.hidden = YES;
        
        cell.informationModel = [[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        //刷新数据
        [self.indicatorCell reloadData:self.totalLifeDayNumber birthDayString:[[PersonInformationsManager shareManager] infoWithFriendId:self.friendUserId].birthday showLabelTye:[Common readAppIntegerDataForKey:SHOWLABLETYPE]];
        
        return self.indicatorCell;
        
    } else if (indexPath.section == 2) {
     
        ChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChartTableViewCell"];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ChartTableViewCell" owner:nil options:nil] lastObject];
        }
        
        cell.allDayArray = self.allDayArray;
        
        cell.dayNumberArray = self.dayNumberArray;
        
        if (self.allDayArray && self.dayNumberArray) {
            
            [cell reloadData];
        }
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return 72.1f;
        
    } else if ( indexPath.section == 1) {
        
        return (SCREEN_HEIGHT - 188)/2.0f;
        
    } else if (indexPath.section == 2) {
        
        return (SCREEN_HEIGHT - 188)/2.0f;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [STNotificationCenter removeObserver:self name:STDidSuccessUpdateFriendInformationSendNotification object:nil];
    
    self.allDayArray = nil;
    
    self.dayNumberArray = nil;
    
    self.indicatorCell = nil;
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
