//
//  @header XMWXHomePageViewController.m
//  @abstract <##>
//  @version <##> 2017/6/8
//  XMWeex
//
//  Created by apple on 2017/6/8.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import "XMWXHomePageViewController.h"
#import "XMWXScanViewController.h"
#import "XMWXViewController.h"
@interface XMWXHomePageViewController ()
@property (nonatomic,strong) IBOutlet UIButton * appFrameTestButton;
@property (nonatomic,strong) IBOutlet UIButton * signelPageTestButton;
@end

@implementation XMWXHomePageViewController

#pragma mark - public method

#pragma mark - private method

#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signel:(UIButton *)sender {

    
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
    XMWXScanViewController * scanVC = [[XMWXScanViewController alloc] init];
    [scanVC setValue:@0 forKey:@"debugType"];
    [self showViewController:scanVC sender:sender];
    
#endif

}
- (IBAction)appFrame:(UIButton *)sender {
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * url = @"";
    WXSDKInstance * instance = [(UIResponder *)[UIApplication sharedApplication].delegate valueForKey:@"instance"];
    [instance destroyInstance];
    [(UIResponder *)[UIApplication sharedApplication].delegate setValue:nil forKey:@"instance"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [(UIResponder *)[UIApplication sharedApplication].delegate performSelector:@selector(instance:) withObject:url];
#elif TARGET_OS_IPHONE//真机
    
    XMWXScanViewController * scanVC = [[XMWXScanViewController alloc] init];
    [scanVC setValue:@1 forKey:@"debugType"];
    [self showViewController:scanVC sender:sender];
    
#endif
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender.titleLabel.text isEqualToString:@"单页面调试"]) {
        [segue.destinationViewController setValue:@0 forKey:@"debugType"];
    }else if ([sender.titleLabel.text isEqualToString:@"AppFrame调试"])
    {
        [segue.destinationViewController setValue:@1 forKey:@"debugType"];
    }
    
}


@end
