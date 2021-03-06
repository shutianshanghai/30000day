//
//  InformationViewController.m
//  30000day
//
//  Created by GuoJia on 16/3/14.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "InformationViewController.h"
#import "DOPDropDownMenu.h"
#import "InformationListTableViewCell.h"
#import "MTProgressHUD.h"
#import "MJRefresh.h"
#import "InformationDetailWebViewController.h"
#import "InformationWriterHomepageViewController.h"
#import "SubscribeCentreViewController.h"
#import "InformationWriterModel.h"
#import "SubscribeTableViewCell.h"

#define BUTTON_WIDTH 65
#define BUTTON_HEIGHT 39

@interface InformationViewController () < UITableViewDataSource,UITableViewDelegate,DOPDropDownMenuDataSource,DOPDropDownMenuDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSArray *titleArray;

@property (nonatomic,strong) NSArray *sortArray;

@property (nonatomic,strong) NSMutableArray *informationModelArray;

@property (nonatomic,strong) UITableView *tableViewInformation; //资讯tableView

@property (nonatomic,strong) UITableView *tableViewSubscription; //订阅tableView

@property (nonatomic,strong) UIButton *subscriptionCentralityButton; //订阅中心

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) STDataHandler *dataHandler;

@property (nonatomic,strong) UIButton *informationButton;//资讯按钮

@property (nonatomic,strong) UIButton *subscriptionButton;//订阅按钮

@property (nonatomic,strong) UIView *buttonParentView;//顶部按钮的父视图

@property (nonatomic,strong) UIView *bottomScrollView;//滚动的小视图

@property (nonatomic,assign) NSInteger scrollViewIndex;//记录scrollView第几页

@property (nonatomic,assign) NSInteger orderByIndex; //记录排序类型

@property (nonatomic,copy) NSString *typeIndex; //记录

@property (nonatomic,strong) NSArray *mySubscribeArray;

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"资讯";
    
    self.orderByIndex = 1;
    
    self.scrollViewIndex = 0;
    
    self.typeIndex = [[NSString alloc] init];
    
    self.dataHandler = [[STDataHandler alloc] init];
    
    //0. 创建顶部视图
    [self createScrollView];
    [self createButton];
    
    //1.设置mune
    self.sortArray = [NSArray arrayWithObjects:@"时间",@"热度", nil];
    self.titleArray = [NSArray arrayWithObjects:@"全部分类",@"饮食",@"运动",@"作息",@"备孕",@"孕期",@"育儿",@"治未病",@"体检",@"就医", nil];
    
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:44];
    menu.delegate = self;
    menu.dataSource = self;
    [self.scrollView addSubview:menu];
    
    //2.设置tableView
    [self createTableView];

    [self loadMySubscribeData];
    
    //监听通知
    [STNotificationCenter addObserver:self selector:@selector(reloadSubscribeList:) name:STDidSuccessSubscribeSendNotification object:nil];
    
    [STNotificationCenter addObserver:self selector:@selector(reloadSubscribeList:) name:STDidSuccessCancelSubscribeSendNotification object:nil];
}

//监听通知
- (void)reloadSubscribeList:(NSNotification *)notification {
    
    if (![notification.object isEqualToString:NSStringFromClass([self class])]) {//不是本控制器发出的就要监听
        
        [STDataHandler sendMySubscribeWithUserId:[NSString stringWithFormat:@"%d",STUserAccountHandler.userProfile.userId.intValue] success:^(NSMutableArray *success) {
            
            self.mySubscribeArray = [NSArray arrayWithArray:success];
            
            dispatch_async(dispatch_get_main_queue(), ^{
             
                [self.tableViewSubscription reloadData];
            
            });
            
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)loadMySubscribeData {

    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
    [STDataHandler sendMySubscribeWithUserId:[NSString stringWithFormat:@"%d",STUserAccountHandler.userProfile.userId.intValue] success:^(NSMutableArray *success) {
        
        self.mySubscribeArray = [NSArray arrayWithArray:success];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.tableViewSubscription reloadData];
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        
        });
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
        
        });
        
    }];
    
}

- (void)createScrollView {

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setTag:100];
    [self.scrollView setBounces:NO];
    [self.scrollView setDelegate:self];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, 0)];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];
}

- (void)createTableView {
    
    self.tableViewInformation = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - 94) style:UITableViewStyleGrouped];
    self.tableViewInformation.delegate = self;
    self.tableViewInformation.dataSource = self;
    [self.scrollView addSubview:self.tableViewInformation];

    self.tableViewInformation.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    self.tableViewInformation.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    
    [self.tableViewInformation.mj_footer setAutomaticallyHidden:YES];
    
    
    self.tableViewSubscription = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 50) style:UITableViewStyleGrouped];
    self.tableViewSubscription.delegate = self;
    self.tableViewSubscription.dataSource = self;
    [self.scrollView addSubview:self.tableViewSubscription];
    
    self.tableViewSubscription.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    self.tableViewSubscription.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
    
    [self.tableViewSubscription.mj_footer setAutomaticallyHidden:YES];
    
    //加载资讯数据
    [self loadDataWithCode:@""];
}

