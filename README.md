# Demo-SecondHandSearch
模仿闲鱼的搜索历史，条数有最大限制，搜索结果按从最新到最旧排列，并且有去重操作。
<br/>可以删除单条历史记录，也可以删除所有记录。
<br/>效果如下：
<br/>
![image](https://github.com/Apologize327/Demo-SecondHandSearch/blob/master/demo-searchResult.gif)
<br/>
在模仿闲鱼的搜索历史中，需要将结果保存在本地，并且有如下要求：
<br/>①搜索结果倒序展示，即最新的搜索结果展示在最上边
<br/>②搜索结果不能重复
<br/>③最多存储10条
<br/>
<br/>对于这些要求，可以如下解决
<br/>
**①搜索结果倒序展示，即最新的搜索结果展示在最上边**
<br/>
对于该条需求，只需在FMDB搜索时，按照主键rowid倒序展示即可
<br/>
  <pre lang="OC"><code>
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
  </code></pre>
<br/>
<br/>
**②搜索结果不能重复**
<pre lang="OC"><code>
/** 去除数据库已有的相同搜索结果，先删除旧的，再插入新的，这样不影响结果显示 */
-(void)removeSameData:(NSString *)searchStr{
    NSArray *tempArr = [[SHSearchDBManager shareSearchDBManage] findAllSearch];
    if ([tempArr containsObject:searchStr]) {
        [[SHSearchDBManager shareSearchDBManage] deleteSearchStrByKeyword:searchStr];
    }
    [[SHSearchDBManager shareSearchDBManage] insterSearchArr:searchStr];
}
</code></pre>
<br/>
<br/>
**③最多存储10条**
<pre lang="OC"><code>
#define MaxCount    10 //最多历史结果条数

/** 保持数据库只存10条数据，若有新的，则删除最旧的 */
-(void)moreThanMaxNumSearchStr:(NSString *)searchStr{
    NSArray *tempArr = [[SHSearchDBManager shareSearchDBManage] findAllSearch];
    if (tempArr.count > MaxCount) {
        [[SHSearchDBManager shareSearchDBManage] deleteTheOldestSearchStr];
    }
}
</code></pre>
<br/>
<br/>
然后在往数据库添加新数据时，去重和限制条数是有顺序的
<br/>
<pre lang="OC"><code>
-(void)insertDataBase:(NSString *)searchStr{
    if (searchStr.length==0) {
        return;
    } else {
        //先去重再添加新的
        [self removeSameData:searchStr];
        [self moreThanMaxNumSearchStr:searchStr];
        [_historyTableView reloadData];
    }
}
</code></pre>
