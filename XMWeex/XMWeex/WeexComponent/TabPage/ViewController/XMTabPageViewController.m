

#import "XMTabPageViewController.h"

#define XMTABPAGE_RGB_COLOR(r, g, b)                [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define XMTABPAGE_IOS_VERSION_GREATER_THAN_7      ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)
#define XMTABPAGE_IOS_VERSION_GREATER_THAN_8      ([[[UIDevice currentDevice] systemVersion] intValue] >= 8)
#define XMTABPAGE_IOS_VERSION_LESS_THAN_8      ([[[UIDevice currentDevice] systemVersion] intValue] < 8)
#define XMTABPAGE_IOS_VERSION_GREATER_THAN_9      ([[[UIDevice currentDevice] systemVersion] intValue] >= 9)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CGSize XMtabpage_getTextSize(UIFont *font, NSString *text, CGFloat maxWidth) {
    if (XMTABPAGE_IOS_VERSION_GREATER_THAN_7) {
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
        return textSize;
    } else {
        CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        return textSize;
    }
}

@interface UIScrollView (UIGestureRecognizerDelegate)<UIGestureRecognizerDelegate>

@end

@implementation UIScrollView (UIGestureRecognizerDelegate)
//-(void)setContentOffset:(CGPoint)contentOffset
//{
//    CGPoint tem;
//    if (contentOffset.x == 0) {
//        tem = CGPointMake(1, contentOffset.y);
//    }
//    [self setContentOffset:tem];
//}
//
//-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
//{
//    CGPoint tem;
//    if (contentOffset.x == 0) {
//        tem = CGPointMake(1, contentOffset.y);
//    }
//    [self setContentOffset:tem animated:animated];
//}
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (self.contentOffset.x <= 0) {
//        if ([otherGestureRecognizer.delegate isKindOfClass:[UINavigationController class]]) {
//            return YES;
//        }
//    }
//
//    return NO;
//}

@end

#pragma clang diagnostic pop

@implementation XMTabPageBarItemModel
-(instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
+(instancetype)itemsWithArray:(NSArray *)array
{
    NSMutableArray * arrayM = [NSMutableArray array];
    
    for (NSDictionary * dict in array) {
        XMTabPageBarItemModel * item = [XMTabPageBarItemModel itemsWithDict:dict];
        [arrayM addObject:item];
        
    }
    return arrayM;
}
+(instancetype)itemsWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
@end

#pragma mark - XMTabPageItem
@interface XMTabPageItem ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation XMTabPageItem

@end
#pragma mark - XMTabPageViewControllerItem
@implementation XMTabPageViewControllerItem

+ (instancetype)tabPageItemWithTitle:(NSString *)title viewController:(UIViewController *)contentViewController {
    XMTabPageViewControllerItem *item = [XMTabPageViewControllerItem new];
    item.title = title;
    item.contentViewController = contentViewController;
    return item;
}

@end
#pragma mark - XMTabPageViewControllerItem
@implementation XMTabPageButtonItem

+ (instancetype)tabPageItemWithButton:(UIButton *)button {
    XMTabPageButtonItem *item = [XMTabPageButtonItem new];
    item.button = button;
    return item;
}

@end

#pragma mark - XMTabPageBar

@interface XMTabPageBar ()

@property (nonatomic, copy) NSArray *items;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) CGFloat indicatorWidth;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger previousSelectedIndex;

@property (nonatomic, copy) void (^tabChangedBlock)(NSInteger selectedIndex);

@property (nonatomic, copy) void (^tabDidChangeHeightBlock)();

@property (nonatomic, assign) BOOL hasRegistered;

@end

@implementation XMTabPageBar

+ (void)initialize {
    if (self == [XMTabPageBar class]) {
        [[XMTabPageBar appearance] setTabBarHeight:44];
        [[XMTabPageBar appearance] setTitleFont:[UIFont systemFontOfSize:14]];
        [[XMTabPageBar appearance] setTitleColor:XMTABPAGE_RGB_COLOR(38, 40, 49)];
        [[XMTabPageBar appearance] setSelectedTitleColor:XMTABPAGE_RGB_COLOR(231, 53, 53)];
        [[XMTabPageBar appearance] setSelectedIndicatorColor:XMTABPAGE_RGB_COLOR(255, 99, 99)];
        [[XMTabPageBar appearance] setSelectedIndicatorHeight:3.0];
        [[XMTabPageBar appearance] setShadowColor:XMTABPAGE_RGB_COLOR(208, 208, 208)];
        [[XMTabPageBar appearance] setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)setSelectedIndicatorColor:(UIColor *)selectedIndicatorColor
{
    _selectedIndicatorColor = selectedIndicatorColor;
    
    [self setupSelectionIndicatorView];
}
-(void)setIndicatorWidth:(CGFloat)indicatorWidth
{
    _indicatorWidth = indicatorWidth;
    
    [self setupSelectionIndicatorView];
}
-(void)setSelectedIndicatorHeight:(CGFloat)selectedIndicatorHeight
{
    _selectedIndicatorHeight = selectedIndicatorHeight;
    
//    self.selectionIndicatorView.height = selectedIndicatorHeight;
    [self setupSelectionIndicatorView];
}
-(void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    
    [self setNeedsDisplay];
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectionIndicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.fittingIndicatorViewWidthToTitle = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.frame.size.height);
    
    self.itemSize = CGSizeMake(CGRectGetWidth(self.bounds) / self.items.count, CGRectGetHeight(self.bounds));
    
    CGFloat currentX = 0;
    for (int i = 0; i < self.items.count; i++) {
        XMTabPageItem *item = self.items[i];
        UIButton *button;

        if ([item isKindOfClass:[XMTabPageViewControllerItem class]]) {
            XMTabPageViewControllerItem *vcItem = (XMTabPageViewControllerItem *) item;
            CGFloat titleWidth = XMtabpage_getTextSize(self.titleFont, vcItem.title, CGFLOAT_MAX).width + 16;
            if (titleWidth > self.itemSize.width) {
                self.itemSize = CGSizeMake(titleWidth, self.itemSize.height);
            }
            button = vcItem.button;
        } else if ([item isKindOfClass:[XMTabPageButtonItem class]]) {
            XMTabPageButtonItem *buttonItem = (XMTabPageButtonItem *) item;

            button = buttonItem.button;
        } else {
            assert(0);
        }

        
        button.frame = CGRectMake(currentX, 0, self.itemSize.width, self.itemSize.height);
        currentX += self.itemSize.width;
        if (currentX > self.bounds.size.width) {
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                UIScrollView * scrollView =                 ((UIScrollView * )self.superview);
                scrollView.contentSize = CGSizeMake(currentX, scrollView.contentSize.height);
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, currentX, self.frame.size.height);
            }
        }

    }
    [self setupSelectionIndicatorView];
}

