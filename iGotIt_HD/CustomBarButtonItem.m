//
//  CustomBarButtonItem.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "CustomBarButtonItem.h"

@implementation UIButton (CustomButton)

+ (UIButton *) barButtonWithImage:(UIImage *)image title:(NSString *)title width:(CGFloat)width target:(id)target action:(SEL)action {
    
    CGRect rect;
    //Prepare a frame for the button
    if ([NSNumber numberWithFloat:width] == nil) {
        rect = CGRectMake(0, 0, 125, 30);
    } else {
        rect = CGRectMake(0, 0, width, 30);
    }
    
    UIButton *anButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [anButton setFrame:rect];
    [anButton setBackgroundColor:[UIColor clearColor]];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButtonStateNormal" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 10, 15, 10);
    [anButton setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButtonStateSelected" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    [anButton setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
    [anButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    //Setup the imageView
    UIImageView *imageView;
    if (image == nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
    } else {
        imageView = [[UIImageView alloc] initWithImage:image];
    }
    //imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(5, 7.5, 15, 15)];
    [imageView setTag:20];
    
    //Setup the label
    UILabel *label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(25, 0, width - 25, 30)];
    [label setTag:10];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:title];
    [label setFont:[UIFont boldSystemFontOfSize:13]];
    label.shadowOffset = CGSizeMake (0,-1);
    
    [anButton addSubview:imageView];
    [anButton addSubview:label];
    
    return anButton;
    
}

@end

@implementation UIBarButtonItem (CustomBarButtonItem)

+ (UIBarButtonItem *) barButtonWithBackground:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action {
   
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setBackgroundColor:[UIColor clearColor]];
    //format the label
    [button setTitle:title forState:UIControlStateNormal];
    [button setAutoresizesSubviews:YES];
    [button sizeToFit];
    float x = button.frame.origin.x;
    float y = button.frame.origin.y;
    float w = button.frame.size.width;
    float h = 30;
    CGRect frame = CGRectMake(x, y, w, h);
    [button setFrame:frame];
    
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [button.titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
    [SettingsClass setThemeButtonTextColor:button];
    
    if (target) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 10, 15, 10);
    [button setBackgroundImage:[image resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:button];
    if (action) {
        [bbi setAction:action];
    }
    if (target) {
        [bbi setTarget:target];
    }
    
    return bbi;
}

@end

