//
//  STManager.h
//  30000day
//
//  Created by GuoJia on 16/4/16.
//  Copyright © 2016年 GuoJia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STManager : NSObject

//自定义对象归档到文件（该自定义对象一定要实现NSCoding协议）
//存储入系统的文件名字为:该类名.src
- (void)encodeDataObject:(id)object;

//自定义对象从文件解档出来（该自定义对象一定要实现NSCoding协议）
//存储入系统的文件名字为:该类名.src
- (id)decodeObject;

- (void)encodeDataObject:(id)object withKey:(NSString *)key;

- (id)decodeObjectwithKey:(NSString *)key;

- (void)deleteDataObjectWithKey:(NSString *)key;

@end