- (void)drawRect:(CGRect)rect {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self removeObservers];

    UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5,
            CGRectGetWidth(self.bounds), 0.5)];
    shadow.backgroundColor = self.shadowColor;
    shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:shadow];

    if (self.items.count != 0) {
        CGFloat indicatorWidth = 0;

        for (int i = 0; i < self.items.count; i++) {
            XMTabPageItem *item = self.items[i];
            UIButton *button;

            if ([item isKindOfClass:[XMTabPageViewControllerItem class]]) {
                XMTabPageViewControllerItem *vcItem = (XMTabPageViewControllerItem *) item;

                UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
                vcItem.button = itemButton;
                itemButton.tag = i + 1;
                [self setupButtonStyleForButton:itemButton];
                
                [itemButton setTitle:vcItem.title forState:UIControlStateNormal];
                [itemButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                itemButton.selected = self.selectedIndex == i;

                button = itemButton;

                if (self.fittingIndicatorViewWidthToTitle) {
                    CGFloat titleWidth = XMtabpage_getTextSize(self.titleFont, vcItem.title, CGFLOAT_MAX).width + 5;
                    if (titleWidth > indicatorWidth) {
                        indicatorWidth = titleWidth;
                    }
				} else {
					[vcItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
					self.hasRegistered = YES;
				}
            } else if ([item isKindOfClass:[XMTabPageButtonItem class]]) {
                XMTabPageButtonItem *buttonItem = (XMTabPageButtonItem *) item;
                [self setupButtonStyleForButton:buttonItem.button];

                button = buttonItem.button;
            } else {
                assert(0);
            }

            [self addSubview:button];
        }

        if (!self.fittingIndicatorViewWidthToTitle) {
            indicatorWidth = CGRectGetWidth(self.bounds) / self.items.count;
        }
        self.indicatorWidth = indicatorWidth;
        [self addSubview:self.selectionIndicatorView];
        [self setupSelectionIndicatorView];

        if (self.tabChangedBlock) {
            self.tabChangedBlock(self.selectedIndex);
        }
    }
}

- (void)removeObservers {
	if (self.hasRegistered) {
		for (XMTabPageViewControllerItem *vcItem in self.items) {
			[vcItem removeObserver:self forKeyPath:@"title"];
		}
		
		self.hasRegistered = NO;
	}
}

- (void)dealloc {
	[self removeObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if ([keyPath isEqualToString:@"title"] && [object isKindOfClass:[XMTabPageViewControllerItem class]]) {
		NSInteger index = [self.items indexOfObject:object];
		if (index != NSNotFound) {
			UIButton *button = [self viewWithTag:index + 1];
			[button setTitle:((XMTabPageViewControllerItem *)object).title forState:UIControlStateNormal];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];

    [self setNeedsDisplay];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (self.previousSelectedIndex == selectedIndex) {
        return;
    }

    _selectedIndex = selectedIndex;

    UIButton *selectedButton = [self.items[_selectedIndex] button];
    selectedButton.selected = YES;
    if (!selectedButton) {
        [self drawRect:self.frame];
        selectedButton = [self.items[_selectedIndex] button];
    }
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView * scr = (UIScrollView *)self.superview;
        if (selectedButton.frame.origin.x < scr.contentSize.width - scr.frame.size.width) {
            [scr setContentOffset:selectedButton.frame.origin animated:YES];
        }else
        {
            if (scr.contentSize.width > scr.frame.size.width) {
                [scr setContentOffset:CGPointMake(scr.contentSize.width - scr.frame.size.width, 0)];
            }

        }
        
    }
    [self setupButtonStyleForButton:selectedButton];

    if (self.previousSelectedIndex != NSNotFound) {
        UIButton *previousSelectedButton = [self.items[self.previousSelectedIndex] button];
        previousSelectedButton.selected = NO;
        [self setupButtonStyleForButton:previousSelectedButton];
    }

    self.previousSelectedIndex = self.selectedIndex;
}

- (void)onScrollingForOffsetFactor:(CGFloat)factor {
    if (self.selectionIndicatorView != nil) {
        CGFloat offset = self.itemSize.width - CGRectGetWidth(self.selectionIndicatorView.bounds);

        CGRect frame = self.selectionIndicatorView.frame;
        frame.origin.x = (CGRectGetWidth(self.selectionIndicatorView.bounds) + offset) * factor + offset / 2;
        self.selectionIndicatorView.frame = frame;
    }
}

#pragma mark - private methods

- (void)setupButtonStyleForButton:(UIButton *)button {
    
    if (self.handleButtonUI) {
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectedTitleColor forState:UIControlStateHighlighted];
        [button setTitleColor:self.selectedTitleColor forState:UIControlStateSelected];
//        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        button.titleLabel.numberOfLines = 0;
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [button setBackgroundColor:[UIColor clearColor]];
        button.titleLabel.font = self.titleFont;
        self.handleButtonUI(button,button.tag);
    }else
    {
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectedTitleColor forState:UIControlStateHighlighted];
        [button setTitleColor:self.selectedTitleColor forState:UIControlStateSelected];
//        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        button.titleLabel.numberOfLines = 0;
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setBackgroundColor:[UIColor clearColor]];
        button.titleLabel.font = self.titleFont;
    }
    

}

