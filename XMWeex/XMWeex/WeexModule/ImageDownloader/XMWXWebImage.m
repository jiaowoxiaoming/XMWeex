//
//  XMWXWebImage.m
//  weex
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "XMWXWebImage.h"
#import <SDWebImage/SDWebImageManager.h>
#import "XMWXHeader.h"
@interface UIColorCache : NSObject
@property (nonatomic,strong)    NSCache *colorImageCache;
@end

@implementation UIColorCache
+ (instancetype)sharedCache
{
    static UIColorCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UIColorCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _colorImageCache = [[NSCache alloc] init];
    }
    return self;
}

- (UIImage *)image:(UIColor *)color
{
    return color ? [_colorImageCache objectForKey:[color description]] : nil;
}

- (void)setImage:(UIImage *)image
        forColor:(UIColor *)color
{
    [_colorImageCache setObject:image
                         forKey:[color description]];
}
@end
@implementation XMWXWebImage
-(void)cancel
{
    
}
+ (UIImage *)imageWithColor:(UIColor *)color {
    if (color == nil)
    {
        assert(0);
        
        return nil;
    }
    UIImage *image = [[UIColorCache sharedCache] image:color];
    if (image == nil)
    {
        CGFloat alphaChannel;
        [color getRed:NULL green:NULL blue:NULL alpha:&alphaChannel];
        BOOL opaqueImage = (alphaChannel == 1.0);
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContextWithOptions(rect.size, opaqueImage, [UIScreen mainScreen].scale);
        [color setFill];
        UIRectFill(rect);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UIColorCache sharedCache] setImage:image
                                    forColor:color];
    }
    return image;
}
-(id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)options completed:(void (^)(UIImage *, NSError *, BOOL))completedBlock
{
    //依据条件做事情
    if ([url hasPrefix:@"http"]) {
        //如果这样写<image :src="xxx"></image>没有带有http的话，那么url参数会被加入http://host/xxx这样的形式，so 我们在这里向加载本地图片需要加入一定的判断条件
        if ([url hasPrefix:@"http://ioslocal/"]) {
            url = [url stringByReplacingOccurrencesOfString:@"http://ioslocal/" withString:@""];
            //在.xcassets文件里取
            UIImage * image = [UIImage imageNamed:url];
            
            if (completedBlock) {
                
                if (image) {//取到就传回
                    completedBlock(image, nil, YES);
                }else                {
                    //取不到就从bundle里面取
                    image = xmwx_imageForSetting(url);
                    completedBlock(image, nil, YES);
                }
            }
            return (id<WXImageOperationProtocol>)self;
        }
    }else
    {
        //图片通过base64之后的data传递
        if (url.length > 0) {
            
            NSRange base64Range = [url rangeOfString:@"base64,"];
            if (base64Range.location == NSNotFound) {
                if (completedBlock) {
                    UIImage * image = [[UIImage alloc] init];
                    
                    completedBlock(image, nil, YES);
                }
                return (id<WXImageOperationProtocol>)self;
            }
            url = [url substringWithRange:NSMakeRange(base64Range.location + base64Range.length, url.length - base64Range.location - base64Range.length)];
            NSData * urlDataBase64 = [[NSData alloc] initWithBase64EncodedString:url options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (completedBlock) {
                UIImage * image = [UIImage imageWithData:urlDataBase64];
                
                completedBlock(image, nil, YES);
            }
            return (id<WXImageOperationProtocol>)self;
        }
        
    }
    [[SDWebImageDownloader sharedDownloader] setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, finished);
        }
    }];

    return (id<WXImageOperationProtocol>)self;
}
@end
