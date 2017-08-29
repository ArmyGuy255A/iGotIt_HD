//
//  CustomModalAlert.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
{
    CFRunLoopRef currentLoop;
    NSUInteger index;
}

@property (readonly) NSUInteger index;

@end

@interface ModalAlert : UIAlertView 
+(BOOL)ask:(NSString *)question title:(NSString *)title;
+(BOOL)confirm:(NSString *)statement title:(NSString *)title;
@end
