//
//  ProvinceModel.m
//  30000day
//
//  Created by GuoJia on 16/3/24.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import "ProvinceModel.h"

@implementation ProvinceModel

- (NSDictionary *)objectClassInArray {
    
    return @{ @"cityList" : [CityModel class]};
}

//- (Class)objectClassInArrayForClass:(Class)c {
//    
//    
//    
//}

#pragma mark --- NSCoding的协议
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ([self init]) {
        
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
        self.cityList = [aDecoder decodeObjectForKey:@"cityList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    
    [aCoder encodeObject:self.cityList forKey:@"cityList"];
    
}

@end

@implementation CityModel


- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ([self init]) {
        
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
        self.businessCircleList = [aDecoder decodeObjectForKey:@"businessCircleList"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    
    [aCoder encodeObject:self.businessCircleList forKey:@"businessCircleList"];
}

@end

@implementation BusinessCircleModel

#pragma mark ---- 将对象转化为NSData的方法

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if ([self init]) {
        
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end

