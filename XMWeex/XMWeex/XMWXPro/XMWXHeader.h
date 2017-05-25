//
//  XMWXHeader.h
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#ifndef XMWXHeader_h
#define XMWXHeader_h


#define XMWXColorHex(hexValue) [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0 green:((CGFloat)((hexValue & 0xFF00) >> 8))/255.0 blue:((CGFloat)(hexValue & 0xFF))/255.0 alpha:1.0]


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static void configXMWeex()
{
    [WXSDKEngine initSDKEnvironment];
    [WXSDKEngine registerModule:@"XMWXModule" withClass:NSClassFromString(@"XMWXModule")];
    [WXSDKEngine registerHandler:[NSClassFromString(@"XMWXWebImage") new] withProtocol:@protocol(WXImgLoaderProtocol)];
    //通过配置这个Component参数来配置程序框架HTML标签名
    [WXSDKEngine registerComponent:@"AppFrame" withClass:NSClassFromString(@"XMWXAPPFrameComponte")];
}

static NSString * host()
{
    return objc_getAssociatedObject([UIApplication sharedApplication], &"host");
}

static UIColor * colorWithHexString(NSString * color,CGFloat alpha)
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

static UIImage * xmwx_fetchImage(NSString * imageNameOrPath)
{
    UIImage *image = [UIImage imageNamed:imageNameOrPath];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:imageNameOrPath];
    }
    return image;
}

#define CommonImageDirectoryName    @"image"
static UIImage * xmwx_imageForSetting(NSString * imageName)
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"XMWeex" ofType:@"bundle"];
    
    NSString *subDirectoryOfCommonImage = CommonImageDirectoryName;
    //先拿2倍图
    NSString *doubleImage  = [imageName stringByAppendingString:@"@2x"];
    NSString *tribleImage  = [imageName stringByAppendingString:@"@3x"];
    NSString *sourcePath   = [bundlePath stringByAppendingPathComponent:subDirectoryOfCommonImage];
    NSString *path = nil;
    
    NSArray *array = [NSBundle pathsForResourcesOfType:nil inDirectory:sourcePath];
    NSString *fileExt = [[array.firstObject lastPathComponent] pathExtension];
    if ([UIScreen mainScreen].scale == 3.0) {
        path = [NSBundle pathForResource:tribleImage ofType:fileExt inDirectory:sourcePath];
    }
    path = path ? path : [NSBundle pathForResource:doubleImage ofType:fileExt inDirectory:sourcePath]; //取二倍图
    path = path ? path : [NSBundle pathForResource:imageName ofType:fileExt inDirectory:sourcePath]; //实在没了就去取一倍图
    return [UIImage imageWithContentsOfFile:path];
}

static inline void swizzling_exchangeMethod(Class clazz ,SEL originalSelector, SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    BOOL success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface WXSDKInstance (FetchView)

@property (nonatomic,strong,readonly) NSMutableDictionary <NSString *,NSString *> * refDict;
-(UIView *)fetchViewWithRefKey:(NSString *)refKey;
@end

static UIView * fetchView(NSString * comRefKey,WXSDKInstance * instance)
{
    return [instance fetchViewWithRefKey:comRefKey];
}
#endif /* XMWXHeader_h */
