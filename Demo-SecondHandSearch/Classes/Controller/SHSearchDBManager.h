//
//  SHSearchDBManager.h
//  Demo-SecondHandSearch
//
//  Created by Suning on 16/6/16.
//  Copyright © 2016年 jf. All rights reserved.
//
//  本地数据库管理

#import <Foundation/Foundation.h>

@interface SHSearchDBManager : NSObject

/** 数据库单例 */
+ (SHSearchDBManager *)shareSearchDBManage;

/** 搜索数据插入数据库 */
- (void)insterSearchArr:(NSString *)searchStr;

/** 根据关键字删除搜索数据 */
- (void)deleteSearchStrByKeyword:(NSString *)keyWord;

/** 删除全部数据 */
- (void)deleteAllSearchStr;

/** 获取数据库里面的全部数据 */
- (NSMutableArray *)findAllSearch;

/** 删除最老的那条数据 */
-(void)deleteTheOldestSearchStr;

@end
