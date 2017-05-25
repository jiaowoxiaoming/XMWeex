//
//  XMWXModule.m
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import "XMWXModule.h"
#import "XMWXViewController.h"
#import "XMWXBarButtonItem.h"
#import "XMWXNavigationItem.h"

@implementation XMWXModule
@synthesize weexInstance = _weexInstance;

WX_EXPORT_METHOD(@selector(openURL:options:completionHandler:))
-(void)openURL:(NSString *)url options:(NSDictionary<NSString *,id> *)options completionHandler:(WXCallback)completion
{
    NSString *newURL = url;
    if ([url hasPrefix:@"//"]) {
        newURL = [NSString stringWithFormat:@"http:%@", url];
    } else if (![url hasPrefix:@"http"]) {
        newURL = [NSURL URLWithString:url relativeToURL:self.weexInstance.scriptURL].absoluteString;
    }
    XMWXViewController * controller = [[XMWXViewController alloc] init];
    controller.renderURL = [NSURL URLWithString:newURL];
    if ([options objectForKey:@"navigtionBarInfo"]) {
        controller.renderInfo = [XMWXNavigationItem infoWithDict:[options objectForKey:@"navigtionBarInfo"]];
    }

    [self.weexInstance.viewController showViewController:controller sender:nil];
    completion(@{@"result":@"success"});
}
WX_EXPORT_METHOD(@selector(creatNavigationBarUI:))
-(void)creatNavigationBarUI:(NSDictionary *)renderInfo
{
    XMWXNavigationItem * info = [XMWXNavigationItem infoWithDict:renderInfo];
    
    if ([self.weexInstance.viewController isKindOfClass:[XMWXViewController class]]) {
        ((XMWXViewController *)self.weexInstance.viewController).renderInfo = info;
    }
    
}

WX_EXPORT_METHOD(@selector(resetAPPFrame));
-(void)resetAPPFrame
{
    WXSDKInstance * instance = [(UIResponder *)[UIApplication sharedApplication].delegate valueForKey:@"instance"];
    NSURL * url = instance.scriptURL;
    [instance destroyInstance];
    [(UIResponder *)[UIApplication sharedApplication].delegate setValue:nil forKey:@"instance"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [(UIResponder *)[UIApplication sharedApplication].delegate performSelector:@selector(instance:) withObject:[url absoluteString]];

}
@end
