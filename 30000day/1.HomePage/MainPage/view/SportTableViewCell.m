//
//  SportTableViewCell.m
//  30000day
//
//  Created by WeiGe on 16/7/7.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "SportTableViewCell.h"

@implementation SportTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)setSportInformationModel:(SportInformationModel *)sportInformationModel {

    _sportInformationModel = sportInformationModel;
    self.dateTimeLable.text = sportInformationModel.startTime;
    
    if (self.sportInformationModel.distance == nil || [self.sportInformationModel.distance isEqualToString:@"0"] || [self.sportInformationModel.distance isEqualToString:@"0.0"]) {
        [self.distanceLable setText:@"0.00"];
    } else {
        [self.distanceLable setText:[NSString stringWithFormat:@"%.2f",[self.sportInformationModel.distance floatValue]]];
    }

    self.timeLable.text = sportInformationModel.period == nil ? @"00:00:00" : [self TimeformatFromSeconds:sportInformationModel.period.integerValue];
    self.stepNumberLable.text = sportInformationModel.steps.stringValue;
    self.calorieLable.text = sportInformationModel.calorie == nil ? @"0.0" : [NSString stringWithFormat:@"%.1f",sportInformationModel.calorie.floatValue];
}

//秒转时分秒
- (NSString*)TimeformatFromSeconds:(NSInteger)seconds {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02d",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

@end
