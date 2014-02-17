//
//  MCRefreshToolView.m
//  MCRefreshDemo
//
//  Created by 陈政 on 14-2-14.
//  Copyright (c) 2014年 sf Inc. All rights reserved.
//

#import "MCRefreshToolView.h"
#import <QuartzCore/QuartzCore.h>

#define kTableViewHeaderViewHeight          80

@interface MCRefreshToolView ()

@property (nonatomic , strong) UITableView *parentTableView;
@property (nonatomic , assign) MCRefreshToolViewType currentViewType;
@property (nonatomic , assign) MCRefreshToolStateType currentStateType;
@property (nonatomic , assign) CGPoint orignalOffset;

@property (nonatomic , strong) UILabel *textLabel;
@property (nonatomic , strong) UIImageView *backgroundView;

//@property (nonatomic , assign) BOOL isAvaliableForUserDragging;

@end

@implementation MCRefreshToolView

- (UIImageView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bk_tool"]];
    }
    return _backgroundView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        CGFloat labelHeight = 30.;
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - labelHeight, kScreenWidth, labelHeight)];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.shadowColor = [UIColor whiteColor];
        _textLabel.shadowOffset = CGSizeMake(1, 1);
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.text = @"下拉即可更新";
    }
    return _textLabel;
}

- (void)dealloc
{
    [self.parentTableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (id)initWithTableView:(UITableView *)tableView viewType:(MCRefreshToolViewType)viewType
{
    CGRect footerRefreshViewFrame;
    if (viewType == MCRefreshToolViewTypeFooter) {
        footerRefreshViewFrame = CGRectMake(0, MAX(tableView.contentSize.height, tableView.frame.size.height), kScreenWidth, kFooterLoadMorePullingDistance);
    } else if (viewType == MCRefreshToolViewTypeHeader) {
        footerRefreshViewFrame = CGRectMake(0, -kHeaderLoadMorePullingDistance, kScreenWidth, kHeaderLoadMorePullingDistance);
    }

    if ((self = [super initWithFrame:footerRefreshViewFrame])) {
        self.parentTableView = tableView;
        self.currentViewType = viewType;
        self.currentStateType = MCRefreshToolStateTypeNormal;

        [self.parentTableView addSubview:self];

        [self addSubview:self.textLabel];
        
        //添加一个假的tableViewHeader
        UIView *fakeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTableViewHeaderViewHeight)];
        fakeView.backgroundColor = [UIColor clearColor];
        self.parentTableView.tableHeaderView = fakeView;
        
        [self insertSubview:self.backgroundView atIndex:0];
        CGRect backgroundImageFrame = self.backgroundView.frame;
        backgroundImageFrame.origin = CGPointZero;
        backgroundImageFrame.size.height = kHeaderLoadMorePullingDistance + kTableViewHeaderViewHeight;
        self.backgroundView.frame = backgroundImageFrame;
        
        [self.parentTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.orignalOffset = [change[@"new"] CGPointValue];
    });
    CGPoint newOffsetPoint = [change[@"new"] CGPointValue];
    CGFloat currentOffset = 1.0 * (self.orignalOffset.y - newOffsetPoint.y);
    
    CGFloat percents = currentOffset / kHeaderLoadMorePullingDistance;
    
    [self animateViewWithPullingFactor:percents currentContentOffsetY:currentOffset];
}

- (void)animateViewWithPullingFactor:(CGFloat)factor currentContentOffsetY:(CGFloat)currentOffsetY
{
    if (self.currentStateType == MCRefreshToolStateTypeLoading) {
        return;
    }
    if (self.parentTableView.contentOffset.y < 0) {
        if (factor > 0.0 && factor <= 1.0) {
            self.textLabel.text = @"下拉即可更新";
            CGFloat offset = currentOffsetY;
            self.currentStateType = MCRefreshToolStateTypePulling;
            self.backgroundView.frame = CGRectMake(- offset, - offset, kScreenWidth + offset * 2, kHeaderLoadMorePullingDistance + kTableViewHeaderViewHeight + offset);
        } else if (factor > 1.0) {
            self.textLabel.text = @"释放立即更新";
            if (!self.parentTableView.isDragging) {
                self.textLabel.text = @"正在用力更新...";
                self.currentStateType = MCRefreshToolStateTypeLoading;
            }
        }
    }
    if (self.currentStateType == MCRefreshToolStateTypeLoading && !self.parentTableView.isDragging) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.parentTableView setContentInset:UIEdgeInsetsMake(kHeaderLoadMorePullingDistance + kTableViewHeaderViewHeight, 0, 0, 0)];
        } completion:^(BOOL finished) {
            if (finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(toolViewDidStartRefreshData)]) {
                    [self.delegate performSelector:@selector(toolViewDidStartRefreshData)];
                }
            }
        }];
    }
}

- (void)didFinishedRefreshData
{
    [UIView animateWithDuration:0.3 animations:^{
        self.parentTableView.contentInset = UIEdgeInsetsMake(64., 0, 0, 0);
        self.backgroundView.frame = CGRectMake(0, 0, kScreenWidth, kHeaderLoadMorePullingDistance + kTableViewHeaderViewHeight);
    } completion:^(BOOL finished) {
        if (finished) {
            self.currentStateType = MCRefreshToolStateTypeNormal;
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
