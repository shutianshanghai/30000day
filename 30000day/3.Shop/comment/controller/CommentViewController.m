//
//  CommentViewController.m
//  30000day
//
//  Created by wei on 16/3/12.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "CommentViewController.h"
#import "ShopDetailCommentTableViewCell.h"
#import "CommentOptionsTableViewCell.h"
#import "AppointmentConfirmViewController.h"
#import "Height.h"
#import "CommentDetailsViewController.h"
#import "CommentModel.h"
#import "CommentDetailsTableViewCell.h"


@interface CommentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *commentModelArray;

@property (nonatomic,strong) NSMutableArray *willRemoveArray;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"全部评论";
    
    self.tableViewStyle = STRefreshTableViewGroup;
    
    [self.tableView setDataSource:self];
    
    [self.tableView setDelegate:self];
    
    self.tableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    
    self.isShowHeadRefresh = NO;
    
    self.isShowFootRefresh = NO;
    
    self.isShowBackItem = YES;
    
    [self.dataHandler sendfindCommentListWithProductId:8 type:3 pId:0 userId:-1 Success:^(NSMutableArray *success) {
        
        self.commentModelArray = [NSMutableArray arrayWithArray:success];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
    
    
}

#pragma mark --- 上啦刷新和下拉刷新

- (void)headerRefreshing {
    
    [self.tableView.mj_header endRefreshing];
}

- (void)footerRereshing {
    
    [self.tableView.mj_footer endRefreshing];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else {
        
        return self.commentModelArray.count;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentModel *commentModel = self.commentModelArray[indexPath.row];
    
    
    if (indexPath.section == 0) {
        
        return 44;
        
    } else {
        
        if (commentModel.level == 1) {

            return 238 + [Height heightWithText:commentModel.remark width:[UIScreen mainScreen].bounds.size.width fontSize:15.0];
            
        } else {
        
            if (commentModel.picUrl != nil && ![commentModel.picUrl isEqualToString:@"test.img"] && ![commentModel.picUrl isEqualToString:@"/img.img"]) {
                
                return 90 + (([UIScreen mainScreen].bounds.size.width - 106) / 3) + [Height heightWithText:commentModel.remark width:[UIScreen mainScreen].bounds.size.width fontSize:15.0];
                
            } else {
            
                return 90 + [Height heightWithText:commentModel.remark width:[UIScreen mainScreen].bounds.size.width fontSize:15.0];
                
            }
        
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.001;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 10;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (indexPath.section == 0) {
        
        CommentOptionsTableViewCell *commentOptionsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"CommentOptionsTableViewCell"];
        
        if (commentOptionsTableViewCell == nil) {
            
            commentOptionsTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"CommentOptionsTableViewCell" owner:nil options:nil] lastObject];
            
        }
        
        [commentOptionsTableViewCell setChangeStateBlock:^(UIButton *changeStatusButton) {
           
            if (changeStatusButton.tag == 1) {
                
                [self showToast:@"1"];
                
            } else if (changeStatusButton.tag == 2){
                
                [self showToast:@"2"];
            
            } else if (changeStatusButton.tag == 3){
                
                [self showToast:@"3"];
            
            } else {
                
                [self showToast:@"4"];
            
            }
            
        }];
        
        return commentOptionsTableViewCell;

        
    } else {
        
        CommentModel *commentModel = self.commentModelArray[indexPath.row];
        
        if (commentModel.level == 1) {
            
            ShopDetailCommentTableViewCell *shopDetailCommentTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ShopDetailCommentTableViewCell"];
            
            if (shopDetailCommentTableViewCell == nil) {
                
                shopDetailCommentTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"ShopDetailCommentTableViewCell" owner:nil options:nil] lastObject];
                
            }
            
            [shopDetailCommentTableViewCell setChangeStateBlock:^(UIButton *changeStatusButton) {
                
                [self cellDataProcessing:changeStatusButton commentModel:commentModel index:indexPath];

            }];
            
            shopDetailCommentTableViewCell.commentModel = commentModel;
            
            return shopDetailCommentTableViewCell;
            
        } else {
            
            CommentDetailsTableViewCell *commentDetailsTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"CommentDetailsTableViewCell"];
            
            if (commentDetailsTableViewCell == nil) {
                
                commentDetailsTableViewCell = [[[NSBundle mainBundle] loadNibNamed:@"CommentDetailsTableViewCell" owner:nil options:nil] lastObject];
                
            }

            [commentDetailsTableViewCell setChangeStateBlock:^(UIButton *changeStatusButton) {
                
                [self cellDataProcessing:changeStatusButton commentModel:commentModel index:indexPath];
                
            }];

            commentDetailsTableViewCell.commentModel = commentModel;
            
            return commentDetailsTableViewCell;
            
        }
        
    }
    
    return nil;
}

#pragma mark - Table view data delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return;
        
    } else {

        CommentDetailsViewController *controller = [[CommentDetailsViewController alloc] init];
        
        controller.commentModel = self.commentModelArray[indexPath.row];
        
        controller.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
}

- (void)removeDataWithPId:(NSInteger)willRemoveId {
    
    for (int i = 0; i < self.commentModelArray.count; i++) {
        
        CommentModel *model = self.commentModelArray[i];
        
        if ([model.pId integerValue] == willRemoveId) {
            
            [self removeDataWithPId:[model.commentId integerValue]];
            
            [self.willRemoveArray addObject:[NSNumber numberWithInt:i]];
        }
    }
    
}

- (void)cellDataProcessing:(UIButton *)changeStatusButton
              commentModel:(CommentModel *)commentModel
                     index:(NSIndexPath *)indexPath{
    
    if (changeStatusButton.tag == 1) {
        
        [self.dataHandler sendfindCommentListWithProductId:8 type:-1 pId:[commentModel.commentId integerValue] userId:-1 Success:^(NSMutableArray *success) {
            
            changeStatusButton.tag = 2;
            
            for (int i = 0; i < success.count; i++) {
                
                CommentModel *comment = success[i];
                comment.level = 0;
                comment.pName = commentModel.userName;
                [self.commentModelArray insertObject:comment atIndex:indexPath.row + 1];
                
            }
            
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            
        }];
        
    } else {
        
        changeStatusButton.tag = 1;
        
        self.willRemoveArray = [NSMutableArray array];
        
        [self removeDataWithPId:[commentModel.commentId integerValue]];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.willRemoveArray.count; i++) {
            
            NSInteger index =  [self.willRemoveArray[i] integerValue];
            
            [array addObject:self.commentModelArray[index]];
            
        }
        
        [self.commentModelArray removeObjectsInArray:array];
        
        [self.tableView reloadData];
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
