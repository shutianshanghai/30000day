//
//  MainViewController.m
//  30000day
//
//  Created by GuoJia on 16/2/17.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "MainViewController.h"
#import "WeatherTableViewCell.h"
#import "ActivityIndicatorTableViewCell.h"
#import "ChartTableViewCell.h"
#import "WeatherInformationModel.h"
#import "UserLifeModel.h"
#import "MotionData.h"
#import "JinSuoDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) WeatherInformationModel *informationModel;

@property (nonatomic,assign) float totalLifeDayNumber;

@property (nonatomic,strong) NSMutableArray *allDayArray;

@property (nonatomic,strong) NSMutableArray *dayNumberArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    
    [self.tableView setTableFooterView:[[UIView alloc] init]];
    
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44);
    
    self.isShowFootRefresh = NO;
    
    //监听个人信息管理模型发出的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:STUserAccountHandlerUseProfileDidChangeNotification object:nil];

    //更新个人运动信息
    [self uploadMotionData];
    
    //定位并获取天气
    [self startFindLocationSucess];
    
    //获取用户天龄
    [self getUserLifeList];
}

- (void)headerRefreshing {
    
    //1.获取个人信息
    [self getUserInformation];
    
    //2.获取天气
    [self startFindLocationSucess];
}

//跳到登录控制器
- (void)jumpToSignInViewController {
    
    SignInViewController *logview = [[SignInViewController alloc] init];
    
    STNavigationController *navigationController = [[STNavigationController alloc] initWithRootViewController:logview];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)reloadData {
    
    //获取用户的天龄
    [self getUserLifeList];

}