- (void)setupSelectionIndicatorView {
    if (self.selectionIndicatorView == nil) {
        return;
    }
    CGFloat offset = self.itemSize.width - self.indicatorWidth;
    self.selectionIndicatorView.frame = CGRectMake(self.itemSize.width * self.selectedIndex + offset / 2,
            CGRectGetHeight(self.bounds) - CGRectGetHeight(self.selectionIndicatorView.bounds),
            self.indicatorWidth, self.selectedIndicatorHeight);
    self.selectionIndicatorView.backgroundColor = self.selectedIndicatorColor;
}

- (IBAction)onButtonClicked:(UIButton *)button {
    if (button.selected) {
        return;
    }

    XMTabPageItem *previousItem = self.items[self.selectedIndex];
    previousItem.button.selected = NO;

    self.selectedIndex = button.tag - 1;

    XMTabPageItem *selectedItem = self.items[self.selectedIndex];
    selectedItem.button.selected = YES;

    [UIView beginAnimations:nil context:nil];
    [self setupSelectionIndicatorView];
    [UIView commitAnimations];

    if (self.tabChangedBlock) {
        self.tabChangedBlock(self.selectedIndex);
    }
}

#pragma mark - UIAppearance methods

- (void)setTabBarHeight:(CGFloat)tabBarHeight {
    _tabBarHeight = tabBarHeight;

    CGRect frame = self.frame;
    frame.size.height = tabBarHeight;
    self.frame = frame;

    if (self.tabDidChangeHeightBlock) {
        self.tabDidChangeHeightBlock();
    }

    [self setNeedsDisplay];
}

