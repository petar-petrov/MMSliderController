//
//  ViewController.h
//  slider
//
//  Created by Petar Petrov on 22/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMSliderViewDelegate;

typedef void(^CompletionHandler)(void);

typedef NS_ENUM(NSInteger, MMSliderControllerState) {
    MMSliderControllerStateShowLeftView,
    MMSliderControllerStateHideLeftView
};

@interface MMSliderController : UIViewController

@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic, readonly) UIViewController *leftViewController;
@property (strong, nonatomic, readonly) UIViewController *frontViewController;

@property (nonatomic) NSTimeInterval animationDuration;

@property (weak, nonatomic) id <MMSliderViewDelegate> delegate;

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController leftViewController:(UIViewController *)leftViewController;

- (void)revealLeftViewController;

- (void)setFrontViewController:(UIViewController *)viewController completionHandler:(CompletionHandler)block;

@end

@interface UIViewController (SwipeViewController)

- (MMSliderController *)swipeViewController;

@end

@protocol MMSliderViewDelegate <NSObject>

@optional

- (void)sliderController:(MMSliderController *)sliderContrller willChangeToState:(MMSliderControllerState)state;

- (void)sliderController:(MMSliderController *)sliderContrller didChangeToState:(MMSliderControllerState)state;

@end