#pragma mark --- 上啦刷新和下拉刷新
- (void)headerRefreshing {
    
    if (self.scrollViewIndex == 0) {
        
        [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
        
        [STDataHandler sendsearchInfomationsWithWriterId:@"" infoTypeCode:@"" sortType:self.orderByIndex success:^(NSMutableArray *success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
                self.informationModelArray = [NSMutableArray arrayWithArray:success];
                
                [self.tableViewInformation reloadData];
                
                [self.tableViewInformation.mj_header endRefreshing];
                
            });

        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
                [self.tableViewInformation.mj_header endRefreshing];
                
            });
            
        }];

    } else {
        
        [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];
        [STDataHandler sendMySubscribeWithUserId:[NSString stringWithFormat:@"%d",STUserAccountHandler.userProfile.userId.intValue] success:^(NSMutableArray *success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                self.mySubscribeArray = [NSArray arrayWithArray:success];
                [self.tableViewSubscription reloadData];
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                [self.tableViewSubscription.mj_header endRefreshing];
            
            });
            
        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
                
                [self.tableViewSubscription.mj_header endRefreshing];
            
            });
        
        }];
    }
}

- (void)footerRereshing {
    
    if (self.scrollViewIndex == 0) {
        
        [self.tableViewInformation.mj_footer endRefreshing];
        
    } else {
    
        [self.tableViewSubscription.mj_footer endRefreshing];
    }
}

#pragma ----
#pragma mark --- UITableViewDataSource/UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.tableViewInformation]) {
        
        return self.informationModelArray.count;
        
    } else {
    
        return self.mySubscribeArray.count;
    
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.tableViewInformation]) {
    
        InformationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InformationListTableViewCell"];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"InformationListTableViewCell" owner:nil options:nil] lastObject];
        }
        
        InformationModel *informationModel = self.informationModelArray[indexPath.row];
        
        cell.informationModel = informationModel;
        
        return cell;
        
    } else {
        
        SubscribeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscribeTableViewCell"];
        
        if (cell == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SubscribeTableViewCell" owner:nil options:nil] lastObject];
        }
        
        InformationWriterModel *model = self.mySubscribeArray[indexPath.row];
        
        cell.writerModel = model;
        
        //点击订阅回调
        [cell setClickActionBlock:^(UIButton *subcribeButton) {
            
            if (model.isMineSubscribe == 0) {//订阅操作
                
                [STDataHandler sendSubscribeWithWriterId:model.writerId userId:[STUserAccountHandler.userProfile.userId stringValue] success:^(BOOL success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{

                        model.isMineSubscribe = 1;
                        
                        [subcribeButton setTitle:@"取消订阅" forState:UIControlStateNormal];
                    
                    });
                    
                } failure:^(NSError *error) {
                    
                }];
                
            } else {
                
                [STDataHandler sendCancelSubscribeWriterId:model.writerId userId:[STUserAccountHandler.userProfile.userId stringValue] success:^(BOOL success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        model.isMineSubscribe = 0;
                        
                        [subcribeButton setTitle:@"订阅" forState:UIControlStateNormal];
                    
                    });
                    
                } failure:^(NSError *error) {
                    
                }];
            }
            
        }];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (tableView == self.tableViewInformation) {
        
        return 86.0f;
    }
    return 72.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 20.0;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([tableView isEqual:self.tableViewInformation]) {
    
        InformationModel *informationModel = self.informationModelArray[indexPath.row];
        
        InformationDetailWebViewController *controller = [[InformationDetailWebViewController alloc] init];
        
        controller.infoId = informationModel.informationId;
        
        controller.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
    
        InformationWriterModel *writerModel = self.mySubscribeArray[indexPath.row];
        
        InformationWriterHomepageViewController *controller = [[InformationWriterHomepageViewController alloc] init];
        
        controller.writerId = writerModel.writerId;
        
        controller.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:controller animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma ----
#pragma mark --- DOPDropDownMenuDataSource/DOPDropDownMenuDelegate

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    
    if (column == 0) {
        
        return self.titleArray.count;
    
    } else {
    
        return self.sortArray.count;
    
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {

    if (indexPath.column == 0) {
        
        return self.titleArray[indexPath.row];
    
    } else {
    
        return self.sortArray[indexPath.row];
    
    }
}

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
    
    return 2;
    
}

-(void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath {
    
    if (indexPath.column == 0) {
        
        NSString *code;
        if (indexPath.row == 0) {
            
            code = @"";
            
        } else {
        
            code = [NSString stringWithFormat:@"%d",(int)indexPath.row + 9];
        }
        
        self.typeIndex = code;
        
        [self loadDataWithCode:code];
        
    } else {
        
        self.orderByIndex = indexPath.row + 1;
        
        [self loadDataWithCode:self.typeIndex];

    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataWithCode:(NSString *)code {
    
    [MTProgressHUD showHUD:[UIApplication sharedApplication].keyWindow];

    [STDataHandler sendsearchInfomationsWithWriterId:@"" infoTypeCode:code sortType:self.orderByIndex success:^(NSMutableArray *success) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            
            self.informationModelArray = [NSMutableArray arrayWithArray:success];
            
            [self.tableViewInformation reloadData];
            
        });
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [MTProgressHUD hideHUD:[UIApplication sharedApplication].keyWindow];
            
        });
    
    }];
}

