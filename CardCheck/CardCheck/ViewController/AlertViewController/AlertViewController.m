
#import "AlertViewController.h"
#import "UIImage+ImageEffects.h"

#import "NotificationManager.h"

#define lCancel NSLocalizedStringFromTable(@"cancel_button_title",   @"Common",   @"UI Controls")

@interface AlertViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *deviderView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *actionsView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;


@property (nonatomic, strong) NSArray<AlertAction *> *actions;

@end


@interface AlertAction ()

@property (nonatomic, copy) NSString *title;

@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, strong) UIView *customView;
@property (nonatomic, weak) AlertViewController *controller;

@property (nonatomic) UIAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(AlertAction *action);

+ (instancetype)cancelAction;
- (UIView *)view;

@end


@implementation AlertViewController

@dynamic title;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    AlertViewController *controller = [[AlertViewController alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
    controller.title = title;
    controller.message = message;
    
    return controller;
}

+ (instancetype)alertControllerWithCustomView:(UIView *)view
{
    AlertViewController *controller = [[AlertViewController alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
    controller.customView = view;
    
    return controller;
}

- (void)addAction:(AlertAction *)action
{
    action.controller = self;
    
    self.actions = self.actions ? [self.actions arrayByAddingObject:action] : @[action];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupViews];
    
    [self.view layoutIfNeeded];
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
}

- (UIModalPresentationStyle)modalPresentationStyle
{
    return UIModalPresentationCustom;
}

- (void)setupBrand
{
    [self.titleLabel setTextColor: BASE_TINT_COLOR];
    [self.deviderView setBackgroundColor: BASE_TINT_COLOR];
}

#pragma mark - Setup View

- (void)setupViews
{
    self.backgroundView.image = [self blurredSnapshot];
    
    [self.mainView setHidden: NO];
    
    if (self.customView) {
        [self setupCustomView];
    }
    else {
        [self setupLegacyView];
    }
    
    [self setupActionViews];
}

- (void)setupLegacyView
{
    self.titleLabel.hidden = NO;
    self.messageLabel.hidden = NO;
    
    self.titleLabel.text = self.title;
    self.messageLabel.text = self.message;
}

- (void)setupCustomView
{
    self.titleLabel.hidden = YES;
    self.messageLabel.hidden = YES;
    
    [self.customView setFrame: self.contentView.frame];
    [self.customView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.contentView addSubview:self.customView];
}

- (void)setupActionViews
{
    if (0 == self.actions.count)
        [self addAction: [AlertAction cancelAction]];
    
    UIView *prevView = nil;
    NSMutableArray *constraints = [NSMutableArray array];
    
    for (AlertAction *action in self.actions)
    {
        UIView *actionView = [action view];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem: actionView
                                                             attribute: NSLayoutAttributeTop
                                                             relatedBy: NSLayoutRelationEqual
                                                                toItem: self.actionsView
                                                             attribute: NSLayoutAttributeTop
                                                            multiplier: 1.0
                                                              constant: 0.0]];
        
        [constraints addObject: [NSLayoutConstraint constraintWithItem: actionView
                                                             attribute: NSLayoutAttributeBottom
                                                             relatedBy: NSLayoutRelationEqual
                                                                toItem: self.actionsView
                                                             attribute: NSLayoutAttributeBottom
                                                            multiplier: 1.0
                                                              constant: 0.0]];
        
        if (prevView) {
            [constraints addObject: [NSLayoutConstraint constraintWithItem: actionView
                                                                 attribute: NSLayoutAttributeLeading
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: prevView
                                                                 attribute: NSLayoutAttributeTrailing
                                                                multiplier: 1.0
                                                                  constant: 1.0]];
            
            [constraints addObject: [NSLayoutConstraint constraintWithItem: actionView
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: prevView
                                                                 attribute: NSLayoutAttributeWidth
                                                                multiplier: 1.0
                                                                  constant: 0.0]];
        }
        else {
            [constraints addObject: [NSLayoutConstraint constraintWithItem: actionView
                                                                 attribute: NSLayoutAttributeLeading
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: self.actionsView
                                                                 attribute: NSLayoutAttributeLeading
                                                                multiplier: 1.0
                                                                  constant: 0.0]];
        }
        
        [actionView setTranslatesAutoresizingMaskIntoConstraints: NO];
        
        [actionView addConstraint:[NSLayoutConstraint constraintWithItem: actionView
                                                               attribute: NSLayoutAttributeWidth
                                                               relatedBy: NSLayoutRelationGreaterThanOrEqual
                                                                  toItem: nil
                                                               attribute: NSLayoutAttributeNotAnAttribute
                                                              multiplier: 1.0
                                                                constant: [actionView sizeThatFits: UILayoutFittingCompressedSize].width + 16.0]];
        [self.actionsView addSubview: actionView];
        prevView = actionView;
    }
    
    [constraints addObject: [NSLayoutConstraint constraintWithItem: prevView
                                                         attribute: NSLayoutAttributeTrailing
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: self.actionsView
                                                         attribute: NSLayoutAttributeTrailing
                                                        multiplier: 1.0
                                                          constant: 0.0]];
    
    [self.actionsView addConstraints: constraints];
}

- (UIImage *)blurredSnapshot
{
    UIWindow *view = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.traitCollection.displayScale);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0.0 alpha:0.25] saturationDeltaFactor:1.8 maskImage:nil];
}

@end


@implementation AlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(AlertAction *))handler
{
    AlertAction *action = [AlertAction new];
    
    action.title = title;
    action.style = style;
    action.handler = handler;
    
    return action;
}

+ (instancetype)actionWithCustomView:(UIView *)view handler:(void (^)(AlertAction *))handler
{
    AlertAction *action = [AlertAction new];
    
    action.customView = view;
    action.handler = handler;
    
    return action;
}

+ (instancetype)cancelAction
{
    return [AlertAction actionWithTitle:lCancel style:UIAlertActionStyleCancel handler:nil];
}

- (void)callAction:(id)sender
{
    if (self.controller) {
        [[NotificationManager sharedInstance] hideAlert: self.controller completion:^{
            if (self.handler) {
                self.handler(self);
            }
        }];
    }
}

- (UIView *)view
{
    if (self.customView) {
        [self.customView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAction:)]];
        return self.customView;
    }
    else {
        return [self button];
    }
}

- (UIButton *)button
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setTitle: self.title forState: UIControlStateNormal];
    [button.titleLabel setLineBreakMode: NSLineBreakByWordWrapping];
    [button.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [button.titleLabel setNumberOfLines: 2];
    
    [button addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
    
    switch (self.style) {
        case UIAlertActionStyleCancel:
            [button.titleLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size: [UIFont labelFontSize]]];
            break;
            
        case UIAlertActionStyleDestructive:
            [button setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    return button;
}

@end
