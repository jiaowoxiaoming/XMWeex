//
//  @header XMWXTabPageComponent.m
//  @abstract <##>
//  @version <##> 2017/6/12
//  Pods
//
//  Created by apple on 2017/6/12.
//
//


#import "XMWXTabPageComponent.h"
#import "XMTabPageViewController.h"
#import "XMWXViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "XMWXHeader.h"
#import <Masonry/Masonry.h>
#import <UIButton+WebCache.h>
@interface XMWXTabPageComponent ()

@property (nonatomic,strong) XMTabPageViewController * tabPageViewController;

@property (nonatomic,strong) NSArray <XMTabPageBarItemModel *> * pageBarItems;

@property (nonatomic,assign) NSInteger selectIndex;
@end

@implementation XMWXTabPageComponent

#pragma mark - public method
-(instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        self.selectIndex = 0;
        [self initTabPage:attributes];

    }
    return self;
}
//-(void)viewDidLoad
//{
//    [super viewDidLoad];
//    if ([[self.attributes objectForKey:@"pageItems"] length]) {
//
//
//    }
//}
-(void)updateAttributes:(NSDictionary *)attributes
{
    [self initTabPage:attributes];
}
#pragma mark - private method

-(void)initTabPage:(NSDictionary *)attributes
{
    if ([[attributes objectForKey:@"pageItems"] length]) {
        NSArray * itemArray = [NSJSONSerialization JSONObjectWithData:[[attributes objectForKey:@"pageItems"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        self.pageBarItems = [XMTabPageBarItemModel itemsWithArray:itemArray];
        if ([attributes objectForKey:@"selectIndex"] && [[attributes objectForKey:@"selectIndex"] respondsToSelector:@selector(integerValue)]) {
            self.selectIndex = [[attributes objectForKey:@"selectIndex"] integerValue];
        }
        [self handleTabPageViewController];
    }
}
/**
 操作pageViewController
 */
-(void)handleTabPageViewController
{
    /**
     当切换栏目时 懒加载视图
     */
    __weak typeof(self) weakSelf = self;
    [self.tabPageViewController setPageChangedBlock:^(NSInteger index) {
        __strong typeof(self) strongSelf = weakSelf;
        
        XMWXViewController * vc = (XMWXViewController *)self.tabPageViewController.selectedViewController;
        MBProgressHUD * hud = nil;
        if (!vc.instance.rootView && ![MBProgressHUD HUDForView:vc.view]) {
            vc.renderURL = [NSURL URLWithString:[self.pageBarItems objectAtIndex:index].renderURLOnline];
        }
    }];
    
    /**
     切换动画的回调
     */
    [self.tabPageViewController setTabPageBarAnimationBlock:^(XMTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress)
     {
         
         // animated font
         //         CGFloat pointSize = weakTabPageViewController.tabPageBar.titleFont.pointSize;
         //         CGFloat selectedPointSize = 18;
         //
         //         fromButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * (1 - progress)];
         //         toButton.titleLabel.font = [UIFont systemFontOfSize:pointSize + (selectedPointSize - pointSize) * progress];
         // animated button title color
         if (fromButton) {
             [weakSelf animatePageBarItemColor:fromButton progress:progress isToButton:NO];
         }
         if (toButton) {
             [weakSelf animatePageBarItemColor:toButton progress:progress isToButton:YES];
         }
         // animated IndicatorColor
         if (fromButton && toButton) {
             [weakSelf animatePageBarSelectedColor:fromButton toButton:toButton progress:progress];
         }else if (fromButton && !toButton)
         {
             weakSelf.tabPageViewController.tabPageBar.selectedIndicatorColor = colorWithHexString([weakSelf.pageBarItems objectAtIndex:fromButton.tag - 1].selectedIndicatorColor, 1.f);
         }else if (!fromButton && toButton)
         {
             self.tabPageViewController.tabPageBar.selectedIndicatorColor = colorWithHexString([self.pageBarItems objectAtIndex:toButton.tag - 1].selectedIndicatorColor,1.f);
         }
         
     }];
    
//
    if (self.selectIndex == 0) {
        self.tabPageViewController.pageChangedBlock(self.selectIndex);
    }else
    {
        [self.tabPageViewController setSelectedIndexByIndex:self.selectIndex];
    }

}

-(void)animatePageBarSelectedColor:(UIButton *)fromButton toButton:(UIButton *)toButton progress:(float)progress
{
    CGFloat red, green, blue;
    [colorWithHexString([self.pageBarItems objectAtIndex:fromButton.tag - 1].selectedIndicatorColor, 1.f) getRed:&red green:&green blue:&blue alpha:NULL];
  
    
    CGFloat selectedRed, selectedGreen, selectedBlue;
    [colorWithHexString([self.pageBarItems objectAtIndex:toButton.tag - 1].selectedIndicatorColor ,1.f) getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:NULL];
    
    self.tabPageViewController.tabPageBar.selectedIndicatorColor = [UIColor colorWithRed:red + (selectedRed - red) * progress green:green + (selectedGreen - green) * progress blue:blue + (selectedBlue - blue) * progress alpha:1];
}
-(void)animatePageBarItemColor:(UIButton *)button progress:(float)progress isToButton:(BOOL)isToButton
{
    // animated text color
    CGFloat red, green, blue;
    
    [colorWithHexString([self.pageBarItems objectAtIndex:button.tag - 1].titleColor ,1.f) getRed:&red green:&green blue:&blue alpha:NULL];
    
    CGFloat selectedRed, selectedGreen, selectedBlue;
    [colorWithHexString([self.pageBarItems objectAtIndex:button.tag - 1].selectedTitleColor ,1.f) getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:NULL];
    
    if (!isToButton) {
        [button setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * (1 - progress) green:green + (selectedGreen - green) * (1 - progress) blue: blue + (selectedBlue - blue) * (1 - progress) alpha:1] forState:UIControlStateSelected];
    }else
    {
        [button setTitleColor:[UIColor colorWithRed:red + (selectedRed - red) * progress green:green + (selectedGreen - green) * progress blue:blue + (selectedBlue - blue) * progress alpha:1] forState:UIControlStateNormal];
    }
    
    
    
}
-(NSArray <XMTabPageItem *> *)creatPageItems
{
    [self handleXMTabPageBar:self.pageBarItems.firstObject];
    NSMutableArray * items = [NSMutableArray array];
    [self.pageBarItems enumerateObjectsUsingBlock:^(XMTabPageBarItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        XMWXViewController * vc = [NSClassFromString(obj.tabPageItemViewControllerClassName) new];
        
        XMTabPageItem * item = [XMTabPageViewControllerItem tabPageItemWithTitle:obj.itemTitle viewController:vc];
        
        [items addObject:item];
    }];
    return items;
}
-(void)handleXMTabPageBar:(XMTabPageBarItemModel *)obj
{
    XMTabPageBar * tabPageBarAppearance = [XMTabPageBar appearance];
    
    [tabPageBarAppearance setTitleFont:[UIFont systemFontOfSize:obj.titleFontSize.floatValue]];
    [tabPageBarAppearance setTitleColor:colorWithHexString(obj.titleColor,1.f)];
    [tabPageBarAppearance setShadowColor: colorWithHexString(@"e1e2e3" ,1.f)];
    [tabPageBarAppearance setTabBarHeight:obj.tabBarHeight.floatValue];
    [tabPageBarAppearance setSelectedTitleColor:colorWithHexString(obj.selectedTitleColor,1.f)];
    [tabPageBarAppearance setSelectedIndicatorColor:colorWithHexString(obj.selectedIndicatorColor,1.f)];
    [tabPageBarAppearance setSelectedIndicatorHeight:obj.selectedIndicatorHeight.floatValue];
    _tabPageViewController.mainScrollView.contentInset = UIEdgeInsetsMake(_tabPageViewController.tabPageBar.tabBarHeight, 0, 0, 0);
}

#pragma mark - getter
#pragma mark -框架Controller
-(XMTabPageViewController *)tabPageViewController
{
    if (!_tabPageViewController) {
        NSArray * items = [self creatPageItems];
        
        _tabPageViewController = [[XMTabPageViewController alloc] initWithItems:items];
        //        _tabPageViewController.gestureScrollEnabled = NO;
        [self.weexInstance.viewController addChildViewController:_tabPageViewController];
        [self.weexInstance.viewController.view addSubview:_tabPageViewController.view];
        
        [_tabPageViewController didMoveToParentViewController:self];
        _tabPageViewController.tabPageBar.fittingIndicatorViewWidthToTitle = YES;
        [_tabPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.weexInstance.viewController.view);
            make.center.equalTo(self.weexInstance.viewController.view);
        }];

        _tabPageViewController.tabPageBar.backgroundColor = [UIColor whiteColor];

        //设置MainscrollView 的frame
        __weak typeof(self) weakSelf = self;
//        [_tabPageViewController setUpdateMainScrollViewConstraintYBlock:^(BOOL showTabbar,NSLayoutConstraint * mainScrollViewY) {
//            //            mainScrollViewY.constant = 0;
//            
//            [weakSelf.tabPageViewController.mainScrollView removeConstraints:weakSelf.tabPageViewController.mainScrollView.constraints];
//            [weakSelf.tabPageViewController.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(weakSelf.view);
//                make.bottom.equalTo(weakSelf.view);
//                make.leading.equalTo(weakSelf.view);
//                make.trailing.equalTo(weakSelf.view);
//            }];
//
//            
//            [weakSelf.tabPageViewController.view bringSubviewToFront:weakSelf.tabPageViewController.tabPageBar];
//        }];

        //tabpagebar Button UI configuration
        [_tabPageViewController.tabPageBar setHandleButtonUI:^(UIButton * button, NSUInteger index) {
            
            XMTabPageBarItemModel * pageBarItemViewModel = [weakSelf.pageBarItems objectAtIndex:index - 1];
            
            [button setTitleColor:colorWithHexString(pageBarItemViewModel.titleColor,1) forState:UIControlStateNormal];
            [button setTitleColor:colorWithHexString(pageBarItemViewModel.selectedTitleColor ,1) forState:UIControlStateHighlighted];
            [button setTitleColor:colorWithHexString(pageBarItemViewModel.selectedTitleColor,1) forState:UIControlStateSelected];
//            button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            button.titleLabel.numberOfLines = 0;
//            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setBackgroundColor:[UIColor clearColor]];
            button.titleLabel.font = [UIFont systemFontOfSize:pageBarItemViewModel.titleFontSize.floatValue];
            
            if (pageBarItemViewModel.itemImageURL.length > 0) {
                [button sd_setImageWithURL:[NSURL URLWithString:pageBarItemViewModel.itemImageURL] forState:(UIControlStateNormal) placeholderImage:nil];

            }
            if (pageBarItemViewModel.itemImageSelectedURL.length > 0) {
                [button sd_setImageWithURL:[NSURL URLWithString:pageBarItemViewModel.itemImageSelectedURL] forState:(UIControlStateSelected) placeholderImage:nil];

            }
            if (pageBarItemViewModel.itemBackgroundImageURL.length > 0) {
                
                [button sd_setBackgroundImageWithURL:[NSURL URLWithString:pageBarItemViewModel.itemBackgroundImageURL] forState:UIControlStateNormal placeholderImage:nil];
            }
            if (pageBarItemViewModel.itemBackgroundImageSelectedURL.length > 0) {
                
                [button sd_setBackgroundImageWithURL:[NSURL URLWithString:pageBarItemViewModel.itemBackgroundImageSelectedURL] forState:UIControlStateSelected placeholderImage:nil];
            }
        }];
    }
    return _tabPageViewController;
}

#pragma mark - setter

#pragma mark - life Cycle

@end
