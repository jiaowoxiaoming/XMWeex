//
//  @header XMWXNavigationItem.m
//  @abstract <##>
//  @version <##> 2017/5/18
//  XMWeex
//
//  Created by apple on 2017/5/18.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import "XMWXNavigationItem.h"
#import "XMWXBarButtonItem.h"
@interface XMWXNavigationItem ()

@end

@implementation XMWXNavigationItem
@synthesize title = _title,leftItemsInfo = _leftItemsInfo,rightItemsInfo = _rightItemsInfo,navigationBarBackgroundColor = _navigationBarBackgroundColor,navgationBarBackgroundImage = _navgationBarBackgroundImage,hiddenNavgitionBar = _hiddenNavgitionBar,clearNavigationBar = _clearNavigationBar,customTitleViewURL = _customTitleViewURL,blurTitleColor = _blurTitleColor,clearTitleColor = _clearTitleColor,rootViewURL = _rootViewURL,scrollViewTopDel = _scrollViewTopDel,statusBarStyle = _statusBarStyle,titleFont = _titleFont;

+(instancetype)infoWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
        self.leftItemsInfo = [XMWXBarButtonItem itemsWithArray:[dict objectForKey:@"leftItemsInfo"]];
        self.rightItemsInfo = [XMWXBarButtonItem itemsWithArray:[dict objectForKey:@"rightItemsInfo"]];
    }
    return self;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
#pragma mark - public method

#pragma mark - private method

#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle

@end
