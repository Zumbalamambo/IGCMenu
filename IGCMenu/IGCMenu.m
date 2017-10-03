//
//  IGCMenu.m
//  IGCMenu
//
//  Created by Sunil Sharma on 11/02/16.
//  Copyright (c) 2016 Sunil Sharma. All rights reserved.
//

#import "IGCMenu.h"
#import <QuartzCore/QuartzCore.h>

#define MENU_START_TAG(offset) (6000 + offset)
#define MENU_NAME_LABEL_TAG(offset) (6100 + offset)
#define ANIMATION_DURATION 0.4
#define MENU_BACKGROUND_VIEW_TAG 6200

@implementation IGCMenu{
    NSMutableArray *menuButtonArray;        //array of menu buttons
    NSMutableArray *menuNameLabelArray;     //array of menu name label
    UIView *pMenuButtonSuperView;
    
    int maxRow;
    __block CGFloat topMenuCenterY;
    CGFloat eachMenuWidth;
    CGFloat eachMenuVerticalSpace;
    BOOL isCircularMenu;
    BOOL isGridMenu;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        menuButtonArray = [[NSMutableArray alloc] init];
        menuNameLabelArray = [[NSMutableArray alloc] init];
        //Default values
        self.disableBackground = YES;
        self.numberOfMenuItem = 0;
        self.menuRadius = 120;
        self.maxColumn = 3;
        self.backgroundType = BlurEffectDark;
        
        //observe orientation changes
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationChanged:)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)createMenuButtons{
    [menuButtonArray removeAllObjects];
    [menuNameLabelArray removeAllObjects];
    for (int i = 0; i < self.numberOfMenuItem; i++) {
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.backgroundColor = [UIColor whiteColor];
        menuButton.tag = MENU_START_TAG(i);
        CGRect newFrame = menuButton.frame;
        CGFloat menuButtonSize;
        if (self.menuHeight) {
            menuButtonSize = self.menuHeight;
        }
        else{
            menuButtonSize = self.menuHeight = 65;
        }
        newFrame.size = CGSizeMake(menuButtonSize, menuButtonSize);
        menuButton.frame = newFrame;
        
        menuButton.center = self.menuButton.center;
        menuButton.layer.cornerRadius = menuButton.frame.size.height / 2;
        menuButton.layer.masksToBounds = YES;
        menuButton.layer.opacity = 0.0;
        [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [pMenuButtonSuperView insertSubview:menuButton belowSubview:self.menuButton];
        [menuButtonArray addObject:menuButton];
        //Display menu name if present
        if (self.menuItemsNameArray.count > i) {
            UILabel *menuNameLabel = [[UILabel alloc] init];
            menuNameLabel.backgroundColor = [UIColor clearColor];
            menuNameLabel.numberOfLines = 1;
            newFrame = menuNameLabel.frame;
            newFrame.size = CGSizeMake(menuButton.frame.size.width, 20);
            menuNameLabel.frame = newFrame;
            menuNameLabel.center = menuButton.center;
            menuNameLabel.layer.opacity = 0.0;
            menuNameLabel.textAlignment = NSTextAlignmentCenter;
            menuNameLabel.font = [UIFont systemFontOfSize:12];
            menuNameLabel.text = self.menuItemsNameArray[i];
            [menuNameLabel sizeToFit];
            menuNameLabel.textColor = [UIColor whiteColor];
            [pMenuButtonSuperView insertSubview:menuNameLabel belowSubview:self.menuButton];
            [menuNameLabelArray addObject:menuNameLabel];
        }
        
        //Set custom menus button background color if present
        if (self.menuBackgroundColorsArray.count > i) {
            menuButton.backgroundColor =(UIColor *)self.menuBackgroundColorsArray[i];
        }
        
        //Display menu images if present
        if (self.menuImagesNameArray.count > i) {
            [menuButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",self.menuImagesNameArray[i]]] forState:UIControlStateNormal];
        }
    }
}

- (void)menuSuperViewBackground{
    if (pMenuButtonSuperView == nil) {
        pMenuButtonSuperView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        pMenuButtonSuperView.tag = MENU_BACKGROUND_VIEW_TAG;
    }
    if (!self.menuSuperView) {
            self.menuSuperView = [self.menuButton superview];
    }
    [self.menuSuperView bringSubviewToFront:self.menuButton];
    [self.menuSuperView insertSubview:pMenuButtonSuperView belowSubview:self.menuButton];
    
    if (self.disableBackground){
        pMenuButtonSuperView.userInteractionEnabled = YES;
    }
    else{
        pMenuButtonSuperView.userInteractionEnabled = NO;
    }
    [self setBackgroundEffect];
}

-(void)setBackgroundEffect{
    
    switch (self.backgroundType) {
        case Dark:
            pMenuButtonSuperView.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
            break;
        case BlurEffectDark:
            [self setBlurredView:UIBlurEffectStyleDark];
            break;
        case BlurEffectLight:
            [self setBlurredView:UIBlurEffectStyleLight];
            break;
        case BlurEffectExtraLight:
            [self setBlurredView:UIBlurEffectStyleExtraLight];
            break;
        case None:
            pMenuButtonSuperView.layer.backgroundColor = [UIColor clearColor].CGColor;
            break;
        default:
            pMenuButtonSuperView.layer.backgroundColor = [UIColor clearColor].CGColor;
            break;
    }
}

-(void)setBlurredView:(UIBlurEffectStyle) blurEffectStyle{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = pMenuButtonSuperView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [pMenuButtonSuperView addSubview:blurEffectView];
    }
    else {
        pMenuButtonSuperView.backgroundColor = [UIColor clearColor];
    }
}

- (void)showCircularMenu{
    isCircularMenu = true;
    
    [self menuSuperViewBackground];
    
    if (menuButtonArray.count <= 0) {
        [self createMenuButtons];
    }
    //menuButton.center = CGPointMake(homeButtonCenter.x - radius * cos(angle * i), homeButtonCenter.y - radius * sin(angle * i));
    
    for (int  i = 1; i < menuButtonArray.count * 2; i=i+2) {
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            pMenuButtonSuperView.layer.opacity = 1.0;
            [self updateCircularMenuLayoutAtIndex:i];
        }completion:nil];
    }
}

