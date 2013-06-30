//
//  SlidingViewController.m
//
//  Created by Brandon Smith on 6/29/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import "SlidingViewController.h"

@interface SlidingViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *menuContainerView;
@property (nonatomic, strong) UITapGestureRecognizer *contentTap;
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) MenuViewSide menuSide;
@end

@implementation SlidingViewController

#pragma mark - Initialization

+ (instancetype)controllerWithMenuWidth:(CGFloat)width side:(MenuViewSide)side
{
    return [[self alloc] initWithMenuWidth:width side:side];
}

- (id)initWithMenuWidth:(CGFloat)width side:(MenuViewSide)side
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _menuWidth = width;
        _menuSide = side;
    }
    return self;
}

#pragma mark - UIView lifecycle

- (void)loadView
{
    self.view = self.scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    CGRect frame = self.view.frame;
    CGPoint contentOrigin, menuOrigin;
    contentOrigin = [self originOffsetForContent];
    menuOrigin = [self originOffsetForMenu];
    
    self.scrollView.contentSize = [self contentSizeForOrientation:UIInterfaceOrientationPortrait];
    self.scrollView.contentOffset = contentOrigin;
    
    self.contentContainerView.frame = CGRectMake(contentOrigin.x, contentOrigin.y, frame.size.width, frame.size.height);
    self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.contentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.contentTap.enabled = NO;
    [self.contentContainerView addGestureRecognizer:self.contentTap];
    [self.view addSubview:self.contentContainerView];
    
    self.menuContainerView.frame = CGRectMake(menuOrigin.x, menuOrigin.y, self.menuWidth, frame.size.height);
    self.menuContainerView.autoresizingMask = [self resizingMaskForMenu];
    [self.view addSubview:self.menuContainerView];
}

#pragma mark - Private helpers

- (CGPoint)originOffsetForContent
{
    CGPoint origin;
    switch (self.menuSide) {
        case MenuViewSideLeft:
            origin = CGPointMake(self.menuWidth, 0);
            break;
            
        case MenuViewSideRight:
            origin = CGPointMake(0, 0);
            break;
    }
    return origin;
}

- (CGPoint)originOffsetForMenu
{
    CGPoint origin;
    switch (self.menuSide) {
        case MenuViewSideLeft:
            origin = CGPointMake(0, 0);
            break;
            
        case MenuViewSideRight:
            origin = CGPointMake(self.view.frame.size.width, 0);
            break;
    }
    return origin;
}

- (UIViewAutoresizing)resizingMaskForMenu
{
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight;
    mask |= (self.menuSide == MenuViewSideLeft) ? UIViewAutoresizingFlexibleRightMargin : UIViewAutoresizingFlexibleLeftMargin;
    return mask;
}

- (BOOL)isMenuFullyDisplayed
{
    BOOL fullyDisplayed;
    switch (self.menuSide) {
        case MenuViewSideLeft:
            fullyDisplayed = self.scrollView.contentOffset.x == 0;
            break;
            
        case MenuViewSideRight:
            fullyDisplayed = self.scrollView.contentOffset.x == self.menuWidth;
            break;
    }
    return fullyDisplayed;
}

- (CGAffineTransform)contentTransformForOffset:(CGPoint)offset
{
    CGAffineTransform t;
    switch (self.menuSide) {
        case MenuViewSideLeft:
            t = CGAffineTransformTranslate(CGAffineTransformIdentity, offset.x, 0);
            break;
            
        case MenuViewSideRight:
            t = CGAffineTransformTranslate(CGAffineTransformIdentity, offset.x, 0);
            break;
    }
    return t;
}

#pragma mark - Getters

- (UIScrollView *)scrollView
{
    if (_scrollView) return _scrollView;
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:screenFrame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.backgroundColor = [UIColor redColor];
    _scrollView.delegate = self;
    
    return _scrollView;
}

- (UIView *)contentContainerView
{
    if (_contentContainerView) return _contentContainerView;
    
    _contentContainerView = [UIView new];
    return _contentContainerView;
}

- (UIView *)menuContainerView
{
    if (_menuContainerView) return _menuContainerView;
    
    _menuContainerView = [UIView new];
    return _menuContainerView;
}

#pragma mark - Setters

- (void)setContentViewController:(UIViewController *)controller
{
    if (self.contentViewController) {
        [self setContentViewController:controller animated:NO];
        return;
    }
    
    _contentViewController = controller;
    [self addChildViewController:controller];
    controller.view.frame = self.contentContainerView.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentContainerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
}

- (void)setContentViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIViewController *oldController = self.contentViewController;
    _contentViewController = controller;
    
    [oldController willMoveToParentViewController:nil];
    [self addChildViewController:self.contentViewController];
    
    controller.view.frame = self.contentContainerView.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self
     transitionFromViewController:oldController
     toViewController:controller
     duration:animated ? 0.3 : 0.0
     options:kNilOptions
     animations:^ {
         
     }
     completion:^(BOOL finished) {
         [oldController removeFromParentViewController];
         [controller didMoveToParentViewController:self];
    }];
}

- (void)setMenuViewController:(UIViewController *)controller
{
    if (self.menuViewController) {
        [self setMenuViewController:controller animated:NO];
        return;
    }
    
    _menuViewController = controller;
    [self addChildViewController:controller];
    controller.view.frame = self.menuContainerView.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuContainerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

- (void)setMenuViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIViewController *oldController = self.menuViewController;
    _menuViewController = controller;
    
    [oldController willMoveToParentViewController:nil];
    [self addChildViewController:self.menuViewController];
    
    controller.view.frame = self.menuContainerView.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self
     transitionFromViewController:oldController
     toViewController:controller
     duration:animated ? 0.3 : 0.0
     options:kNilOptions
     animations:^ {
         
     }
     completion:^(BOOL finished) {
         [oldController removeFromParentViewController];
         [controller didMoveToParentViewController:self];
     }];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    self.contentTap.enabled = [self isMenuFullyDisplayed];
    self.contentContainerView.transform = [self contentTransformForOffset:offset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint currentTarget = *targetContentOffset;
    
    if (currentTarget.x > self.menuWidth/2.0f && currentTarget.x < self.menuWidth) *targetContentOffset = CGPointMake(self.menuWidth, 0.0f);
    if (currentTarget.x < self.menuWidth/2.0f && currentTarget.x > 0.0f) *targetContentOffset = CGPointZero;
}

#pragma mark - Rotation

- (CGSize)contentSizeForOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size;
    CGRect frame = self.view.frame;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(frame.size.height + self.menuWidth, frame.size.width);
    } else {
        size = CGSizeMake(frame.size.width + self.menuWidth, frame.size.height);
    }
    return size;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.scrollView.contentSize = [self contentSizeForOrientation:toInterfaceOrientation];
    self.scrollView.contentOffset = [self originOffsetForContent];
}

#pragma mark - Gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    [self.scrollView setContentOffset:[self originOffsetForContent] animated:YES];
}

@end