- (void)setSelectionIndicatorView:(UIView *)selectionIndicatorView {
    _selectionIndicatorView = selectionIndicatorView;

    [self setNeedsDisplay];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;

    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;

    [self setNeedsDisplay];
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;

    [self setNeedsDisplay];
}

@end

#pragma mark - XMTabPageScrollView

@interface XMTabPageScrollView : UIScrollView {
    BOOL contentViewIsAlready;
}

@property (nonatomic, strong) UIView *contentView;

@end

@implementation XMTabPageScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_contentView];

        NSDictionary *viewDict = NSDictionaryOfVariableBindings(_contentView, self);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView(==self)]|" options:0 metrics:0 views:viewDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(==self)]|" options:0 metrics:0 views:viewDict]];
        contentViewIsAlready = YES;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if (!contentViewIsAlready) {
        [super addSubview:view];
    } else {
        [self.contentView addSubview:view];
    }
}

- (void)addConstraint:(NSLayoutConstraint *)constraint {
    if (!contentViewIsAlready) {
        [super addConstraint:constraint];
    } else {
        [self.contentView addConstraint:constraint];
    }
}

- (void)addConstraints:(NSArray *)constraints {
    if (!contentViewIsAlready) {
        [super addConstraints:constraints];
    } else {
        [self.contentView addConstraints:constraints];
    }
}

- (void)removeConstraints:(NSArray *)constraints {
    if (!contentViewIsAlready) {
        [super removeConstraints:constraints];
    } else {
        [self.contentView removeConstraints:constraints];
    }
}

- (NSArray *)constraints {
    return self.contentView.constraints;
}

@end

#pragma mark - XMTabPageViewController

@interface XMTabPageViewController () <UIScrollViewDelegate>

