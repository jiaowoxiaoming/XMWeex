//
//  @header XMWXBarButtonItem.h
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMWXProtocol.h"

@interface XMWXBarButtonItem : NSObject<XMWXBarButtonItemProtocol>
+(instancetype)itemWithDict:(NSDictionary *)dict;
-(instancetype)initWithDict:(NSDictionary *)dict;
+(NSMutableArray *)itemsWithArray:(NSArray *)items;
@end
