//
//  InformationDetailViewController.m
//  30000day
//
//  Created by GuoJia on 16/3/14.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "InformationDetailViewController.h"
#import "InformationTableViewCell.h"
#import "ShopDetailOneLineDataNoImageViewTableViewCell.h"
#import "ShopDetailCommentTableViewCell.h"
#import "CommentViewController.h"
#import "ReportViewController.h"
#import "InformationDetailImageTableViewCell.h"
#import "InformationDetailDownTableViewCell.h"

@interface InformationDetailViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation InformationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";

    self.tableViewStyle = STRefreshTableViewGroup;
    
    self.isShowBackItem = YES;
    
    self.isShowFootRefresh = NO;
    
    self.isShowHeadRefresh = NO;
    
    self.tableView.frame = CGRectMake(0, 54, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    self.tableView.dataSource = self;
    
    self.tableView.delegate = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonAction)];
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.isShowInputView = YES;
}

#pragma ---
#pragma mark --- 上啦刷新和下拉刷新

- (void)headerRefreshing {
    
    [self.tableView.mj_header endRefreshing];
}

- (void)footerRereshing {
    
    [self.tableView.mj_footer endRefreshing];
}

- (void)barButtonAction {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *first_action = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ReportViewController *controller = [[ReportViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.success = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }];
                                     
    UIAlertAction *second_action = [UIAlertAction actionWithTitle:@"转载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    UIAlertAction *third_action = [UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [controller addAction:first_action];
    
    [controller addAction:second_action];
    
    [controller addAction:third_action];
    
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --
#pragma mark --- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        
    return 4;
        
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        CGFloat height = [Common heightWithText:@"江西35岁女县长直升副厅级领导江西35岁女县长直升副厅级领导" width:SCREEN_WIDTH fontSize:16.0] + [Common heightWithText:@"一般是说、县（市、区）长先接任书记，才有可能进入副厅级领导行列，想彭艳梅这样，直接从县长直升副厅级领导的毕竟是少数。一般是说、县（市、区）长先接任书记，才有可能进入副厅级领导行列，想彭艳梅这样，直接从县长直升副厅级领导的毕竟是少数。一般是说、县（市、区）长先接任书记，才有可能进入副厅级领导行列，想彭艳梅这样，直接从县长直升副厅级领导的毕竟是少数。" width:SCREEN_WIDTH fontSize:15.0] + 70;
        
        return height;
        
    } else if (indexPath.row == 1 || indexPath.row == 2) {
    
        return 150;
    
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        InformationTableViewCell *informationTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"InformationTableViewCell"];
        
        if (informationTableViewCell == nil) {
            
            informationTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"InformationTableViewCell" owner:nil options:nil] lastObject];
        }
        
        return informationTableViewCell;
        
    } else if (indexPath.row == 1 || indexPath.row == 2) {
        
        InformationDetailImageTableViewCell *informationDetailImageTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"InformationDetailImageTableViewCell"];
        
        if (informationDetailImageTableViewCell == nil) {
            
            informationDetailImageTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"InformationDetailImageTableViewCell" owner:nil options:nil] lastObject];
        }
        
        return informationDetailImageTableViewCell;
        
        
    } else {
        
        InformationDetailDownTableViewCell *informationDetailDownTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"InformationDetailDownTableViewCell"];
        
        if (informationDetailDownTableViewCell == nil) {
            
            informationDetailDownTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"InformationDetailDownTableViewCell" owner:nil options:nil] lastObject];
        }
        
        return informationDetailDownTableViewCell;
        
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
