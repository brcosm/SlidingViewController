//
//  SlidingViewController.h
//
//  Created by Brandon Smith on 6/29/13.
//  Copyright (c) 2013 Brandon Smith. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MenuViewSide)
{
    MenuViewSideLeft = 1,
    MenuViewSideRight
};

@interface SlidingViewController : UIViewController

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIViewController *menuViewController;

+ (instancetype)controllerWithMenuWidth:(CGFloat)width side:(MenuViewSide)side;

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated;

- (void)setMenuViewController:(UIViewController *)menuViewController animated:(BOOL)animated;

@end
