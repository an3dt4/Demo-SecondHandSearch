//
//  HistoryTableViewCell.m
//  Demo-SecondHandSearch
//
//  Created by Suning on 16/6/16.
//  Copyright © 2016年 jf. All rights reserved.
//

#import "HistoryTableViewCell.h"

@interface HistoryTableViewCell(){
    UILabel *_contentLab;
    UIButton *_clearBtn;
}

@end

@implementation HistoryTableViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpBackground];
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteTheHistory" object:@{@"cell":self}];
    }
    return self;
}

-(void)setUpBackground{
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 30)];
    lab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:lab];
    _contentLab = lab;
    
    CGFloat btnW = 20;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kScreenWidth-10-btnW, lab.top, btnW, lab.height);
    [self.contentView addSubview:btn];
    _clearBtn = btn;
    [btn addTarget:self action:@selector(clickTheDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithRed:231/255.0 green:232/255.0 blue:232/255.0 alpha:1];
    [self.contentView addSubview:line];
}

-(void)clickTheDeleteBtn{
    if (_delegate && [_delegate respondsToSelector:@selector(clickClearBtn:searchStr:)]) {
        [_delegate clickClearBtn:self.cellIndex searchStr:_contentLab.text];
    }
}

-(void)setLabName:(NSString *)labName{
    _contentLab.text = labName;
}

-(void)setClearBtnName:(NSString *)clearBtnName{
    [_clearBtn setImage:[UIImage imageNamed:clearBtnName] forState:UIControlStateNormal]; ;
}

-(void)setColorName:(UIColor *)colorName{
    _contentLab.textColor = colorName;
}

-(void)setCellIndex:(NSInteger)cellIndex{
    _cellIndex = cellIndex;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
