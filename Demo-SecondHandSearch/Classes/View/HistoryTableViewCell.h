//
//  HistoryTableViewCell.h
//  Demo-SecondHandSearch
//
//  Created by Suning on 16/6/16.
//  Copyright © 2016年 jf. All rights reserved.
//
//  历史结果cell

#import <UIKit/UIKit.h>

@protocol ClearHistoryDelegate <NSObject>

@optional
-(void)clickClearBtn:(NSInteger )cellIndexRow searchStr:(NSString *)searchStr;

@end

@interface HistoryTableViewCell : UITableViewCell

@property(nonatomic,copy) NSString *labName;

@property(nonatomic,copy) NSString *clearBtnName;

@property(nonatomic,strong) UIColor *colorName;

/** 该cell的行号 */
@property(nonatomic,assign) NSInteger cellIndex;

@property(nonatomic,weak) id<ClearHistoryDelegate> delegate;

@end
