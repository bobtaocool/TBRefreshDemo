//
//  UIScrollView+TBRefresh.h
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBRefreshHeadView;

@class TBRefreshFootView;

@interface UIScrollView (TBRefresh)
//下拉刷新
@property(nonatomic,weak)TBRefreshHeadView *header;
//上拉加载
@property(nonatomic,weak)TBRefreshFootView *footer;


-(void)addRefreshHeaderWithBlock:(void (^)())Block;


-(void)addRefreshFootWithBlock:(void (^)())Block;

@end
