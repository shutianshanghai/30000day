//
//  ShopDetailCommentTableViewCell.m
//  30000day
//
//  Created by wei on 16/3/11.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "ShopDetailCommentTableViewCell.h"

@implementation ShopDetailCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkReply:(UIButton *)sender {
    
    if (self.changeStateBlock) {
        self.changeStateBlock();
    }
    
}


@end
