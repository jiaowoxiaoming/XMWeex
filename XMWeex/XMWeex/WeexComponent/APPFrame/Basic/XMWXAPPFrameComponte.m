//
//  @header XMWXAPPFrameComponte.m
//  @abstract <##>
//  @version <##> 2017/5/17
//  XMWeex
//
//  Created by apple on 2017/5/17.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import "XMWXAPPFrameComponte.h"
#import "XMWXViewController.h"
#import "XMWXNavigationItem.h"
#import "XMWXTabbarItem.h"
#import <SDWebImage/SDWebImageManager.h>
#import "XMWXHeader.h"

@implementation WXSDKInstance (FetchView)
-(void)setRefDict:(NSMutableDictionary<NSString *,NSString *> *)refDict
{
    objc_setAssociatedObject(self, &"refDict", refDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSMutableDictionary<NSString *,NSString *> *)refDict
{
    return objc_getAssociatedObject(self, &"refDict");
}

-(UIView *)fetchViewWithRefKey:(NSString *)refKey
{
    //取出 components ref表
    NSDictionary * dict = self.refDict;
    //    NSLog(@"ssfajfafjaasnlandskla%@",dict);
    //通过ref就可以取出 component.view 注意这个refKey一定要对应到正确的WXSDKInstance对象
    return [self componentForRef:[dict objectForKey:refKey]].view;
}

@end

@interface WXComponent (load)

@end
@implementation WXComponent (load)

+(void)load
{
    //交换实现方式 目的是为了能捕捉到ref参数，并能将我们attributes中的refKey形成键值
    swizzling_exchangeMethod([self class], @selector(initWithRef:type:styles:attributes:events:weexInstance:), @selector(xm_initWithRef:type:styles:attributes:events:weexInstance:));
}

-(instancetype)xm_initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    
    if ([attributes objectForKey:@"refKey"]) {
        if (!weexInstance.refDict) {
            weexInstance.refDict = [NSMutableDictionary dictionary];
        }
        [weexInstance.refDict setObject:ref forKey:[attributes objectForKey:@"refKey"]];
    }
    return [self xm_initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
}
@end



@interface XMWXAPPFrameComponte ()<CAAnimationDelegate>

@end

@implementation XMWXAPPFrameComponte

#pragma mark - public method
-(instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        [self firstInitAPPFrameWithAttributes:attributes];
        
    }
    return self;
}
#pragma mark - private method

/**
 初始化APP框架

 @param attributes 返回的RenderInfo
 */
-(void)firstInitAPPFrameWithAttributes:(NSDictionary *)attributes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //设置APP
        UIApplication * application = [UIApplication sharedApplication];
        UITabBarController * tabarViewController = nil;
        if ([application.keyWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
            tabarViewController = application.keyWindow.rootViewController;
        }else
        {
            tabarViewController = [[UITabBarController alloc] init];
            self.weexInstance.viewController = tabarViewController;
            UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [((UIResponder *)application.delegate) setValue:window forKey:@"window"];

            window.rootViewController = tabarViewController;

            window.backgroundColor = [UIColor whiteColor];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDEBUGUI)];
            tap.numberOfTapsRequired = 2;
            tap.numberOfTouchesRequired = 3;
            [tabarViewController.view addGestureRecognizer:tap];
            [window makeKeyAndVisible];
        }

        //    tabarViewController.view.alpha = 0;

        
        [self handleTabbarViewControllers:attributes tabarController:tabarViewController];
    });

    
}
-(void)showDEBUGUI
{
#ifdef DEBUG
    Class overlayClass = NSClassFromString(@"UIDebuggingInformationOverlay");
    [overlayClass performSelector:NSSelectorFromString(@"prepareDebuggingOverlay")];
    id overlayObject = [overlayClass performSelector:NSSelectorFromString(@"overlay")];
    [overlayObject performSelector:NSSelectorFromString(@"toggleVisibility")];
#endif
}


/**
 创建tabbar.items

 @param attributes component 下发数据
 @param tabarController [UIApplication sharedApplication].keyWindow.rootViewController
 @return 创建的UITabBarItem集合
 */
