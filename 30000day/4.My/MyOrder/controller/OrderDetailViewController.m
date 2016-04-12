//
//  OrderDetailViewController.m
//  30000day
//
//  Created by GuoJia on 16/4/6.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "MyOrderDetailModel.h"
#import "PaymentViewController.h"
#import "OrderDetailTableViewCell.h"
#import "PersonInformationTableViewCell.h"
#import "ShopDetailViewController.h"
#import "MTProgressHUD.h"
#import "CommodityCommentViewController.h"

@interface OrderDetailViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) MyOrderDetailModel *detailModel;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIView *backgoudView;

@property (nonatomic,strong) UILabel *rightLabel;

@end

@implementation OrderDetailViewController {
    
    NSTimer *_timer;
    long _count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    
    //配置UI界面
    [self configUI];
    
    [self judgeConformButtonCanUse];
    
    [self loadDataFromServer];
}

//配置UI界面
- (void)configUI {
    
    self.isShowBackItem = YES;
    
    self.tableViewStyle = STRefreshTableViewGroup;
    
    self.isShowFootRefresh = NO;
    
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50);
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    self.backgoudView.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    self.backgoudView.layer.borderWidth = 0.5f;
    
    self.leftButton.layer.cornerRadius = 5;
    self.leftButton.layer.masksToBounds = YES;
    
    self.leftButton.layer.borderWidth = 0.5f;
    self.leftButton.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
    
    self.rightButton.layer.cornerRadius = 5;
    self.rightButton.layer.masksToBounds = YES;
    
    [self.rightButton setBackgroundImage:[Common imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [self.leftButton setBackgroundImage:[Common imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    
    self.rightLabel.textColor = [UIColor redColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightLabel];
}

- (void)headerRefreshing {
    
    [self loadDataFromServer];
}

//从服务器下载数据
- (void)loadDataFromServer {

    //下载数据
    [self.dataHandler sendFindOrderDetailOrderNumber:self.orderNumber success:^(MyOrderDetailModel *detailModel) {
        
        self.detailModel = detailModel;
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        self.status = self.detailModel.status;
        
        if ([self.status isEqualToString:@"10"]) {
            
            [self configOrderLimitTime:self.detailModel.orderDate];
        }
        
        [self judgeConformButtonCanUse];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_header endRefreshing];
        
    }];
}

//配置限时时间
- (void)configOrderLimitTime:(NSNumber *)orderTime {
    
    NSDate *date = [NSDate date];
    
    NSTimeInterval currentTimeInterval = [date timeIntervalSince1970];
    
    NSTimeInterval a = [orderTime doubleValue]/1000;
    
    if ((currentTimeInterval - a ) > 300 ) {//超过5分钟了
        
    } else if ((currentTimeInterval - a ) < 300 ) {//在5分钟之内
        
        NSTimeInterval b = 300 + a - currentTimeInterval;//剩余的时间
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countNumberOfData) userInfo:nil repeats:YES];
        
        _count = (long)b;
        
        [_timer fire];
    }
}

- (void)countNumberOfData {
    
    _count--;
    
    self.rightLabel.text = [NSString stringWithFormat:@"%02li:%02li",_count/60,_count%60];
    
    if (_count == 0) {
        
        [_timer invalidate];
        
        //发出更新通知
        [STNotificationCenter postNotificationName:STDidSuccessCancelOrderSendNotification object:nil];
        
        //修改时间显示
        self.rightLabel.text = @"";
        
        self.rightButton.enabled = NO;
        
        self.leftButton.enabled = NO;
        
        [self.rightButton setTitle:@"已超时" forState:UIControlStateNormal];
    }
}

//取消订单，修改按钮并发出通知
- (void)canceledOrderSetting {
    
    [self showToast:@"订单取消成功"];
    
    self.rightButton.enabled = NO;
    
    self.leftButton.enabled = NO;
    
    self.rightLabel.text = @"";
    
    [_timer invalidate];
    
    [self.rightButton setTitle:@"已取消" forState:UIControlStateNormal];
    
    //发出更新通知
    [STNotificationCenter postNotificationName:STDidSuccessCancelOrderSendNotification object:nil];
    
    [self loadDataFromServer];//重新从服务器下载数据
}

