//
//  XMWXViewController.m
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import "XMWXViewController.h"
#import <objc/runtime.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "XMWXHeader.h"

@implementation NSObject (visibleViewController)

//获取当前屏幕显示的viewcontroller
+(UIViewController *)visibleViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    result = [self findTopViewController:result];
    
    return result;
}
+(UIViewController *)findTopViewController:(id)viewController
{
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self findTopViewController:((UITabBarController *)viewController).selectedViewController];
    }else if ([viewController isKindOfClass:[UINavigationController class]])
    {
        return [self findTopViewController:[viewController visibleViewController]];
    }
    else if ([viewController isKindOfClass:[UIViewController class]])
    {
        return viewController;
    }
    else
    {
        
        return nil;
    }
}

@end
@interface UIView (LayoutSubView)
@property (nonatomic,assign) BOOL shouldSetScrollViewContentInset;

/**
 设置偏移量
 */
@property (nonatomic,assign) CGFloat scrollViewTopDel;
@end
@implementation UIView (LayoutSubView)
-(void)setShouldSetScrollViewContentInset:(BOOL)shouldSetScrollViewContentInset
{
    objc_setAssociatedObject(self, &"shouldSetScrollViewContentInset", @(shouldSetScrollViewContentInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)shouldSetScrollViewContentInset
{
    return [objc_getAssociatedObject(self, &"shouldSetScrollViewContentInset") boolValue];
}
-(CGFloat)scrollViewTopDel
{
    return [objc_getAssociatedObject(self, &"scrollViewTopDel") floatValue];
}
-(void)setScrollViewTopDel:(CGFloat)scrollViewTopDel
{
    objc_setAssociatedObject(self, &"scrollViewTopDel", @(scrollViewTopDel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)layoutSubviews
{
    if (self.shouldSetScrollViewContentInset) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIScrollView * scrollView = nil;
            
            if ([obj isKindOfClass:[UIScrollView class]]) {
                scrollView = obj;
                [scrollView setContentInset:UIEdgeInsetsMake(CGRectGetMaxY([NSObject visibleViewController].navigationController.navigationBar.frame) + self.scrollViewTopDel ? : 0, 0, 0, 0)];
                
                [scrollView setContentOffset:CGPointMake(0, -(CGRectGetMaxY([NSObject visibleViewController].navigationController.navigationBar.frame) + self.scrollViewTopDel ? : 0))];
            }
        }];
    }
    
}

@end




@interface XMWXViewController ()

@property (nonatomic, strong) UIView *weexView;

@property (nonatomic, assign) CGFloat weexHeight;

@property (nonatomic, strong) UIButton * refreshButton;
@property (nonatomic, strong) UIButton * refreshAPPFrameButton;
@end

@implementation XMWXViewController
@synthesize instance = _instance;
#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUserInterface];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_instance fireGlobalEvent:WX_APPLICATION_DID_BECOME_ACTIVE params:nil];
    [self updateInstanceState:WeexInstanceAppear];
    
    [self handleNavigationBar];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self handleNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_instance fireGlobalEvent:WX_APPLICATION_WILL_RESIGN_ACTIVE params:nil];
}
-(void)dealloc
{
    [_instance destroyInstance];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)viewWillLayoutSubviews
//{
//    
//}
//TODO get height
- (void)viewDidLayoutSubviews
{
    _weexHeight = self.view.frame.size.height;
    self.instance.frame = self.view.bounds;
    [self.view bringSubviewToFront:self.refreshButton];
    [self.view bringSubviewToFront:self.refreshAPPFrameButton];
}
#pragma mark - creatUserInterface
-(void)creatUserInterface
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setClipsToBounds:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _weexHeight = self.view.frame.size.height;
    [self refreshButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefreshInstance:) name:@"RefreshInstance" object:nil];
}
-(void)clearNavigationBar
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self whiteBackItem];
    UIViewController * visibleViewController = [[self class] visibleViewController];
    UINavigationController * nav = visibleViewController.navigationController;
    nav.navigationBar.hidden = NO;
    [nav.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:[[UIImage alloc] init]];
    UIFont * font = self.renderInfo.titleFont.length > 0 ? fontByString(self.renderInfo.titleFont) : [UIFont systemFontOfSize:16];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular],NSForegroundColorAttributeName:colorWithHexString(self.renderInfo.clearTitleColor, 1.f),NSFontAttributeName:font}];
}
-(void)whiteBackItem
{
    UIViewController * visibleViewController = [[self class] visibleViewController];
    if (visibleViewController.navigationItem.leftBarButtonItems.count > 0) {
        [((UIButton *)[visibleViewController.navigationItem.leftBarButtonItems objectAtIndex:0].customView) setImage:xmwx_imageForSetting(@"back_white") forState:(UIControlStateNormal)];
        [[visibleViewController.navigationItem.leftBarButtonItems objectAtIndex:0].customView sizeToFit];
    }
    
}
-(void)blackBackItem
{
    UIViewController * visibleViewController = [[self class] visibleViewController];
    //    if ([visibleViewController.navigationController valueForKey:@"backImage"]) {
    //        return;
    //    }
    if (visibleViewController.navigationItem.leftBarButtonItems.count > 0) {
        [((UIButton *)[visibleViewController.navigationItem.leftBarButtonItems objectAtIndex:0].customView) setImage:xmwx_imageForSetting(@"back") forState:(UIControlStateNormal)];
        [[visibleViewController.navigationItem.leftBarButtonItems objectAtIndex:0].customView sizeToFit];
    }
    
}
-(void)blurNavigationBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.hidden = NO;
    
    [self blackBackItem];
    UIViewController * visibleViewController = [[self class] visibleViewController];
    UINavigationController * nav = visibleViewController.navigationController;
    [nav.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:nil];
    UIFont * font = self.renderInfo.titleFont.length > 0 ? fontByString(self.renderInfo.titleFont) : [UIFont systemFontOfSize:16];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular],NSForegroundColorAttributeName:colorWithHexString(self.renderInfo.blurTitleColor, 1.f),NSFontAttributeName:font}];
}


