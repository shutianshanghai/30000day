//
//  CityViewController.h
//  30000day
//
//  Created by GuoJia on 16/3/17.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "AddressBookBaseViewController.h"
#import "DataModel.h"

@interface CityViewController : AddressBookBaseViewController

//点击按钮后的回调
@property (nonatomic,copy) void (^cityBlock)(DataModel *);

@end
