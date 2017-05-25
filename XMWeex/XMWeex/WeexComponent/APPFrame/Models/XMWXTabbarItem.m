//
//  @header XMWXTabbarItem.m
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import "XMWXTabbarItem.h"

@interface XMWXTabbarItem ()

@end

@implementation XMWXTabbarItem
@synthesize tintColor = _tintColor,title = _title,selectedTitleColor = _selectedTitleColor,normalTitleColor = _normalTitleColor,selectedImage = _selectedImage,image = _image;
#pragma mark - public method
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+(instancetype)itemWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
#pragma mark - private method


#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle

@end
