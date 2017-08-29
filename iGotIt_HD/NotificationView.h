//
//  NotificationView.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationView : UIView {
    
}

+ (id)notificationViewInView:(UIView *)aSuperview notificationMessage:(NSString *)notificationMessage withIndicator:(BOOL)withIndicator;
- (void)removeView;
@end