@property (nonatomic, copy, readwrite) NSArray *items;
//@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) NSLayoutConstraint *mainScrollViewConstraintY;

@property (nonatomic, assign) NSInteger previousSelectedIndex;
@property (nonatomic, strong) NSLayoutConstraint *offsetConstraintX;

@end

@implementation XMTabPageViewController
@synthesize mainScrollView = _mainScrollView;
@synthesize tabPageBar = _tabPageBar;
- (instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    if (self) {
        self.items = items;

        self.showTabPageBar = YES;
        self.gestureScrollEnabled = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    [self setupTabBar];

    [self.view addSubview:self.mainScrollView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"scrollView" : self.mainScrollView}]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mainScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];

    self.mainScrollViewConstraintY = [NSLayoutConstraint constraintWithItem:self.mainScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    self.mainScrollView.scrollsToTop = NO;
    [self.view addConstraint:self.mainScrollViewConstraintY];

    [self setupItems];

    self.selectedIndex = _selectedIndex;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (!self.mainScrollView.isTracking && !self.mainScrollView.dragging) { //this calls viewDidScroll
        self.mainScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * self.childViewControllers.count, CGRectGetHeight(self.mainScrollView.bounds));
    }
    
    [self.mainScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(obj.tag * self.mainScrollView.bounds.size.width, 0, self.mainScrollView.bounds.size.width, self.mainScrollView.bounds.size.height);
    }];
    
    [self.view bringSubviewToFront:self.tabPageBar];
    if (self.tabPageBar.superview) {
        [self.view bringSubviewToFront:self.tabPageBar.superview];
        self.tabPageBar.superview.frame = CGRectMake(self.tabPageBar.frame.origin.x, CGRectGetMaxY(self.parentViewController.navigationController.navigationBar.frame), self.view.frame.size.width, self.tabPageBar.frame.size.height);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods

- (void)setTabPageBarAnimationBlock:(TabPageBarAnimationBlock)tabPageBarAnimationBlock {
    _tabPageBarAnimationBlock = tabPageBarAnimationBlock;

    if (self.tabPageBar.layer.contents != nil) {
        self.tabPageBar.tabChangedBlock(self.selectedIndex);
    }
}

- (XMTabPageBar *)tabPageBar {
    
    if (_tabPageBar == nil) {
        _tabPageBar = [[XMTabPageBar alloc] init];
        
    }
    return _tabPageBar;
}
-(void)setTabPageBar:(XMTabPageBar *)tabPageBar
{
    _tabPageBar = tabPageBar;
    
    NSLog(@"%@",_tabPageBar);
}
- (void)setupTabBar {
    if (self.showTabPageBar) {
        
        self.tabPageBar.frame = CGRectMake(0, CGRectGetMinY(self.tabPageBar.frame), CGRectGetWidth(self.view.bounds), self.tabPageBar.tabBarHeight);
        self.tabPageBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        __weak XMTabPageViewController *weakSelf = self;
        [self.tabPageBar setTabChangedBlock:^(NSInteger selectedIndex) {
            if (weakSelf.tabPageBarAnimationBlock) {
                XMTabPageItem *selectedItem = weakSelf.items[weakSelf.selectedIndex];
                XMTabPageItem *willToSelectItem = weakSelf.items[selectedIndex];
                weakSelf.tabPageBarAnimationBlock(weakSelf, selectedItem == willToSelectItem ? nil : selectedItem.button, willToSelectItem.button, 1);
            }

            weakSelf.selectedIndex = selectedIndex;
        }];
        UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:self.tabPageBar.frame];
        [scrollView addSubview:self.tabPageBar];
        self.tabPageBar.frame = scrollView.bounds;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
//        scrollView.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:scrollView];
//        [self.view addSubview:self.tabPageBar];
        [self.tabPageBar setItems:self.items];

        [self.tabPageBar setTabDidChangeHeightBlock:^{
            [weakSelf updateMainScrollViewConstraintY];
        }];
    }
}

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        if (XMTABPAGE_IOS_VERSION_GREATER_THAN_7) {
            _mainScrollView = [[UIScrollView alloc] init];
        } else {
            _mainScrollView = [[XMTabPageScrollView alloc] init];
        }
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainScrollView.scrollEnabled = self.gestureScrollEnabled;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.alwaysBounceVertical = NO;
        _mainScrollView.directionalLockEnabled = YES;
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.delaysContentTouches = NO;
    }
    return _mainScrollView;
}

