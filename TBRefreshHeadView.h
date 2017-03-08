//
//  TBRefreshHeadView.h
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import <UIKit/UIKit.h>

const static int headerRefeshHight=60;

@interface TBRefreshHeadView : UIView

@property (nonatomic, copy) void(^ReturnBlock)();


//开始下拉刷新
-(void)beginRefreshing;

//结束下拉刷新
-(void)endHeadRefresh;

@end
