#Weex-iOS
[iOS调试Demo](https://github.com/jiaowoxiaoming/XMWeex)
[WeexDemo](https://github.com/jiaowoxiaoming/app_weex)
本篇详细说明一下如何调试，打包Weex。
[Weex 从无到有开发一款上线应用 1](http://www.jianshu.com/p/5fe02ca05e86)中说了一些调试方法。Weex官方的调试在这里不多说了。这里说一下如何使用[iOS调试Demo](https://github.com/jiaowoxiaoming/XMWeex)。

######从iOS调试Demo说起
从git拉下来文件后
```
pod install
```
这里我在```pod file```里有两种引入```WeexSDK```的形式
```
#   毕竟Weex开源 拉一份代码到本地就能保证实时用的最新SDK，还能方便看源码
#   想使用SDK的用pod 'WeexSDK' 想用源码的 pod 'WeexSDK', :path => '/Users/apple/Desktop/incubator-weex'
    pod 'WeexSDK'
#   这个地方是拉下来的Weex源代码路径
#    pod 'WeexSDK', :path => '/Users/apple/Desktop/incubator-weex'
```
这样就能编译通过Demo。
![Demo图](http://upload-images.jianshu.io/upload_images/762651-f3a0ede867f34b82.jpg)
######单页面调试&&AppFrame调试
顾名思义 进行单个页面的调试 类似于Weex的DevTool。
可以通过加载```AppFrame.js```来调试整个app
真机需要扫描二维码来加载，模拟器需要设置```renderURL```
```
- (IBAction)单页面调试:(UIButton *)sender {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * url = @"";
    XMWXViewController * viewController = [[XMWXViewController alloc] init];
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
    
    if ([url hasPrefix:@"http"]) {
        viewController.renderURL = [NSURL URLWithString:url];
    }else
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:url ofType:@""];
        if (path) {
            viewController.renderURL = [NSURL fileURLWithPath:path];
        }
    }
    [self showViewController:viewController sender:nil];

#elif TARGET_OS_IPHONE//真机
    
    [self showViewController:[[XMWXScanViewController alloc] init] sender:sender];
    
#endif

}
- (IBAction)AppFrame调试:(UIButton *)sender {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * url = @"";
    WXSDKInstance * instance = [(UIResponder *)[UIApplication sharedApplication].delegate valueForKey:@"instance"];
    [instance destroyInstance];
    [(UIResponder *)[UIApplication sharedApplication].delegate setValue:nil forKey:@"instance"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [(UIResponder *)[UIApplication sharedApplication].delegate performSelector:@selector(instance:) withObject:url];
#elif TARGET_OS_IPHONE//真机
    
    [self showViewController:[[XMWXScanViewController alloc] init] sender:sender];
    
#endif
}
```
######WeexDemo调试
首先还是拉下来代码，将目录中的```build.zip```解压到目录中。
![weex_app目录.png](http://upload-images.jianshu.io/upload_images/762651-e190776c5c0d2fdb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
webstorm打开```app_weex```

![webstrom项目结构.png](http://upload-images.jianshu.io/upload_images/762651-e50b7f3ba3f92944.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
打开WebStorm的Terminal（注意是打开WebStorm的Terminal）。
快捷键：fn + option + f12
或者：view->ToolWindows->Terminal
1.输入
```
npm install
```
并执行
![npm install.png](http://upload-images.jianshu.io/upload_images/762651-4bacbe7cbc831788.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![npm installing.png](http://upload-images.jianshu.io/upload_images/762651-ee685a7e7677d0f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
2.之后输入
```
weex compile src dist
```
命令并执行
![weex compile src dist.png](http://upload-images.jianshu.io/upload_images/762651-a662c6117f65f60e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
3.之后输入
```
npm run serve
```
![npm run serve.png](http://upload-images.jianshu.io/upload_images/762651-01c5a223192d90a7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这样我们的服务就运行在你的```本机IP + 8084（可以在package.js中设置）```上
这时随便找一个二维码生成网站，生成一下需要调试的JSBundle地址。
如用[草料](http://cli.im/)
将```http://yourip:8084/dist/Components/Frame/AppFrame.js```生成二维码，用[iOS调试Demo](https://github.com/jiaowoxiaoming/XMWeex)扫描该二维码就可以看到应用界面。
扫描结果如图
![单页面调试](http://upload-images.jianshu.io/upload_images/762651-f50a953251d4eba4.jpg)
![AppFrame调试](http://upload-images.jianshu.io/upload_images/762651-cd69da8379cb0256.jpg)
