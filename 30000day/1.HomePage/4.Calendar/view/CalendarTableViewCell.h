//
//  CalendarTableViewCell.h
//  30000day
//
//  Created by GuoJia on 16/3/29.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarTableViewCell : UITableViewCell

//点击日期回调
@property (nonatomic,copy) void (^chooseDateBlock)();

@end
