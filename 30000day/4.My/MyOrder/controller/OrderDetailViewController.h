//
//  OrderDetailViewController.h
//  30000day
//
//  Created by GuoJia on 16/4/6.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "ShowBackItemViewController.h"

@interface OrderDetailViewController : STRefreshViewController

@property (nonatomic,copy)NSString *orderNumber;//订单标号

@property (nonatomic,copy) NSString *status;//支付状态

@end