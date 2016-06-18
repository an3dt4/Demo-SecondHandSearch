//
//  SHSearchGoodsViewController.m
//  Demo-SecondHandSearch
//
//  Created by Suning on 16/6/15.
//  Copyright © 2016年 jf. All rights reserved.
//

#import "SHSearchGoodsViewController.h"
#import "HistoryTableViewCell.h"
#import "SHSearchDBManager.h"

#define MaxCount    2 //最多历史结果条数

@interface SHSearchGoodsViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ClearHistoryDelegate>{
    UISearchDisplayController *_searchController;
    /** 历史搜索表 */
    UITableView *_historyTableView;
    UISearchBar *_searchBar;
}

/** 历史搜索结果 */
@property(nonatomic,strong) NSMutableArray *historySearchArr;

@end

@implementation SHSearchGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241/255.0 green:242/255.0 blue:243/255.0 alpha:1];
    
    [self setUpBackground];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapWholeView)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"deleteTheHistory" object:nil queue:nil usingBlock:^(NSNotification *note) {
        HistoryTableViewCell *cell = (HistoryTableViewCell *)note.object[@"cell"];
        cell.delegate = self;
    }];
}

-(void)setUpBackground{
    CGFloat searchBarY = self.prefersStatusBarHidden ? 0:20;
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, searchBarY, kScreenWidth, 44)];
    searchBar.placeholder = @"请输入宝贝关键字";

    //自定义搜索框背景
    UIView *backView = [[UIView alloc]initWithFrame:searchBar.bounds];
    backView.backgroundColor = [UIColor colorWithRed:241/255.0 green:242/255.0 blue:243/255.0 alpha:1];
    [searchBar insertSubview:backView atIndex:1];
    
    searchBar.tintColor = [UIColor colorWithRed:68/255.0 green:69/255.0 blue:70/255.0 alpha:1];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
    
    //设置历史搜索tableview
    CGFloat tempH = self.prefersStatusBarHidden?0:20;
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, searchBar.bottom, kScreenWidth, kScreenHeight-searchBar.height-tempH) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _historyTableView = tableView;
    
}

-(void)tapWholeView{
    [_searchBar resignFirstResponder];
}


#pragma mark - tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.historySearchArr.count == 0) {
        return self.historySearchArr.count;
    } else {
        return self.historySearchArr.count + 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIden";
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HistoryTableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
    }
    cell.cellIndex = indexPath.row;
    
    if (indexPath.row==0) {
        cell.labName = @"历史搜索";
        cell.clearBtnName = @"delete_icon";
        cell.colorName = [UIColor colorWithHexString:@"#666666"];
    } else {
        cell.labName = [self.historySearchArr objectAtIndex:(indexPath.row-1)];
        cell.clearBtnName = @"close_ico_s";
        cell.colorName = [UIColor colorWithHexString:@"#999999"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //利用service搜索
    //………………
}

#pragma mark - DeleteHistoryViewCellDelegate
-(void)clickClearBtn:(NSInteger)cellIndexRow searchStr:(NSString *)searchStr{
    if (cellIndexRow==0) {
        [self.historySearchArr removeAllObjects];
        [[SHSearchDBManager shareSearchDBManage] deleteAllSearchStr];
    } else {
        [self.historySearchArr removeObjectAtIndex:(cellIndexRow-1)];
        [[SHSearchDBManager shareSearchDBManage] deleteSearchStrByKeyword:searchStr];
    }
    [_historyTableView reloadData];
}

#pragma mark - UISearchBarDelegate
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}

//开始编辑时调用
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            UIButton * cancel =(UIButton *)view;
            [cancel setTitle:@"取消" forState:UIControlStateNormal];
            cancel.titleLabel.font = [UIFont systemFontOfSize:14];
        }
    }
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self insertDataBase:searchBar.text]; // 插入数据库
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 操作数据库
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

/** 去除数据库已有的相同搜索结果，先删除旧的，再插入新的，这样不影响结果显示 */
-(void)removeSameData:(NSString *)searchStr{
    NSArray *tempArr = [[SHSearchDBManager shareSearchDBManage] findAllSearch];
    if ([tempArr containsObject:searchStr]) {
        [[SHSearchDBManager shareSearchDBManage] deleteSearchStrByKeyword:searchStr];
    }
    [[SHSearchDBManager shareSearchDBManage] insterSearchArr:searchStr];
}

/** 保持数据库只存10条数据，若有新的，则删除最旧的 */
-(void)moreThanMaxNumSearchStr:(NSString *)searchStr{
    NSArray *tempArr = [[SHSearchDBManager shareSearchDBManage] findAllSearch];
    if (tempArr.count > MaxCount) {
        [[SHSearchDBManager shareSearchDBManage] deleteTheOldestSearchStr];
    }
}

#pragma mark - setter/getter
-(NSMutableArray *)historySearchArr{
    if (!_historySearchArr) {
        _historySearchArr = [[SHSearchDBManager shareSearchDBManage] findAllSearch];
    }
    return _historySearchArr;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
