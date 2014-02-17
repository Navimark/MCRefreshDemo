

#define kFooterLoadMorePullingDistance              74.0
#define kHeaderLoadMorePullingDistance              100.

#define kScreenWidth                                (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)

typedef NS_ENUM(NSInteger, MCRefreshToolViewType) {
    MCRefreshToolViewTypeFooter,
    MCRefreshToolViewTypeHeader,
};

typedef NS_ENUM(NSInteger, MCRefreshToolStateType) {
    MCRefreshToolStateTypeNormal,
    MCRefreshToolStateTypePulling,
    MCRefreshToolStateTypeLoading,
};



