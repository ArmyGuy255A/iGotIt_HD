//
//  CustomBarButtonItem.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (CustomButton)

+ (UIButton *) barButtonWithImage:(UIImage *)image title:(NSString *)title width:(CGFloat)width target:(id)target action:(SEL)action; 


@end



@interface UIBarButtonItem (CustomBarButtonItem)

+ (UIBarButtonItem *) barButtonWithBackground:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action; 

@end