- (void)createButton {
    
    self.buttonParentView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
    self.navigationItem.titleView = self.buttonParentView;
    
    CGFloat leftX = (self.buttonParentView.bounds.size.width - BUTTON_WIDTH) / 2;
    
    _informationButton = [self buttonWithTitle:@"资讯" numberAndTag:0];
    [_informationButton setTitleColor:LOWBLUECOLOR forState:UIControlStateNormal];
    [_informationButton setFrame:CGRectMake(leftX - BUTTON_WIDTH, 5, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.buttonParentView addSubview:_informationButton];
    
    _subscriptionButton = [self buttonWithTitle:@"订阅" numberAndTag:1];
    [_subscriptionButton setFrame:CGRectMake(leftX + BUTTON_WIDTH, 5, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [self.buttonParentView addSubview:_subscriptionButton];
    
    _bottomScrollView = [[UIView alloc]initWithFrame:CGRectMake(leftX - BUTTON_WIDTH, 42, BUTTON_WIDTH, 2)];
    [_bottomScrollView setBackgroundColor:LOWBLUECOLOR];
    [self.buttonParentView addSubview:_bottomScrollView];
    
    
    self.subscriptionCentralityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.subscriptionCentralityButton setImage:[UIImage imageNamed:@"icon_add_events"] forState:UIControlStateNormal];
    [self.subscriptionCentralityButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.subscriptionCentralityButton addTarget:self action:@selector(subscription) forControlEvents:UIControlEventTouchDown];
    [self.buttonParentView addSubview:self.subscriptionCentralityButton];
    self.subscriptionCentralityButton.translatesAutoresizingMaskIntoConstraints=NO;
    
    [self.buttonParentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subscriptionCentralityButton
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.buttonParentView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:0]];
    
    [self.buttonParentView addConstraint:[NSLayoutConstraint constraintWithItem:self.subscriptionCentralityButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.buttonParentView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0]];

    
}

- (void)subscription {

    SubscribeCentreViewController *controller = [[SubscribeCentreViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

}

- (UIButton *)buttonWithTitle:(NSString*)title numberAndTag:(int)tag {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    
    button.tag = tag;
    
    return button;
    
}

#pragma mark 按钮监听方法
- (void)tapButton:(UIButton *)button {
    
    self.scrollViewIndex = button.tag;
    
    [_scrollView setContentOffset:CGPointMake(button.tag * SCREEN_WIDTH, - 64) animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [_bottomScrollView setFrame:CGRectMake(button.frame.origin.x, 42, 65 , 2)];
        
    }];
    
    [self buttonTitleChange:button.tag];
}

- (void)buttonTitleChange:(NSInteger)page {
    
    switch (page) {
            
        case 0:
            [_informationButton setTitleColor:LOWBLUECOLOR forState:UIControlStateNormal];
            [_subscriptionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            break;
        case 1:
            [_subscriptionButton setTitleColor:LOWBLUECOLOR forState:UIControlStateNormal];
            [_informationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            break;
        case 2:
            [_subscriptionButton setTitleColor:LOWBLUECOLOR forState:UIControlStateNormal];
            [_informationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            break;
        default:
            
            break;
    }
}

#pragma mark ---- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 100) {
      
        CGPoint offset = scrollView.contentOffset;
        
        NSInteger curPageNo = offset.x / _scrollView.bounds.size.width;
        
        self.scrollViewIndex = curPageNo;
        
        CGFloat leftX = (self.buttonParentView.bounds.size.width - BUTTON_WIDTH) / 2;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGFloat X;
            
            if (curPageNo) {
                
                X = leftX + BUTTON_WIDTH;
                
            } else {
                
                X = leftX - BUTTON_WIDTH;
                
            }
            
            [_bottomScrollView setFrame:CGRectMake(X, 42, BUTTON_WIDTH, 2)];
        }];
        
        [self buttonTitleChange:curPageNo];

    }
}

- (void)dealloc {
    
    [STNotificationCenter removeObserver:self name:STDidSuccessSubscribeSendNotification object:nil];
    
    [STNotificationCenter removeObserver:self name:STDidSuccessCancelSubscribeSendNotification object:nil];
    
    self.titleArray = nil;
    
    self.sortArray = nil;
    
    self.scrollView = nil;
    
    self.informationButton = nil;
    
    self.subscriptionButton = nil;
    
    self.buttonParentView = nil;
    
    self.bottomScrollView = nil;
    
    self.mySubscribeArray = nil;
}

@end
