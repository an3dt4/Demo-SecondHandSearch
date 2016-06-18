//
//  ViewController.m
//  Demo-CALayerTest
//
//  Created by Suning on 16/3/29.
//  Copyright © 2016年 jf. All rights reserved.
//

#import "ViewController.h"
#import "SHSearchGoodsViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    CGFloat btnW = 200;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((kScreenWidth-btnW)/2, 150, btnW, 80);
    [btn setTitle:@"搜索" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickTheNextBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)clickTheNextBtn{
    SHSearchGoodsViewController *search = [[SHSearchGoodsViewController alloc]init];
    [self presentViewController:search animated:YES completion:nil];
}

@end
