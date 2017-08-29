//
//  NotificationPanel.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/30/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawingClass.h"
#import <QuartzCore/QuartzCore.h>

#define NOTIFICATION_PANEL 6873
#define THE_BLOCKER 563
@interface NotificationPanel : UIView

+ (id)notificationViewInView:(UIView *)aSuperview title:(NSString *)title message:(NSString *)message withView:(UIView *)view;

-(void)removePanel;

@end

