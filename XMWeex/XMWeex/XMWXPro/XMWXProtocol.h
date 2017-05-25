//
//  XMWXProtocol.h
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const itemURLKey = @"itemURL";

@protocol XMWXBarButtonItemProtocol <NSObject>

@property (nonatomic,copy) NSString * wxAction;

@property (nonatomic,copy) NSString * itemURL;

//@property (nonatomic,copy) NSString * title;
//
//@property (nonatomic,copy) NSString * image;
//
//@property (nonatomic,copy) NSString * selectedImage;
//
//@property (nonatomic,copy) NSString * tintColor;

@property (nonatomic,copy) NSString * frame;
@end

@protocol XMWXNavigationBarProtocol <NSObject>

@property (nonatomic,copy) NSString * title;

@property (nonatomic,copy) NSString * clearTitleColor;

@property (nonatomic,copy) NSString * blurTitleColor;

/**
 leftItem的渲染信息
 */
@property (nonatomic,strong) NSMutableArray<id <XMWXBarButtonItemProtocol>> * leftItemsInfo;


/**
 自定义导航栏是否透明效果
 */
@property (nonatomic,assign,getter=isClearedNavigationBar) BOOL clearNavigationBar;

/**
 是否隐藏导航栏
 */
@property (nonatomic,assign,getter=isHiddenNavgitionBar) BOOL hiddenNavgitionBar;

/**
 rightItem 的渲染信息
 */
@property (nonatomic,strong) NSMutableArray<id <XMWXBarButtonItemProtocol>> * rightItemsInfo;

/**
 自定义导航栏的背景颜色
 */
@property (nonatomic,copy) NSString * navigationBarBackgroundColor;

/**
 自定义导航栏的背景图片 只能用于模态视图且不会有Push行为的情况下使用
 */
@property (nonatomic,copy) NSString * navgationBarBackgroundImage;

/**
 自定义导航栏的titleView
 */
@property (nonatomic,copy) NSString * customTitleViewURL;

@property (nonatomic,copy) NSString * rootViewURL;
@end

@protocol XMWXTabbarItemProtocol <NSObject>

@property (nonatomic,copy) NSString * normalTitleColor;

@property (nonatomic,copy) NSString * selectedTitleColor;

@property (nonatomic,copy) NSString * title;

@property (nonatomic,copy) NSString * selectedImage;

@property (nonatomic,copy) NSString * image;

@property (nonatomic,copy) NSString * tintColor;

@end