- (void)updateMainScrollViewConstraintY {
    if (self.updateMainScrollViewConstraintYBlock) {
        self.updateMainScrollViewConstraintYBlock(self.showTabPageBar,self.mainScrollViewConstraintY);
        XMTabPageViewControllerItem *selectedItem = self.items[self.selectedIndex];
        [self addConstraintsToView:selectedItem.contentViewController.view forIndex:self.selectedIndex];
    }else
    {
        if (self.showTabPageBar) {
            self.mainScrollViewConstraintY.constant = 0;
        } else {
            self.mainScrollViewConstraintY.constant = 0;
        }
    }

    
}

- (void)setupItems {
    for (int i = 0; i < self.items.count; i++) {
        XMTabPageItem *item = self.items[i];

        if ([item isKindOfClass:[XMTabPageViewControllerItem class]]) {
            XMTabPageViewControllerItem *vcItem = (XMTabPageViewControllerItem *) item;
            if (vcItem.contentViewController) {
                [self addChildViewController:vcItem.contentViewController];
            }
            
        }
    }
}

- (UIViewController *)selectedViewController {
    assert(self.items != nil);
    XMTabPageViewControllerItem *vcItem = self.items[self.selectedIndex];
    if ([vcItem isKindOfClass:[XMTabPageViewControllerItem class]]) {
        return vcItem.contentViewController;
    } else {
        return nil;
    }
}

- (void)setGestureScrollEnabled:(BOOL)gestureScrollEnabled {
    _gestureScrollEnabled = gestureScrollEnabled;

    self.mainScrollView.scrollEnabled = gestureScrollEnabled;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex < 0 || selectedIndex >= self.items.count) {
        return;
    }

    self.mainScrollView.contentOffset = // this calls viewDidScroll, thus logic must handle the fact its not really scrolling.
            CGPointMake(selectedIndex * CGRectGetWidth(self.mainScrollView.bounds), 0);
    [self setSelectedIndexByIndex:selectedIndex];
}

- (void)addConstraintsToView:(UIView *)view forIndex:(NSInteger)index {
    [self.mainScrollView setNeedsLayout];
    CGFloat offset = index * CGRectGetWidth(self.mainScrollView.bounds);
    view.tag = index;
    view.frame = CGRectMake(offset, 0, view.superview.bounds.size.width, view.superview.bounds.size.height);
    
//    view.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
//
//    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
//
//    [self.mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
//
//    [self.mainScrollView addConstraint:self.offsetConstraintX = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:offset]];
    
}

- (void)cleanupSubviews {
    for (UIView *subview in self.mainScrollView.subviews) {
        if (subview != self.selectedViewController.view) {
            [subview removeFromSuperview];
        }
    }
}