//取消预约
- (IBAction)leftButtonAction:(id)sender {
    
    if ([self.status isEqualToString:@"2"]) {//去评价
        
        CommodityCommentViewController *controller = [[CommodityCommentViewController alloc] init];
        
        controller.orderNumber = self.orderNumber;
        
        controller.productName = self.detailModel.productName;
        
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {//取消订单
        
        [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
        
        [self.dataHandler sendCancelOrderWithOrderNumber:self.detailModel.orderNo
                                                 success:^(BOOL success) {
                                                     
                                                     [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                     
                                                     [self canceledOrderSetting];
                                                     
                                                 } failure:^(NSError *error) {
                                                     
                                                     [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                                                     
                                                     [self showToast:[error.userInfo objectForKey:NSLocalizedDescriptionKey]];
                                                     
                                                 }];
        
    }
}

//前往预约
- (IBAction)rightButtonAction:(id)sender {
    
    if ([self.status isEqualToString:@"2"]) {//表示支付完成
        
        
        
    } else {
        
        PaymentViewController *controller = [[PaymentViewController alloc] init];
        
        controller.selectorDate = [NSDate dateWithTimeIntervalSince1970:[self.detailModel.orderDate doubleValue]/1000.0000000];
        
        controller.timeModelArray = self.detailModel.orderCourtList;
        
        controller.productId = self.detailModel.productId;
        
        controller.productName = self.detailModel.productName;
        
        controller.orderNumber = self.detailModel.orderNo;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//判断确认订单是否可用
- (void)judgeConformButtonCanUse {
    
    if ([self.status isEqualToString:@"10"]) {
        
        [self.rightButton setTitle:@"前往付款" forState:UIControlStateNormal];
        
        self.rightButton.enabled = YES;
        
        self.leftButton.enabled = YES;

    } else if ([self.status isEqualToString:@"11"]) {
        
        [self.rightButton setTitle:@"已取消" forState:UIControlStateNormal];
        
        self.rightButton.enabled = NO;
        
        self.leftButton.enabled = NO;
        
    } else if ([self.status isEqualToString:@"12"]) {
        
        [self.rightButton setTitle:@"已超时" forState:UIControlStateNormal];
        
        self.rightButton.enabled = NO;
        
        self.leftButton.enabled = NO;
        
    } else if ([self.status isEqualToString:@"2"]) {
        
        [self.rightButton setTitle:@"申请退款" forState:UIControlStateNormal];
        
        [self.leftButton setTitle:@"去评价" forState:UIControlStateNormal];
        
        self.rightButton.enabled = YES;
        
        self.leftButton.enabled = YES;
    }
}

#pragma ----
#pragma mark ---- UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else if (section == 1) {
        
        return 1;
        
    } else if (section == 2) {
        
        return 2 + self.detailModel.orderCourtList.count;
        
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 ) {
        
        return 134;
        
    } else if (indexPath.section == 1) {
        
        return 169;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     OrderDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailTableViewCell"];
    
    if (indexPath.section == 0) {
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailTableViewCell" owner:nil options:nil] firstObject];
        }
        
        [cell configContactPersonInformation:self.detailModel];
        
        return cell;
        
    } else if ( indexPath.section == 1 ) {
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderDetailTableViewCell" owner:nil options:nil] lastObject];
        }
        
        [cell configProductInformation:self.detailModel];
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
         PersonInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonInformationTableViewCell"];
        
        if (indexPath.row == 0) {
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonInformationTableViewCell" owner:nil options:nil][2];
            }
            cell.firstTitleLabel.text = @"预约日期";
            
            cell.firstTitleLabel.hidden = NO;
            
            cell.contentLabel.text = [[Common dateFormatterWithFormatterString:@"yyyy-MM-dd"] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.detailModel.orderDate doubleValue]/1000]];
            
        } else if (indexPath.row == 1) {
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonInformationTableViewCell" owner:nil options:nil][2];
            }
            
            AppointmentTimeModel *timeModel = self.detailModel.orderCourtList[0];
            
            cell.firstTitleLabel.text = @"场次";
            
            cell.firstTitleLabel.hidden = NO;
            
            [cell configOrderWithAppointmentTimeModel:timeModel];
            
        } else if  (indexPath.row == 1 + self.detailModel.orderCourtList.count) {//总计
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonInformationTableViewCell" owner:nil options:nil][3];
            }
            
            cell.titleLabel.text = @"支付总额";
            
            //配置总价格
            [cell configTotalPriceWith:self.detailModel.orderCourtList];
            
            return cell;
            
        } else {
            
            if (cell == nil) {
                
                cell = [[NSBundle mainBundle] loadNibNamed:@"PersonInformationTableViewCell" owner:nil options:nil][2];
            }
            
            AppointmentTimeModel *timeModel = self.detailModel.orderCourtList[indexPath.row - 1];
            
            cell.firstTitleLabel.hidden = YES;
            
            [cell configOrderWithAppointmentTimeModel:timeModel];
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10.0f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.5f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        ShopDetailViewController *controller = [[ShopDetailViewController alloc] init];
        
        controller.productId = [NSString stringWithFormat:@"%@",self.detailModel.productId];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
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
