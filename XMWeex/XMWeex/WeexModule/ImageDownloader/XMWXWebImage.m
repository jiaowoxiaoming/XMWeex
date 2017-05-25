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
@implementation XMWXWebImage
-(id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)options completed:(void (^)(UIImage *, NSError *, BOOL))completedBlock
{
    //依据条件做事情
    if ([url hasPrefix:@"http"]) {
        //如果这样写<image :src="xxx"></image>没有带有http的话，那么url参数会被加入http://host/xxx这样的形式，so 我们在这里向加载本地图片需要加入一定的判断条件
        if ([url hasPrefix:@"http://mkhioslocal/"]) {
            url = [url stringByReplacingOccurrencesOfString:@"http://mkhioslocal/" withString:@""];
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
    return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, finished);
        }

    }];
}
@end