- (void)setSelectedIndexByIndex:(NSInteger)newIndex {
    XMTabPageViewControllerItem *selectedItem = self.items[newIndex];

    if ([selectedItem isKindOfClass:[XMTabPageViewControllerItem class]]) {
        if (selectedItem.contentViewController == nil) return;

        NSInteger previousSelectedIndex = _selectedIndex;
        _selectedIndex = newIndex;
        if (self.pageChangedBlock && previousSelectedIndex != newIndex) {
            self.pageChangedBlock(newIndex);
        }

        if (self.showTabPageBar) {
            self.tabPageBar.selectedIndex = newIndex;
        }

        if (selectedItem.contentViewController.view.superview == nil) {
            [self.mainScrollView addSubview:selectedItem.contentViewController.view];
            [self addConstraintsToView:selectedItem.contentViewController.view forIndex:_selectedIndex];
        }
        [self cleanupSubviews];
    }

    self.previousSelectedIndex = newIndex;
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (!XMTABPAGE_IOS_VERSION_LESS_THAN_8) {
        NSInteger index = self.selectedIndex;
        CGFloat width = self.mainScrollView.bounds.size.width ; //UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? self.mainScrollView.bounds.size.width : self.mainScrollView.bounds.size.height;
        CGFloat offset = index * width;
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        if (self.offsetConstraintX) {
            self.offsetConstraintX.constant = offset;
            self.mainScrollView.contentOffset = CGPointMake(offset, 0);
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    if (XMTABPAGE_IOS_VERSION_GREATER_THAN_8) {
        NSInteger index = self.selectedIndex;
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

        if (self.offsetConstraintX) {
            [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
                self.mainScrollView.contentOffset = CGPointMake(index * size.width, 0); //不加这个 动画有问题
                self.offsetConstraintX.constant = (index * size.width);
            } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
                self.mainScrollView.contentOffset = CGPointMake(index * size.width, 0);
                self.offsetConstraintX.constant = (index * size.width);
            }];
        }
    }
}


#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.mainScrollView.isDragging && !self.mainScrollView.decelerating) {
        return;
    }

    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat factor = contentOffset.x / CGRectGetWidth(scrollView.bounds);
    NSInteger willToIndex = -1;

    if (factor > (self.showTabPageBar ? self.tabPageBar.selectedIndex : self.selectedIndex)) {
        willToIndex = ceil(factor);
    } else if (factor < (self.showTabPageBar ? self.tabPageBar.selectedIndex : self.selectedIndex)) {
        willToIndex = floor(factor);
    }

    if (willToIndex == -1 || willToIndex >= self.childViewControllers.count) {
        willToIndex = NSNotFound;
    }

    if (self.showTabPageBar && (scrollView.isDecelerating || scrollView.isDragging)) {
        if (self.tabPageBarAnimationBlock) {
            __weak XMTabPageViewController *weakSelf = self;
            CGFloat progress = ABS(factor - self.tabPageBar.selectedIndex);
            if (progress >= 1.00) {
                progress -= 1.00;
                self.tabPageBar.selectedIndex = round(factor);
                self.tabPageBarAnimationBlock(weakSelf, nil, [self.items[self.tabPageBar.selectedIndex] button], 1);
            } else {
                XMTabPageItem *selectedItem = self.items[self.tabPageBar.selectedIndex];
                XMTabPageItem *willToSelectItem;
                if (willToIndex != NSNotFound) {
                    willToSelectItem = self.items[willToIndex];
                    if (![willToSelectItem isKindOfClass:[XMTabPageViewControllerItem class]]) {
                        willToSelectItem = nil;
                    }
                }
                self.tabPageBarAnimationBlock(weakSelf, selectedItem.button, willToSelectItem.button, progress);
            }
        }
        [self.tabPageBar onScrollingForOffsetFactor:factor];
    }

    if (!scrollView.isDragging)
        return; 

    if (willToIndex != NSNotFound) {
        XMTabPageViewControllerItem *item = self.items[willToIndex];
        if (item.contentViewController.view.superview == nil) {
            [self.mainScrollView addSubview:item.contentViewController.view];
            [self addConstraintsToView:item.contentViewController.view forIndex:willToIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger newIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    if (self.selectedIndex != newIndex) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
        [self setSelectedIndexByIndex:newIndex];
        [self didChangeValueForKey:NSStringFromSelector(@selector(selectedIndex))];
    }
    [self cleanupSubviews];
}

@end
