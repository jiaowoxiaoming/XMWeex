//
//  XMWXViewController.h
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMWXProtocol.h"
#import <WeexSDK/WeexSDK.h>

static char * const wxAtionKey = "wxAction";

@interface XMWXViewController : UIViewController

/**
    navigationBar渲染信息
 */
@property (nonatomic,strong) id<XMWXNavigationBarProtocol> renderInfo;


@property (nonatomic,weak,readonly) WXSDKInstance * instance;

/**
 需要渲染的URL
 */
@property (nonatomic,strong) NSURL * renderURL;

//-(void)actionForBarButtonItem:(UIBarButtonItem *)item;

@end
