//
//  MCRefreshToolView.h
//  MCRefreshDemo
//
//  Created by 陈政 on 14-2-14.
//  Copyright (c) 2014年 sf Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCRefreshToolConstant.h"

@class MCRefreshToolView;
@protocol MCRefreshToolViewDelegate <NSObject>

- (void)toolViewDidStartRefreshData;

//- (void)toolViewDidStartLoadMoreData;

@end

@interface MCRefreshToolView : UIView
{
    
}

@property (nonatomic ,assign)id <MCRefreshToolViewDelegate> delegate;

- (id)initWithTableView:(UITableView *)tableView viewType:(MCRefreshToolViewType)viewType;

- (void)didFinishedRefreshData;

@end