- (void)updateInstanceState:(WXState)state
{
    if (_instance && _instance.state != state) {
        _instance.state = state;
        
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}
#pragma mark - refresh
- (void)refreshWeex
{
    [self setRenderURL:self.renderURL];
}
-(void)refreshAPPFrame:(UIButton *)btn
{
    WXSDKInstance * instance = [(UIResponder *)[UIApplication sharedApplication].delegate valueForKey:@"instance"];
    NSURL * url = instance.scriptURL;
    [instance destroyInstance];
    [(UIResponder *)[UIApplication sharedApplication].delegate setValue:nil forKey:@"instance"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [(UIResponder *)[UIApplication sharedApplication].delegate performSelector:@selector(instance:) withObject:[url absoluteString]];
}
#pragma mark - notification
- (void)notificationRefreshInstance:(NSNotification *)notification {
    [self refreshWeex];
}

//-(void)render
//{
//
//}
#pragma mark - getter
-(UIButton *)refreshButton
{
    if (!_refreshButton) {
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 30, 64, 0, 0)];
        [_refreshButton setTitle:@"🔄" forState:(UIControlStateNormal)];
        [_refreshButton sizeToFit];
        [_refreshButton addTarget:self action:@selector(refreshWeex) forControlEvents:(UIControlEventTouchUpInside)];
#if DEBUG
        [self.view addSubview:_refreshButton];
#endif
    }
    return _refreshButton;
}
-(UIButton *)refreshAPPFrameButton
{
    if (!_refreshAPPFrameButton) {
        _refreshAPPFrameButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 70, 64, 0, 0)];
        [_refreshAPPFrameButton setTitle:@"🔄" forState:(UIControlStateNormal)];
        [_refreshAPPFrameButton sizeToFit];
        [_refreshAPPFrameButton addTarget:self action:@selector(refreshAPPFrame:) forControlEvents:(UIControlEventTouchUpInside)];
#if DEBUG
        [self.view addSubview:_refreshAPPFrameButton];
#endif
    }
    return _refreshAPPFrameButton;
}
-(WXSDKInstance *)instance
{
    if (!_instance) {
        WXSDKInstance * instance = [[WXSDKInstance alloc] init];
        instance.viewController = self;
        _instance = instance;
        CGFloat width = self.view.frame.size.width;
        _instance.frame = CGRectMake(self.view.frame.size.width - width, 0, width, _weexHeight);
    }
    return _instance;
}
- (BOOL)fd_prefersNavigationBarHidden {
    return self.renderInfo.hiddenNavgitionBar;
}
#pragma mark - setter
-(void)setRenderURL:(NSURL *)renderURL
{
    _renderURL = renderURL;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    renderURL = [self URLWithString:renderURL.absoluteString];
    [_instance destroyInstance];
    _instance = nil;
    [self instance];
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        typeof (self) __strong strongSelf = weakSelf;
        [strongSelf.weexView removeFromSuperview];
        strongSelf.weexView = view;
        [strongSelf.view addSubview:strongSelf.weexView];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, strongSelf.weexView);
        strongSelf.weexView.shouldSetScrollViewContentInset = ![weakSelf fd_prefersNavigationBarHidden] && !weakSelf.renderInfo.clearNavigationBar;
        strongSelf.weexView.scrollViewTopDel = weakSelf.renderInfo.scrollViewTopDel.floatValue;
    };
    _instance.onFailed = ^(NSError *error) {
        
    };
//    _instance.onLayoutChange = ^(UIView *view)
//    {
//        
//    };
    _instance.renderFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Render Finish...");
        [weakSelf updateInstanceState:WeexInstanceAppear];
        
    };
    
    _instance.updateFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Update Finish...");
    };
    if (!self.renderURL) {
        WXLogError(@"error: render url is nil");
        return;
    }
    [self.instance renderWithURL:renderURL];
    
}

