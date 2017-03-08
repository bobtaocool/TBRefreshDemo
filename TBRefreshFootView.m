//
//  TBRefreshFootView.m
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import "TBRefreshFootView.h"
#import "TBRefresh.h"

/*
 *枚举下拉刷新的几种状态
 */
typedef enum {
    
    TBStateNomorl = 0, //默认状态
    TBStatePulling,    //上拉状态
    TBStateRefreshing, //正在刷新状态
    TBStateFinsh //没有更多数据
    
}state;

@interface TBRefreshFootView ()

@property (nonatomic,assign)BOOL lastHidden;
/*
 *用于设置文字文本
 */
@property (nonatomic,strong)UILabel *label;

/*
 * 记录当前状态
 */
@property (nonatomic, assign)int currentState;
/*
 * TableView弱引用
 */
@property (nonatomic,weak)UIScrollView *superScrollview;

/*
 * 菊花
 */
@property(nonatomic,strong)UIActivityIndicatorView *ActivityIndicator;

@end


@implementation TBRefreshFootView

-(instancetype)init
{
    if (self=[super initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, footerRefreshHeight)]) {
        
        [self setUpUI];
        
        self.currentState=TBStateNomorl;
        
    }

    return self;
    
}

-(void)setUpUI
{
    
    [self.label sizeToFit];
    
    self.label.frame = CGRectMake((ScreenWidth - self.label.frame.size.width ) / 2, 2.5, self.label.frame.size.width, 30);
    
    self.ActivityIndicator.center=CGPointMake(self.label.frame.origin.x-20, 17.5);

}


#pragma 加到父控件时会调用该方法,并添加观察者
- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        self.superScrollview = (UIScrollView *)newSuperview;
        
        [self.superScrollview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }else {
        
        if (self.superScrollview) {
            
             [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
            
        }
        
       
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:  (NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        if (self.currentState==TBStateFinsh) {
            
            return;
        }
        
        [self UpdateRefreshView];
    }
}

#pragma 更新刷新视图
- (void)UpdateRefreshView{
    
    int _lastPosition = 0;
    int currentPostion = self.superScrollview.contentOffset.y;
    
    if(self.superScrollview.isDragging)
    {
        CGFloat y = self.superScrollview.contentSize.height;
        if ( y < ScreenHeight) {
            
            y = ScreenHeight;
        }
        if (currentPostion - _lastPosition > 0) {//上拉
            
            _lastPosition = currentPostion;
            
            self.hidden = NO;
            
            self.frame = CGRectMake(0, y, ScreenWidth, footerRefreshHeight);
            
            if((currentPostion + self.superScrollview.frame.size.height >= self.superScrollview.contentSize.height)&&(currentPostion + self.superScrollview.frame.size.height < self.superScrollview.contentSize.height + footerRefreshHeight))
            {
                //下拉到最后一个cell未显示出来
                
                self.currentState = TBStateNomorl;
                
            }else if(currentPostion + self.superScrollview.frame.size.height >= self.superScrollview.contentSize.height + footerRefreshHeight && self.currentState == TBStateNomorl){
                
                //显示出最后一个cell
                self.currentState = TBStatePulling;
            }
        }
        else if (_lastPosition - currentPostion > 0)//下拉
        {
            _lastPosition = currentPostion;
            self.hidden = YES;
            self.frame = CGRectMake(0, y, ScreenWidth, footerRefreshHeight);
        }
        
    }
    else if(self.currentState == TBStatePulling && currentPostion + self.superScrollview.frame.size.height >= self.superScrollview.contentSize.height + footerRefreshHeight){
        self.currentState = TBStateRefreshing;
    }
    
}

#pragma mark -- 重写setState方法，在该方法中修改文字，图片
- (void)setCurrentState:(int)currentState {
    
    if (_currentState == currentState) {
        //相等直接返回
        return;
    }
    _currentState = currentState;
    if (_currentState ==TBStateNomorl ) {
        //默认状态正常状态
        
        self.label.text = @"查看更多";
        
        [self.ActivityIndicator stopAnimating];
        
    }else if (_currentState == TBStatePulling){
        
        self.label.text = @"查看更多";
        
        [self.ActivityIndicator stopAnimating];
    }
    else if (_currentState == TBStateRefreshing){
        //释放刷新
        
        self.label.text = @"加载中...";
        
        [self.ActivityIndicator startAnimating];
        
        [UIView animateWithDuration:0.5 animations:^{
      
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top - footerRefreshHeight, self.superScrollview.contentInset.left, footerRefreshHeight, self.superScrollview.contentInset.right);
        }];
        
        if (self.ReturnBlock) {
            
            self.ReturnBlock();
            
        }
        
        
        
    }else if (_currentState==TBStateFinsh)
    {
        
        [self.ActivityIndicator stopAnimating];

    }
}

-(void)endFooterRefreshing {
    
    if (self.currentState ==TBStateRefreshing) {
        self.currentState = TBStateNomorl;
        //先隐藏掉后在改变frame,不然会有掉下去的效果
        self.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top + footerRefreshHeight, self.superScrollview.contentInset.left, footerRefreshHeight, self.superScrollview.contentInset.right);
        }];
        
    }
    
}


#pragma mark-没有更多数据
-(void)NoMoreData
{
    if (self.currentState ==TBStateRefreshing) {
        self.currentState = TBStateFinsh;
        
        self.label.text=@"加载完毕";
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top + footerRefreshHeight, self.superScrollview.contentInset.left, footerRefreshHeight, self.superScrollview.contentInset.right);
        }];

    }
}

#pragma mark-重置刷新状态
-(void)ResetNomoreData
{
    self.currentState = TBStateNomorl;

}


- (void)dealloc {
    //判断是否释放
    NSLog(@"底部已经释放");
    
}


#pragma mark --懒加载子控件

// 文本控件
- (UILabel *)label {
    if (_label == nil) {
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"查看更多    ";
        [label sizeToFit];
        [self addSubview:label];
        _label = label;
    }
    return _label;
}
// 菊花控件
-(UIActivityIndicatorView*)ActivityIndicator
{
    if (!_ActivityIndicator) {
        
        _ActivityIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [_ActivityIndicator stopAnimating];
        
        [_ActivityIndicator setHidesWhenStopped:YES];
        
        [self addSubview:_ActivityIndicator];
        
    }
    
    return _ActivityIndicator;
    
}


@end
