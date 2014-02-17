//
//  MCHomeViewController.m
//  MCRefreshDemo
//
//  Created by 陈政 on 14-2-14.
//  Copyright (c) 2014年 sf Inc. All rights reserved.
//

#import "MCHomeViewController.h"
#import "MCRefreshToolView.h"

#define kMainTableViewCellReuseIdentifier       @"kMainTableViewCellReuseIdentifier"

@interface MCHomeViewController () <UITableViewDataSource , UITableViewDelegate ,MCRefreshToolViewDelegate>

@property (nonatomic , strong) UITableView *mainTableView;
@property (nonatomic , strong) NSMutableArray *dataSource;
@property (nonatomic , strong) MCRefreshToolView *footerRefreshView;

@end

@implementation MCHomeViewController

- (MCRefreshToolView *)footerRefreshView
{
    if (!_footerRefreshView) {
        _footerRefreshView = [[MCRefreshToolView alloc] initWithTableView:self.mainTableView viewType:MCRefreshToolViewTypeHeader];
        _footerRefreshView.delegate = self;
    }
    return _footerRefreshView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UITableView *)mainTableView
{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
    }
    return _mainTableView;
}

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.mainTableView];
    [self footerRefreshView];
//    [self.mainTableView addSubview:self.footerRefreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"O(∩_∩)O哈哈~";
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMainTableViewCellReuseIdentifier];
    [self addBatchDataSourceAfterReady:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - MCRefreshToolViewDelegate

- (void)toolViewDidStartRefreshData
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addBatchDataSourceAfterReady:YES];
        [self.footerRefreshView didFinishedRefreshData];
    });
}

#pragma mark -
#pragma mark - 私有函数

- (void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView reloadData];
    });
}

- (void)addBatchDataSourceAfterReady:(BOOL)shouldReload
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static NSInteger counter = 0;
        for (int i = 0; i < 3; ++ i,++counter) {
            NSString *text = [NSString stringWithFormat:@"我是第%d行数据",counter];
            [self.dataSource addObject:text];
        }
        [self reloadData];
    });
}

#pragma mark -
#pragma mark - UITableViewDataSource  &&  UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont systemFontOfSize:14.];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMainTableViewCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

@end