- (void)updateCircularMenuLayoutAtIndex:(int)i{
    UIButton * menuButton = (UIButton *)[menuButtonArray objectAtIndex:i/2];
    menuButton.layer.opacity = 1.0;
    CGFloat angle = M_PI / (menuButtonArray.count * 2);
    menuButton.center = CGPointMake(self.menuButton.center.x - self.menuRadius * cos(angle * i), self.menuButton.center.y - self.menuRadius * sin(angle * i));
    if (menuNameLabelArray.count > (i/2)) {
        UILabel *menuNameLabel = (UILabel *)[menuNameLabelArray objectAtIndex:i/2];
        menuNameLabel.layer.opacity = 1.0;
        menuNameLabel.center = CGPointMake(menuButton.center.x, menuButton.frame.origin.y + menuButton.frame.size.height  + (menuNameLabel.frame.size.height / 2) + 5);
    }
}

- (void)hideCircularMenu{
    isCircularMenu = false;
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        for (int i = 0; i < menuButtonArray.count; i++) {
            UIButton *menuButton = (UIButton *)[menuButtonArray objectAtIndex:i];
            menuButton.layer.opacity = 0.0;
            menuButton.center = self.menuButton.center;
            if (menuNameLabelArray.count > i) {
                UILabel *menuNameLabel = (UILabel *)[menuNameLabelArray objectAtIndex:i];
                menuNameLabel.layer.opacity = 0.0;
                menuNameLabel.center = self.menuButton.center;
                pMenuButtonSuperView.layer.opacity = 0.0;
            }
        }
    } completion:^(BOOL finished) {
        [pMenuButtonSuperView removeFromSuperview];
        pMenuButtonSuperView = nil;
        for (int i = 0; i < menuButtonArray.count; i++) {
            UIButton *menuButton = (UIButton *)[menuButtonArray objectAtIndex:i];
            [menuButton removeFromSuperview];
            if (menuNameLabelArray.count > i) {
                UILabel *menuNameLabel = (UILabel *)[menuNameLabelArray objectAtIndex:i];
                [menuNameLabel removeFromSuperview];
            }
        }
        [menuNameLabelArray removeAllObjects];
        [menuButtonArray removeAllObjects];
    }];
}

-(void)showGridMenu{
    isGridMenu = true;
    [self menuSuperViewBackground];
    if (menuButtonArray.count <= 0) {
        [self createMenuButtons];
    }
    
    [self setMenuButtonLayout];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        pMenuButtonSuperView.layer.opacity = 1.0;
        [self updateGridMenuLayout];
    }completion:nil];
}

