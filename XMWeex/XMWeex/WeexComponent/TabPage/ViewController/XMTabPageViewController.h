

#import <UIKit/UIKit.h>
@class XMTabPageBar;

@interface XMTabPageBarItemModel : NSObject
@property (nonatomic,copy) NSString * renderURLOnline;

@property (nonatomic,copy) NSString * renderURLOnBundle;

@property (nonatomic,copy) NSString * itemImageURL;

@property (nonatomic,copy) NSString * itemImageSelectedURL;

@property (nonatomic,copy) NSString * itemBackgroundImageSelectedURL;
@property (nonatomic,copy) NSString * itemBackgroundImageURL;

@property (nonatomic,copy) NSString * itemTitle;

@property (nonatomic,copy) NSString * titleColor;

@property (nonatomic,copy) NSString * selectedTitleColor;

@property (nonatomic,copy) NSString * selectedIndicatorColor;

@property (nonatomic,strong) NSNumber * selectedIndicatorHeight;

@property (nonatomic,strong) NSNumber * tabBarHeight;

@property (nonatomic,strong) NSNumber * titleFontSize;

@property (nonatomic,copy) NSString * shadowColor;

@property (nonatomic,strong) NSNumber * fittingIndicatorViewWidthToTitle;


@property (nonatomic,copy) NSString * tabPageItemViewControllerClassName;




-(instancetype)initWithDict:(NSDictionary *)dict;

+(instancetype)itemsWithArray:(NSArray *)array;

+(instancetype)itemsWithDict:(NSDictionary *)dict;
@end

#pragma mark - XMTabPageItem

@interface XMTabPageItem : NSObject

@property (nonatomic, readonly) UIButton *button;

@end

#pragma mark - XMTabPageViewControllerItem

@interface XMTabPageViewControllerItem : XMTabPageItem

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIViewController *contentViewController;

+ (instancetype)tabPageItemWithTitle:(NSString *)title
                      viewController:(UIViewController *)contentViewController;

@end

#pragma mark - XMTabPageButtonItem

@interface XMTabPageButtonItem : XMTabPageItem

+ (instancetype)tabPageItemWithButton:(UIButton *)button;

@end

#pragma mark - XMTabPageBar

@interface XMTabPageBar : UIView

/**
 *  顶部标签栏高度
 */
@property (nonatomic, assign) CGFloat tabBarHeight UI_APPEARANCE_SELECTOR;

/**
 * 选择标记的高度。默认为3。
 */
@property (nonatomic, assign) CGFloat selectedIndicatorHeight UI_APPEARANCE_SELECTOR;

/**
 * 选择标记的颜色。默认是橙红色
 */
@property (nonatomic, copy) UIColor *selectedIndicatorColor UI_APPEARANCE_SELECTOR;

/**
 *  选择标记的字体。默认是 [UIFont systemFontOfSize:14].
 */
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;

/**
 * normal
 */
@property (nonatomic, copy) UIColor *titleColor UI_APPEARANCE_SELECTOR;

/**
 * selected
 */
@property (nonatomic, copy) UIColor *selectedTitleColor UI_APPEARANCE_SELECTOR;

/**
 * 阴影颜色 默认为灰色
 */
@property (nonatomic, copy) UIColor *shadowColor UI_APPEARANCE_SELECTOR;


@property (nonatomic, strong) UIView *selectionIndicatorView;

/**
 *  是否让选择标记视图跟title一样宽
 */
@property (nonatomic, assign) BOOL fittingIndicatorViewWidthToTitle;


/**
 自定义Button样式
 */
@property (nonatomic,copy) void(^handleButtonUI)(UIButton *btn,NSUInteger index);
@end

#pragma mark - XMTabPageViewController
@class XMTabPageViewController;

typedef void(^TabPageBarAnimationBlock)(XMTabPageViewController *weakTabPageViewController, UIButton *fromButton, UIButton *toButton, CGFloat progress);

@interface XMTabPageViewController : UIViewController

- (instancetype)initWithItems:(NSArray *)items;

@property (nonatomic, readonly) XMTabPageBar *tabPageBar;

@property (nonatomic, copy, readonly) NSArray *items;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, readonly) UIViewController *selectedViewController;

/**
 *  是否显示顶部标签栏.
 */
@property (nonatomic, assign) BOOL showTabPageBar;

/**
 *  是否允许滚动手势
 */
@property (nonatomic, assign) BOOL gestureScrollEnabled;

@property (nonatomic, strong, readonly) UIScrollView * mainScrollView;

/**
 *  执行页面上的改变后的回调
 */
@property (nonatomic, copy) void (^pageChangedBlock)(NSInteger selectedIndex);

/**
 *  顶部选择标签视图动画结束后的回调
 */
@property (nonatomic, copy) TabPageBarAnimationBlock tabPageBarAnimationBlock;

/**
 更新scrollView的top
 */
@property (nonatomic, copy) void(^updateMainScrollViewConstraintYBlock)(BOOL showTabbar,NSLayoutConstraint * mainScrollViewTop);


- (void)setSelectedIndexByIndex:(NSInteger)newIndex;

- (void)addConstraintsToView:(UIView *)view forIndex:(NSInteger)index;
@end
