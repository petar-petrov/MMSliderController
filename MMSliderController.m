//
//  ViewController.m
//  slider
//
//  Created by Petar Petrov on 22/02/2016.
//  Copyright © 2016 Petar Petrov. All rights reserved.
//

#import "MMSliderController.h"

@interface MMSliderController () <UIDynamicAnimatorDelegate>

@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

@property (assign, nonatomic, getter=isDraggingContainerView) BOOL draggingContainerView;
@property (assign, nonatomic, getter=isLeftViewShown) BOOL leftViewShown;

@property (strong, nonatomic, readwrite) UIViewController *leftViewController;
@property (strong, nonatomic, readwrite) UIViewController *frontViewController;

@property (strong, nonatomic) UIView *containerView;

@end

@implementation MMSliderController

#pragma mark - Custom Accessor

#pragma mark - Initilizers

- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController leftViewController:(UIViewController *)leftViewController {
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        _frontViewController = frontViewController;
        _leftViewController = leftViewController;
        
        self.animationDuration = .4;
    }
    
    return self;
}

#pragma mark - Life Cycle

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor redColor];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.backgroundColor = [UIColor redColor];
    [self configureShadowForFrontView:self.containerView];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.containerView];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.tapGestureRecognizer.enabled = NO;
    
    [self.containerView addGestureRecognizer:self.tapGestureRecognizer];
    
    if (self.frontViewController) {
        
        [self addChildViewController:self.frontViewController];
        
        self.frontViewController.view.frame = self.view.bounds;
        [self.containerView addSubview:self.frontViewController.view];
        
        [self.frontViewController didMoveToParentViewController:self];
    }
    
    if (self.leftViewController) {
        [self addChildViewController:self.leftViewController];
        
        self.leftViewController.view.frame = self.view.bounds;
        [self.view insertSubview:self.leftViewController.view belowSubview:self.containerView];
        
        [self.leftViewController didMoveToParentViewController:self];
    }
}

#pragma mark - Public

- (void)revealLeftViewController {
    [self animateFrontViewWithState:MMSliderControllerStateShowLeftView];
}

- (void)setFrontViewController:(UIViewController *)viewController completionHandler:(CompletionHandler)block {
    
    BOOL isCurrentViewController = [self.frontViewController isEqual:viewController];
    
    if (isCurrentViewController) {
        [self hideLeftViewController];
        
        if (block != nil)
            block();
        
        return;
    }
    
    [self.frontViewController willMoveToParentViewController:nil];
    [self.frontViewController beginAppearanceTransition:NO animated:NO];
    [self addChildViewController:viewController];
    [viewController beginAppearanceTransition:YES animated:NO];

    
    [UIView animateWithDuration:(self.animationDuration)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.containerView.center = CGPointMake(self.containerView.center.x + self.view.bounds.size.width, self.containerView.center.y);
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                             // remove old view controller
                             [self.frontViewController endAppearanceTransition];
                             [self.frontViewController.view removeFromSuperview];
                             [self.frontViewController removeFromParentViewController];
                          
                             
                             self.frontViewController = viewController;
                             self.frontViewController.view.frame = self.containerView.bounds;
                             [self.containerView addSubview:self.frontViewController.view];
                             self.containerView.frame = CGRectMake(self.view.bounds.size.width, self.view.frame.origin.y, self.view.bounds.size.width , self.view.bounds.size.height);
                             
                             [UIView animateWithDuration:self.animationDuration
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.containerView.center = self.view.center;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self.frontViewController endAppearanceTransition];
                                                  [self.frontViewController didMoveToParentViewController:self];
                                                  
                                                  [self setFlagsForLeftViewShown:NO];
                                                  if (block != nil && finished) {
                                                      block();
                                                  }
                                              }];
                         }
                     }];
}

#pragma mark - Private

- (void)configureShadowForFrontView:(UIView *)view {
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(-2.0f, 0.0f);
    view.layer.shadowOpacity = 0.8f;
    view.layer.shadowRadius = 2.0f;
}

- (void)hideLeftViewController {
    [self animateFrontViewWithState:MMSliderControllerStateHideLeftView];

}

- (void)handleTapGesture:(UITapGestureRecognizer *)geseture {
    [self hideLeftViewController];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint locationInView = [gesture locationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ((locationInView.x < 80.0f  && velocity.x > 0 && !self.isLeftViewShown)) {
            self.draggingContainerView = YES;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged && self.isDraggingContainerView) {
        
        CGPoint translation = [gesture translationInView:self.view];
        
        CGFloat newX = self.containerView.frame.origin.x + translation.x;
        
        if (newX <= self.view.frame.origin.x) {
            self.containerView.frame = self.view.bounds;
        } else {
            self.containerView.frame = CGRectMake(newX, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        }
        
        [gesture setTranslation:CGPointZero inView:self.view];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded && self.isDraggingContainerView) {
        
        
        if ((locationInView.x < CGRectGetMidX(self.view.bounds) && velocity.x > 50) || (locationInView.x > CGRectGetMidX(self.view.bounds) && velocity.x > 0)) {

            [self animateFrontViewWithState:MMSliderControllerStateShowLeftView];
        } else {
            [self animateFrontViewWithState:MMSliderControllerStateHideLeftView];
        }
        
        self.draggingContainerView = NO;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self.frontViewController.view setNeedsUpdateConstraints];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)animateFrontViewWithState:(MMSliderControllerState)state {
    
    CGRect newFrame;
    
    CGFloat minSize = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGFloat damping = 1;
    
    switch (state) {
                case MMSliderControllerStateShowLeftView: {
                    damping = 0.6;

                    [self setFlagsForLeftViewShown:YES];
                    newFrame = CGRectMake(minSize - 60, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
                    break;
                }
                case MMSliderControllerStateHideLeftView: {
                    [self setFlagsForLeftViewShown:NO];
                    newFrame = CGRectMake(self.view.bounds.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
                    break;
                }
                default:
                    break;
            }
    
    if ([self.delegate respondsToSelector:@selector(sliderController:willChangeToState:)]) {
        [self.delegate sliderController:self willChangeToState:state];
    }
    
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
         usingSpringWithDamping:damping
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.containerView.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         if ([self.delegate respondsToSelector:@selector(sliderController:didChangeToState:)]) {
                             [self.delegate sliderController:self didChangeToState:state];
                         }
                     }];
        
}

- (void)setFlagsForLeftViewShown:(BOOL)flag {
    self.leftViewShown = flag;
    
    self.frontViewController.view.userInteractionEnabled = !flag;
    self.tapGestureRecognizer.enabled = flag;
}

@end

@implementation UIViewController (SwipeViewController)

- (MMSliderController *)swipeViewController {
    
    UIViewController *controller = self.parentViewController;
    
    if (controller == nil) {
        return nil;
    }
    
    if ([controller isKindOfClass:[MMSliderController class]]) {
        return (MMSliderController *)controller;
    } else {
        return [controller swipeViewController];
    }
}

@end
