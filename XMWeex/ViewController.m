//
//  ViewController.m
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import "ViewController.h"
#import "XMWXViewController.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.fd_prefersNavigationBarHidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    XMWXViewController * vc = segue.destinationViewController;
    
    XMWXViewController * __weak weakVC = vc;
    vc.instance.onCreate = ^(UIView * view)
    {
        XMWXViewController * __strong vc = weakVC;
        [vc.view addSubview:view];
    };
    vc.instance.frame = vc.view.bounds;
    vc.instance.onLayoutChange = ^(UIView *view)
    {
        XMWXViewController * __strong vc = weakVC;
        vc.instance.frame = vc.view.bounds;
    };
}


@end