-(void)setMenuButtonLayout{
    maxRow = ceilf(menuButtonArray.count /(float)self.maxColumn);
    topMenuCenterY = self.menuButton.frame.origin.y - 10;
    eachMenuVerticalSpace = 0;
    eachMenuWidth = 0;
    if (menuButtonArray.count) {
        UIButton *menuButton = (UIButton *)menuButtonArray[0];
        eachMenuVerticalSpace = menuButton.frame.size.height + 20;
        eachMenuWidth = menuButton.frame.size.width;
        if (menuNameLabelArray.count) {
            UILabel *nameLabel = (UILabel *)menuNameLabelArray[0];
            eachMenuVerticalSpace = eachMenuVerticalSpace + nameLabel.frame.size.height;
        }
        topMenuCenterY = topMenuCenterY - (eachMenuVerticalSpace * maxRow) + menuButton.frame.size.height/2;
    }
    else{
        eachMenuVerticalSpace = 100.0;
        topMenuCenterY = topMenuCenterY - (eachMenuVerticalSpace * maxRow) + eachMenuVerticalSpace/3;
    }
}

- (void)updateGridMenuLayout{
    
     __block CGFloat distanceBetweenMenu = ((pMenuButtonSuperView.frame.size.width - (self.maxColumn*eachMenuWidth))/(self.maxColumn +1));
    int menuIndex = 0;
    //for each row
    for(int  i = 1; i <= maxRow; i++,topMenuCenterY += eachMenuVerticalSpace) {
        
        int remainingMenuButton = self.maxColumn;
        //CGFloat menuCenterX = distanceBetweenMenu;
        
        CGFloat menuCenterX;
        //for each column
        for (int j = 1; j <= remainingMenuButton; j++) {
            UIButton *menuButton = (UIButton *)[menuButtonArray objectAtIndex:menuIndex];
            menuButton.layer.opacity = 1.0;
            
            menuCenterX = (distanceBetweenMenu *j) + (2*j - 1)*(menuButton.frame.size.width/2);
            if (i == maxRow) {
                remainingMenuButton = menuButtonArray.count % self.maxColumn;
                if (remainingMenuButton == 0) {
                    remainingMenuButton = self.maxColumn;
                }
                menuCenterX = menuCenterX + ((self.maxColumn - remainingMenuButton)*(distanceBetweenMenu/2)) + (self.maxColumn - remainingMenuButton)*menuButton.frame.size.width/2;
            }
            menuButton.center = CGPointMake(menuCenterX, topMenuCenterY);
            
            if (menuNameLabelArray.count > menuIndex) {
                UILabel *menuNameLabel = (UILabel *)[menuNameLabelArray objectAtIndex:menuIndex];
                menuNameLabel.layer.opacity = 1.0;
                menuNameLabel.center = CGPointMake(menuButton.center.x, menuButton.frame.origin.y + menuButton.frame.size.height  + (menuNameLabel.frame.size.height / 2) + 5);
            }
            
            menuIndex++;
        }
    }
}

-(void)hideGridMenu{
    isGridMenu = false;
    [self hideCircularMenu];
}

- (void)menuButtonClicked:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(igcMenuSelected:atIndex:)]) {
    int index;
    NSInteger buttonTag =  sender.tag;
    for (index = 0; index < menuButtonArray.count; index++) {
        UIButton *menuButton = (UIButton *)[menuButtonArray objectAtIndex:index];
        if (menuButton.tag == buttonTag) {
            NSString *menuName;
            if (self.menuItemsNameArray.count > index) {
                menuName = self.menuItemsNameArray[index];
            }
            if (self.delegate) {
                [self.delegate igcMenuSelected:menuName atIndex:index];
            }
            break;
        }
    }
}
}

//MARK: Orientation changes
- (void)orientationChanged:(NSNotification *)note{
    UIDevice * device = note.object;
    switch(device.orientation){
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            [pMenuButtonSuperView setFrame: [UIScreen mainScreen].bounds];
            /* update menu animation */
            if (isCircularMenu){
                for (int  i = 1; i < menuButtonArray.count * 2; i=i+2) {
                    [self updateCircularMenuLayoutAtIndex:i];
                }
            } else if (isGridMenu){
                [self setMenuButtonLayout];
                [self updateGridMenuLayout];
            }
            break;
        default:
            break;
    };
}

@end
