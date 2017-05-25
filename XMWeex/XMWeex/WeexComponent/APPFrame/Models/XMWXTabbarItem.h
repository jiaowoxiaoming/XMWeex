//
//  @header XMWXTabbarItem.h
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWXProtocol.h"
//@{@"title":@"xxxxx",@"normalTitleColor":@"",@"selectedTitleColor":@"",@"selectedImage":@"",@"image":@"",@"tintColor":@""}
@interface XMWXTabbarItem : NSObject<XMWXTabbarItemProtocol>

+(instancetype)itemWithDict:(NSDictionary *)dict;

-(instancetype)initWithDict:(NSDictionary *)dict;


@end