-(void)setRenderInfo:(id<XMWXNavigationBarProtocol>)renderInfo
{
    _renderInfo = renderInfo;
    typeof(self) __weak weakSelf = self;
    if ([renderInfo.title containsString:@"http"]) {
        WXSDKInstance * titleInstance = [[WXSDKInstance alloc] init];
        [titleInstance renderWithURL:[self URLWithString:[NSURL URLWithString:renderInfo.title].absoluteString]];
        titleInstance.renderFinish = ^(UIView * view){
            weakSelf.navigationItem.titleView = view;
        };
        titleInstance.frame = CGRectMake(0, 0, 100, 30);
    }else
    {
        self.navigationItem.title = renderInfo.title;
    }
    
    [self handleNavigationBar];
    
    if (renderInfo.navigationBarBackgroundColor.length > 0 && !renderInfo.hiddenNavgitionBar) {
        self.navigationController.navigationBar.backgroundColor = colorWithHexString(renderInfo.navigationBarBackgroundColor, 1.f);
    }
    
    [renderInfo.leftItemsInfo enumerateObjectsUsingBlock:^(id <XMWXBarButtonItemProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf creatABarButtonItemWithWXItem:obj isRight:NO];
    }];
    
    [renderInfo.rightItemsInfo enumerateObjectsUsingBlock:^(id <XMWXBarButtonItemProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf creatABarButtonItemWithWXItem:obj isRight:YES];
    }];
    
}


#pragma mark - private Method

-(NSURL *)URLWithString:(NSString *)URLString
{
    NSURL * renderURL = [NSURL URLWithString:URLString];
    if ([URLString containsString:@"http://localhost/"]) {
        NSString * newURL = [URLString mutableCopy];
        newURL = [newURL stringByReplacingOccurrencesOfString:@"http://localhost/" withString:host()];
        renderURL = [NSURL URLWithString:newURL];
    }
    return renderURL;
}
-(void)handleNavigationBar
{
    if (self.renderInfo) {
        [self handleNavigationBarIsClear];
        [self handleNavigationBarIsHidden];
        [self handleNavigationBarBackgroundColor];
        [self handleNavigationBarBackgroundImage];
        
        
    }
    
}
-(void)handleNavigationBarIsHidden
{
    //    [self.navigationController setNavigationBarHidden:self.renderInfo.hiddenNavgitionBar animated:NO];
    
}
-(void)handleNavigationBarIsClear
{
    if (self.renderInfo.clearNavigationBar) {
        [self clearNavigationBar];
    }else
    {
        [self blurNavigationBar];
    }
}
-(void)handleNavigationBarBackgroundColor
{
    if (_renderInfo.navigationBarBackgroundColor.length > 0 && !_renderInfo.hiddenNavgitionBar) {
        self.navigationController.navigationBar.backgroundColor = colorWithHexString(_renderInfo.navigationBarBackgroundColor, 1.f);
    }
}
-(void)handleNavigationBarBackgroundImage
{
    typeof(self) __weak weakSelf = self;
    if ([_renderInfo.navgationBarBackgroundImage hasPrefix:@"http"]) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_renderInfo.navgationBarBackgroundImage] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            [weakSelf.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            
        }];
    }else
    {
        
    }
    
}
-(void)creatABarButtonItemWithWXItem:(id <XMWXBarButtonItemProtocol>)WXItem isRight:(BOOL)isRight
{
    typeof(self) __weak weakSelf = self;
    if (WXItem.itemURL.length > 0) {
        WXSDKInstance * instance = [[WXSDKInstance alloc] init];
        instance.viewController = weakSelf;
        if ([WXItem.itemURL hasPrefix:@"http"]) {
            [instance renderWithURL:[self URLWithString:[NSURL URLWithString:WXItem.itemURL].absoluteString]];
        }else
        {
            [instance renderWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:WXItem.itemURL ofType:@""]]];
        }
        
        
        instance.renderFinish = ^(UIView * view){
            
            NSMutableArray * tmpItems = nil;
            NSArray * items = isRight ? weakSelf.navigationItem.rightBarButtonItems : weakSelf.navigationItem.leftBarButtonItems;
            
            if (items.count > 0) {
                tmpItems = items.mutableCopy;
            }else
            {
                tmpItems = [NSMutableArray array];
            }
            UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:view];
            
            [item setTarget:weakSelf];
            [item setAction:@selector(actionForBarButtonItem:)];
            objc_setAssociatedObject(item, &wxAtionKey, WXItem.wxAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [tmpItems addObject:item];
            isRight ? [weakSelf.navigationItem setRightBarButtonItems:tmpItems animated:YES] : [weakSelf.navigationItem setLeftBarButtonItems:tmpItems animated:YES];
        };
        instance.frame = CGRectFromString(WXItem.frame);
    }
}

-(void)actionForBarButtonItem:(UIBarButtonItem *)item
{
    
    NSString * wxAtionMehodName = objc_getAssociatedObject(item, &wxAtionKey);
    
    [self.instance fireGlobalEvent:wxAtionMehodName params:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