-(NSMutableArray <UITabBarItem *> *)handleTabbarItems:(NSDictionary *)attributes tabarController:(UITabBarController __kindof * )tabarController
{
    NSString * tabItemsDictJsonString = [WXConvert NSString:attributes[XMWXAPPFrameComponteTabbarItemsKey]];
    
    NSArray * tabItemsInfoArray = [NSJSONSerialization JSONObjectWithData:[tabItemsDictJsonString dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingAllowFragments) error:nil];
    if (tabItemsInfoArray.count == 0) {
        return nil;
    }
    NSMutableArray * tabarItems = [NSMutableArray array];
    
    [tabItemsInfoArray enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XMWXTabbarItem * xmItem = [XMWXTabbarItem itemWithDict:obj];
        UITabBarItem * item = [[UITabBarItem alloc] init];
        
        item.title = xmItem.title;
        
        if (xmItem.tintColor.length) {
            [tabarController.tabBar setTintColor:colorWithHexString(xmItem.tintColor, 1.f)];
        }
        
        if (xmItem.normalTitleColor.length) {
            [item setTitleTextAttributes:@{NSForegroundColorAttributeName:colorWithHexString(xmItem.normalTitleColor, 1.f)} forState:(UIControlStateNormal)];
        }
        if (xmItem.selectedTitleColor.length) {
            [item setTitleTextAttributes:@{NSForegroundColorAttributeName:colorWithHexString(xmItem.selectedTitleColor, 1.f)} forState:(UIControlStateSelected)];
        }
        
        
        if ([xmItem.image hasPrefix:@"http"]) {
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:xmItem.image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                [tabarController.tabBar setItems:tabarItems];
            }];
        }else
        {
            item.image = xmwx_imageForSetting(xmItem.image);
        }
        
        if ([xmItem.selectedImage hasPrefix:@"http"]) {
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:xmItem.selectedImage] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

                [tabarController.tabBar setItems:tabarItems];
            }];
            
        }else
        {
            item.selectedImage = xmwx_imageForSetting(xmItem.selectedImage);
        }
        
        [tabarItems addObject:item];
    }];
    return tabarItems;
}

/**
 渲染TabbarViewController

 @param attributes component 下发数据
 @param tabarController [UIApplication sharedApplication].keyWindow.rootViewController
 */
-(void)handleTabbarViewControllers:(NSDictionary *)attributes tabarController:(UITabBarController __kindof * )tabarController
{
    NSMutableArray <UITabBarItem *> * tabbarItems = [self handleTabbarItems:attributes tabarController:tabarController];
    if (!tabbarItems) {
        return;
    }
    NSArray * viewControllerItems = [NSJSONSerialization JSONObjectWithData:[[WXConvert NSString:[attributes objectForKey:XMWXAPPFrameComponteViewControllerItemsKey]] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray * viewControllers = [NSMutableArray array];

    [viewControllerItems enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        XMWXNavigationItem * navigationItem = [XMWXNavigationItem infoWithDict:obj];
        
        XMWXViewController * viewController = [[XMWXViewController alloc] init];
        
        viewController.renderInfo = navigationItem;
        if (navigationItem.rootViewURL.length > 0) {
            //
            if ([navigationItem.rootViewURL hasPrefix:@"http"]) {
                viewController.renderURL = [NSURL URLWithString:navigationItem.rootViewURL];
            }else
            {
                NSString * path = [[NSBundle mainBundle] pathForResource:navigationItem.rootViewURL ofType:@""];
                if (path) {
                    viewController.renderURL = [NSURL fileURLWithPath:path];
                }
            }
        }
        
        XMWXViewController * __weak weakViewController = viewController;
        viewController.instance.onCreate = ^(UIView * view)
        {
            XMWXViewController * __strong vc = weakViewController;
            [vc.view addSubview:view];
        };
        viewController.instance.frame = viewController.view.bounds;
        viewController.instance.onLayoutChange = ^(UIView *view)
        {
            XMWXViewController * __strong vc = weakViewController;
            vc.instance.frame = vc.view.bounds;
        };
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.tabBarItem = [tabbarItems objectAtIndex:idx];
        [viewControllers addObject:nav];
    }];
    
    [tabarController setViewControllers:viewControllers animated:YES];
}

/**
 数据更改的时候调用

 @param attributes component属性数据
 */
-(void)updateAttributes:(NSDictionary *)attributes
{
    [self firstInitAPPFrameWithAttributes:attributes];
}
#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle

@end
