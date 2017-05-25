//
//  @header XMWXBarButtonItem.m
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import "XMWXBarButtonItem.h"

@interface XMWXBarButtonItem ()

@end

@implementation XMWXBarButtonItem
@synthesize wxAction = _wxAction,itemURL = _itemURL,frame = _frame;


#pragma mark - public method
+(instancetype)itemWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        
    }
    return self;
}
+(NSMutableArray *)itemsWithArray:(NSArray *)items
{
    NSMutableArray * arrayM = [NSMutableArray array];
    
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arrayM addObject:[XMWXBarButtonItem itemWithDict:obj]];
    }];
    return arrayM;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
#pragma mark - private method

#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle

@end
