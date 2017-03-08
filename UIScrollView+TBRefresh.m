//
//  UIScrollView+TBRefresh.m
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import "UIScrollView+TBRefresh.h"
#import "TBRefreshFootView.h"
#import "TBRefreshHeadView.h"
#import <objc/runtime.h>
@implementation UIScrollView (TBRefresh)

#pragma mark-关联头部
-(void)setHeader:(TBRefreshHeadView *)header
{
    
   objc_setAssociatedObject(self, @selector(header), header, OBJC_ASSOCIATION_ASSIGN);
    
}

-(TBRefreshHeadView*)header
{
     return objc_getAssociatedObject(self, @selector(header));
}


#pragma mark-关联底部
-(void)setFooter:(TBRefreshFootView *)footer
{
    
    objc_setAssociatedObject(self, @selector(footer), footer, OBJC_ASSOCIATION_ASSIGN);
    
}

-(TBRefreshFootView*)footer
{
    
    return objc_getAssociatedObject(self, @selector(footer));
    
}

#pragma mark-初始化头部
-(void)addRefreshHeaderWithBlock:(void (^)())Block
{
    TBRefreshHeadView *TBheader=[TBRefreshHeadView new];
    
    TBheader.ReturnBlock=Block;
    
    self.header=TBheader;
    
    [self insertSubview:TBheader atIndex:0];
    
}

#pragma mark-初始化底部
-(void)addRefreshFootWithBlock:(void (^)())Block
{
    
    TBRefreshFootView *TBfooter=[TBRefreshFootView new];
    
    TBfooter.ReturnBlock=Block;
    
    self.footer=TBfooter;
    
    [self insertSubview:TBfooter atIndex:0];

}

#pragma mark-测试可得，tableView先释放，所以在释放之前把头部和尾部释放，移除观察者，不然会奔溃
-(void)dealloc
{
    if (self.header) {
        
        [self removeObserver:self.header forKeyPath:@"contentOffset"];
        
        self.header=nil;
        
    }
    
    if (self.footer) {
        
        [self removeObserver:self.footer forKeyPath:@"contentOffset"];
        
        self.footer=nil;
    }
    
    
}

@end
