//
//  @header XMWXScanViewController.h
//  @abstract <##>
//  @version <##> 2017/5/20
//  XMWeex
//
//  Created by apple on 2017/5/20.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XMWXDEBUGTypeIsSingelPage,
    XMWXDEBUGTypeIsAppFrame,
    
} XMWXDEBUGType;

@interface XMWXScanViewController : UIViewController
@property (nonatomic,assign) XMWXDEBUGType debugType;
@end
#import <Foundation/Foundation.h>



/**
 *  播放音效类、判断应用是否有权限使用相机
 */
@interface BaseTapSound : NSObject


/**
 *  振动效果,默认为YES(有振动效果)
 */
@property(nonatomic) BOOL vibrate;


/**
 *  音效播放对象
 */
+(instancetype)shareTapSound;

/**
 *  添加音效文件
 */
- (void)playSoundFileName:(NSString *)soundName;

/**
 *  播放音效文件
 */
- (void)playSound;

/**
 * 播放系统音效
 */
- (void)playSystemSound;

/**
 * 是否有权限使用系统相机
 */
+ (BOOL)ifCanUseSystemCamera;

/**
 * 是否有权限使用系统相册
 */
+ (BOOL)ifCanUseSystemPhoto;

@end
