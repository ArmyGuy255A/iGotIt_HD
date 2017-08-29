//
//  CustomModalAlert.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "CustomModalAlert.h"

@implementation ModalAlertDelegate
@synthesize index;

// Initialize with the supplied run loop
-(id) initWithRunLoop: (CFRunLoopRef)runLoop {
    if (self = [super init]) currentLoop = runLoop;
    return self;
}

//User pressed button. Retrieve results
-(void)alertView:(UIAlertView *)aView clickedButtonAtIndex:(NSInteger)anIndex {
    index = anIndex;
    CFRunLoopStop(currentLoop);
}

@end

@implementation ModalAlert
+(NSUInteger)queryWith:(NSString *)question title:(NSString *)title button1:(NSString *)button1 button2:(NSString *)button2 {
    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    //create Alert
    ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
    [alertView setMessage:question];
    [alertView show];
    
    //Wait for a response
    CFRunLoopRun();
    
    //Retrieve answer
    NSUInteger answer = madelegate.index;
    return answer;
    
}

//Ask a Yes-No question
+(BOOL)ask:(NSString *)question title:(NSString *)title{
    return ([ModalAlert queryWith:question title:title button1:@"No" button2:@"Yes"] == 1);
}

//Ask a Cancel-OK question
+(BOOL)confirm:(NSString *)statement title:(NSString *)title{
    return ([ModalAlert queryWith:statement title:title button1:@"Cancel" button2:@"OK"]);
}
@end