//登录获取个人信息
- (void)getUserInformation {
    
    [self.dataHandler postSignInWithPassword:[Common readAppDataForKey:KEY_SIGNIN_USER_PASSWORD]
                                   loginName:[Common readAppDataForKey:KEY_SIGNIN_USER_NAME]
                          isPostNotification:NO
                                     success:^(BOOL success) {
                                         
                                         //获取用户的天龄
                                         [self getUserLifeList];
                                         
                                         [self.tableView.mj_header endRefreshing];
                                         
                                     }
                                     failure:^(NSError *error) {
                                         
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

//获取用户的天龄
- (void)getUserLifeList {
    
    if (![Common isObjectNull:STUserAccountHandler.userProfile.userId]) {//表示如果账户的userId为空的话，那么就不获取用户的天龄
    
        [self.dataHandler sendUserLifeListWithCurrentUserId:STUserAccountHandler.userProfile.userId endDay:[Common getDateStringWithDate:[NSDate date]] dayNumber:@"7" success:^(NSMutableArray *dataArray) {
            
            UserLifeModel *lastModel = [dataArray firstObject];
            
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
            
            [self.tableView reloadData];
            
            [self.tableView.mj_header endRefreshing];

        } failure:^(LONetError *error) {
            
            [self showToast:@"获取天龄失败，可能是网络繁忙"];
            
            [self.tableView.mj_header endRefreshing];
        }];
        
    }
}

//上传用户信息
- (void)uploadMotionData {
    
    if (![Common isObjectNull:STUserAccountHandler.userProfile.userId]) {
        
        MotionData *mdata = [[MotionData alloc]init];
        
        [mdata getHealtHequipmentWhetherSupport:^(BOOL scs) {
            
            if (scs) {
                
                //获取步数
                [mdata getHealthUserDateOfBirthCount:^(NSString *birthString) {
                    
                    if (birthString != nil) {
                        NSLog(@"获取步数  %@",birthString);
                        //获取爬楼数
                        [mdata getClimbStairsCount:^(NSString *climbStairsString) {
                            
                            if (climbStairsString != nil) {
                                NSLog(@"获取爬楼数  %@",climbStairsString);
                                //获取运动距离
                                [mdata getMovingDistanceCount:^(NSString *movingDistanceString) {
                                    
                                    if (movingDistanceString != nil) {
                                        NSLog(@"获取运动距离  %@",movingDistanceString);
                                        
                                        NSMutableDictionary *dataDictionary=[NSMutableDictionary dictionary];
                                        [dataDictionary setObject:birthString forKey:@"stepNum"];
                                        [dataDictionary setObject:climbStairsString forKey:@"stairs"];
                                        [dataDictionary setObject:movingDistanceString forKey:@"distance"];
                                        
                                        NSString *dataString=[self dataToJsonString:dataDictionary];
                                        
                                        [self.dataHandler sendStatUserLifeWithUserId:STUserAccountHandler.userProfile.userId dataString:dataString success:^(BOOL success) {
                                            
                                            if (success) {
                                                NSLog(@"运动信息上传成功");
                                            }
                                            
                                        } failure:^(NSError *error) {
                                            
                                            NSLog(@"运动信息上传失败");
                                            
                                        }];
                                    }
                                    
                                } failure:^(NSError *error) {
                                    NSLog(@"获取运动距离失败");
                                }];
                            }
                            
                        } failure:^(NSError *error) {
                            NSLog(@"获取爬楼数失败");
                        }];
                        
                    }
                    
                } failure:^(NSError *error) {
                    NSLog(@"获取步数失败");
                }];
                
            }else{
                return;
            }
            
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    
}

//定位并获取天气情况
- (void)startFindLocationSucess {
    
    //1.开始定位
    [self.dataHandler startFindLocationSucess:^(NSString *cityName,NSString *administrativeArea,CLLocationCoordinate2D coordinate2D) {
        
        NSMutableString *string = [NSMutableString stringWithString:cityName];
        
        NSRange locatin;
        if ([string containsString:@"市"]) {
            
             locatin = [string rangeOfString:@"市"];
            
        } else if ([string containsString:@"自治区"]) {
            
            locatin = [string rangeOfString:@"自治区"];
            
        }
        
        if (locatin.length != 0) {
            
            [string deleteCharactersInRange:locatin];
            
        }
        
        
        
        
        //获取天气情况
        [self.dataHandler getWeatherInformation:string sucess:^(WeatherInformationModel *informationModel) {
            
            self.informationModel = informationModel;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
        } failure:^(NSError *error) {
            
            [self showToast:@"获取天气失败"];
            
        }];
        
    } failure:^(NSError *error) {
        
        [self showToast:@"定位失败"];
        
    }];
}


#pragma ---
#pragma mark --- UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        static NSString *weatherCellIndentifier = @"WeatherTableViewCell";
        
        WeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:weatherCellIndentifier];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:weatherCellIndentifier owner:nil options:nil] lastObject];
        }
        
        [cell.ageLable setText:[NSString stringWithFormat:@"%ld岁",(long)[self daysToYear]]];
        [cell.jinSuoImageView setImage:[self lifeToYear]];
        
        [cell setChangeStateBlock:^() {
            [self lifeImagePush];
        }];
        
        cell.informationModel = self.informationModel;
        
        //下载头像
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:STUserAccountHandler.userProfile.headImg] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        return cell;
        
    } else if (indexPath.row == 1) {
        
        static NSString *activityIndicatorCellIndentifier = @"ActivityIndicatorTableViewCell";
        
        ActivityIndicatorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activityIndicatorCellIndentifier];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:activityIndicatorCellIndentifier owner:nil options:nil] lastObject];
        }
        
        //刷新数据
        [cell reloadData:self.totalLifeDayNumber birthDayString:STUserAccountHandler.userProfile.birthday];
        
        return cell;
        
    } else if (indexPath.row == 2) {
        
        static NSString *chartCellIndentifier = @"ChartTableViewCell";
        
        ChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:chartCellIndentifier];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:chartCellIndentifier owner:nil options:nil] lastObject];
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
    
    if (indexPath.row == 0) {
        
        return 80;
        
    } else if ( indexPath.row == 1) {
        
        return (SCREEN_HEIGHT - 188)/2.0f;
        
    } else if (indexPath.row == 2) {
        
        return (SCREEN_HEIGHT - 188)/2.0f;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSString *)dataToJsonString:(id)object {
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
       
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


- (NSInteger)daysToYear {
    
    NSInteger day = [[self.allDayArray lastObject] integerValue];
    NSNumber *year = [NSNumber numberWithFloat:day/365];
    NSInteger yearInt = [year integerValue];
    
    return yearInt;
}

- (UIImage *)lifeToYear {
    
    NSInteger life = [self daysToYear];
    
    if ([[STUserAccountHandler userProfile].gender intValue] == 0) {
        
        if (life <= 20) {
            return [UIImage imageNamed:@"age_1_f"];
        }else if (life <= 30){
            return [UIImage imageNamed:@"age_2_f"];
        }else if (life <= 40){
            return [UIImage imageNamed:@"age_3_f"];
        }else if (life <= 50){
            return [UIImage imageNamed:@"age_4_f"];
        }else if (life <= 60){
            return [UIImage imageNamed:@"age_5_f"];
        }else if (life <= 70){
            return [UIImage imageNamed:@"age_6_f"];
        }else if (life <= 80){
            return [UIImage imageNamed:@"age_7_f"];
        }else if (life <= 90){
            return [UIImage imageNamed:@"age_8_f"];
        }else if (life <= 100 || life > 100){
            return [UIImage imageNamed:@"age_9_f"];
        }else{
            return nil;
        }
    }
    
    if ([[STUserAccountHandler userProfile].gender intValue] == 1) {
        
        if (life <= 20) {
            return [UIImage imageNamed:@"age_1"];
        }else if (life <= 30){
            return [UIImage imageNamed:@"age_2"];
        }else if (life <= 40){
            return [UIImage imageNamed:@"age_3"];
        }else if (life <= 50){
            return [UIImage imageNamed:@"age_4"];
        }else if (life <= 60){
            return [UIImage imageNamed:@"age_5"];
        }else if (life <= 70){
            return [UIImage imageNamed:@"age_6"];
        }else if (life <= 80){
            return [UIImage imageNamed:@"age_7"];
        }else if (life <= 90){
            return [UIImage imageNamed:@"age_8"];
        }else if (life <= 100 || life > 100){
            return [UIImage imageNamed:@"age_9"];
        }else{
            return nil;
        }

    }
    
    return nil;
    
}

- (void)lifeImagePush {
    
    JinSuoDetailsViewController *controller = [[JinSuoDetailsViewController alloc] init];
    
    controller.averageAge = [self daysToYear];
    
    controller.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:controller animated:YES];
    
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
