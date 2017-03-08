//
//  TBRefreshFootView.h
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import <UIKit/UIKit.h>

const static int footerRefreshHeight = 35  ;

@interface TBRefreshFootView : UIView

@property (nonatomic, copy) void(^ReturnBlock)();

//结束下拉加载
- (void)endFooterRefreshing;

//没有更多数据
-(void)NoMoreData;

//将没有更多数据状态设置为正常状态
-(void)ResetNomoreData;
@end
