//
//  ViewController.m
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import "ViewController.h"
#import "TBRefresh.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *mainTableview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
     [self.view addSubview:self.mainTableview];
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(UITableView*)mainTableview
{
    if (!_mainTableview) {
    
        __weak ViewController *weakself=self;
        _mainTableview=[[UITableView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        
        _mainTableview.delegate=self;
        
        _mainTableview.dataSource=self;
        
        [_mainTableview addRefreshHeaderWithBlock:^{
          
            [weakself LoadDatas];
            
        }];
        
        [_mainTableview addRefreshFootWithBlock:^{
          
            [weakself LoadMoreDatas];
        }];
   
    }
    
    
    return _mainTableview;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 10;
    
    
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"这是第%ld行",indexPath.row];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 80;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==1) {
        
        ViewController *vc=[ViewController new];
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
    }else{
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
    
    
}


#pragma mark-加载数据

-(void)LoadDatas
{
    
    [self.mainTableview.footer ResetNomoreData];
    
    // 模拟延时设置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.mainTableview.header endHeadRefresh];
        
    });
    
    
    
}

-(void)LoadMoreDatas
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.mainTableview.footer NoMoreData];
        
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
