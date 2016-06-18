//
//  SHSearchDBManager.m
//  Demo-SecondHandSearch
//
//  Created by Suning on 16/6/16.
//  Copyright © 2016年 jf. All rights reserved.
//

#import "SHSearchDBManager.h"
#import <sqlite3.h>
#import "FMDB.h"

#define FileName   @"SearchDataBase"
#define TableName  @"SearchDataBase"

@interface SHSearchDBManager()

/** 数据库路径 */
@property(nonatomic,copy) NSString *dbPath;

@end

@implementation SHSearchDBManager

+(SHSearchDBManager *)shareSearchDBManage{
    static SHSearchDBManager *shareDB = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareDB = [[self alloc] init];
        [shareDB creatDataBase];
    });
    return shareDB;
}

/** 数据库中创建表 */
-(void)creatDataBase{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [file stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",FileName]];
    self.dbPath = filePath;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // 表不存在，创建表
    if (![manager fileExistsAtPath:filePath]) {
        FMDatabase *db = [FMDatabase databaseWithPath:filePath];
        if ([db open]) {
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (rowid INTEGER PRIMARY KEY AUTOINCREMENT, keyWord text)",TableName];
            BOOL isSuccess = [db executeUpdate:sql];
            if (isSuccess) {
                //建表成功
//                NSLog(@"建表成功");
            } else{
               //建表失败
//                NSLog(@"建表失败");
            }
//            [db close];
        }
    }
}

-(void)insterSearchArr:(NSString *)searchStr{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (keyWord) VALUES (?)",TableName];
        BOOL isSuccess = [db executeUpdate:insertSql,searchStr];
        if (isSuccess) {
//            NSLog(@"数据添加成功");
            [db close];
        } else {
//            NSLog(@"数据添加失败");
        }
    }
}

-(NSMutableArray *)findAllSearch{
    NSMutableArray *arr = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ order by rowid desc",TableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *keyWord = [rs stringForColumn:@"keyWord"];
            [arr addObject:keyWord];
        }
        [db close];
    }
    return arr;
}

-(void)deleteSearchStrByKeyword:(NSString *)keyWord{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE keyWord = '%@'",TableName,keyWord];
        BOOL isSuccess = [db executeUpdate:sql];
        if (isSuccess) {
//            NSLog(@"单条数据删除成功");
            [db close];
        } else {
//            NSLog(@"单条数据删除失败");
        }
    }
}

-(void)deleteAllSearchStr{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE 1>0",TableName];
        BOOL isSuccess = [db executeUpdate:sql];
        if (isSuccess) {
//            NSLog(@"所有数据删除成功");
            [db close];
        } else {
//            NSLog(@"所有数据删除失败");
        }
    }
}

-(void)deleteTheOldestSearchStr{
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    NSMutableArray *arr = [NSMutableArray array];
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",TableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *resultStr = [rs stringForColumn:@"keyWord"];
            [arr addObject:resultStr];
        }
        NSString *searchStr = [arr firstObject];
        NSString *sqlDel = [NSString stringWithFormat:@"DELETE FROM %@ WHERE keyWord = '%@'",TableName,searchStr];
        BOOL isSuccess = [db executeUpdate:sqlDel];
        if (isSuccess) {
            [db close];
        }
    }
}

@end
