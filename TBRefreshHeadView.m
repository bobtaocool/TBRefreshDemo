//
//  TBRefreshHeadView.m
//  TBRefreshDemo
//
//  Created by bob on 2017/3/7.
//  Copyright © 2017年 bob. All rights reserved.
//

#import "TBRefreshHeadView.h"
#import "TBRefresh.h"
typedef enum {
    
    TBStatueNomal=0,//默认状态
    
    TBStatuePulling,//下拉状态
    
    TBStatueRefreshing//刷新状态
    
    
}state;


@interface TBRefreshHeadView ()

/*
 *设置图片
 */
@property (nonatomic,strong)UIImageView *imageView;
/*
 *设置文字label
 */
@property (nonatomic,strong)UILabel *label;

/*
 *菊花控件
 */
@property (nonatomic,weak)UIActivityIndicatorView *activityView;
/*
 * 记录当前状态
 */
@property (nonatomic, assign)int currentState;
/*
 * tableView弱引用
 */
@property (nonatomic,weak)UIScrollView *superScrollview;
/*
 * 记录父控件初始时的偏移量
 */
@property (nonatomic,assign)CGFloat contentOffSetY;


@end


@implementation TBRefreshHeadView

-(instancetype)init
{
    if (self=[super initWithFrame:CGRectMake(0,  -headerRefeshHight, ScreenWidth,  headerRefeshHight)]) {
        
        [self SetUpUI];
        
    }
    
    
    return self;
    
}

-(void)SetUpUI
{
    
    //图片位置
    CGFloat imagViewWH = 40;
    
    CGFloat imagViewX = ScreenWidth * 0.4;
    
    self.imageView.frame = CGRectMake(  imagViewX, (self.frame.size.height - imagViewWH) / 2, 15, imagViewWH);
    
    //文字位置
    CGFloat labelX = CGRectGetMaxX(self.imageView.frame);
    self.label.frame = CGRectMake(labelX , (self.frame.size.height - imagViewWH) / 2, 100, imagViewWH);
    
    //菊花位置
    self.activityView.frame =self.imageView.frame;

}


#pragma mark -添加观察者
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
  
        if (self.superScrollview.contentInset.top==64) {
            
            self.contentOffSetY=self.superScrollview.contentInset.top;
        }
        CGFloat y = self.superScrollview.contentOffset.y;
        if (self.superScrollview.isDragging) {
            //正在拖动
            
            if (y<  -self.contentOffSetY &&y> -self.contentOffSetY - headerRefeshHight && self.currentState ==TBStatuePulling) {
                //下拉状态->正常状态
                self.currentState = TBStatueNomal;
                
            }else if (y <= -self.contentOffSetY - headerRefeshHight && self.currentState == TBStatueNomal)
                //正常状态->下拉状态
            {
                self.currentState = TBStatuePulling;
            }
    
        }else if(self.currentState ==TBStatuePulling &&y <= -self.contentOffSetY - headerRefeshHight){ //拖拽释放
            self.currentState = TBStatueRefreshing;
            
        }

    }
}


#pragma 重写setState方法，在该方法中修改文字，图片
- (void)setCurrentState:(int)currentState {
    
    if (_currentState == currentState)
    { //如果状态没有变化，则返回
        return;
    }
    _currentState = currentState;
    if (_currentState ==TBStatueNomal) {
        //默认状态 为正常状态
        
        self.imageView.hidden = NO;
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.imageView stopAnimating];
            self.label.text = @"下拉刷新";
            self.imageView.image = [UIImage imageNamed:@"arrowdown"];
            
                   }];
        
    }else if (_currentState ==TBStatuePulling){
        //下拉状态
        
        self.imageView.hidden = NO;
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            
            [self.imageView stopAnimating];
            self.label.text= @"释放刷新";
            self.imageView.image = [UIImage imageNamed:@"arrowup"];
            }];
        
    }else if (_currentState == TBStatueRefreshing){
        //刷新状态
        self.label.text = @"正在刷新...";

        self.activityView.hidden = NO;
        self.imageView.hidden = YES;
        [self.activityView startAnimating];
   
        [UIView animateWithDuration:0.25 animations:^{
            
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top + headerRefeshHight, self.superScrollview.contentInset.left, self.superScrollview.contentInset.bottom, self.superScrollview.contentInset.right);
            
        }];
        
        if (self.ReturnBlock) {
            
            self.ReturnBlock();
            
        }
        
        
    }
}

#pragma 开始刷新
- (void)beginRefreshing {
    
    self.currentState = TBStatueRefreshing;
}

#pragma 结束下拉刷新
-(void)endHeadRefresh {
    
    if (self.currentState == TBStatueRefreshing) {
        
        self.currentState = TBStatueNomal;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top - headerRefeshHight, self.superScrollview.contentInset.left, self.superScrollview.contentInset.bottom, self.superScrollview.contentInset.right);
        }];
        
    }
}

- (void)dealloc
{
    NSLog(@"头部已经释放");
}



#pragma mark --懒加载子控件
//  图片控件
- (UIImageView *)imageView {
    if (_imageView == nil) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
      
        imageView.image = [UIImage imageNamed:@"arrowdown"];
        
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview: imageView];
        _imageView = imageView;
    }
    return _imageView;
}

// 文本控件
- (UILabel *)label {
    
    if (_label == nil) {
   
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"下拉刷新";
        [label sizeToFit];
        [self addSubview:label];
        _label = label;
    }
    return _label;
}

//菊花控件
- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView = activityView;
        activityView.bounds = self.imageView.bounds;
        activityView.autoresizingMask = self.imageView.autoresizingMask;
        
        [self addSubview: activityView];
        
    }
    return _activityView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
