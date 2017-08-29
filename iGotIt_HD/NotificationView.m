//
//  NotificationView.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//


#import "NotificationView.h"
#import "DrawingClass.h"
#import <QuartzCore/QuartzCore.h>

@implementation NotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setZPosition:100];
    }
    return self;
}

+ (id)notificationViewInView:(UIView *)aSuperview notificationMessage:(NSString *)notificationMessage withIndicator:(BOOL)withIndicator
{
    NotificationView *nView = [[NotificationView alloc] initWithFrame:[aSuperview bounds]];
	if (!nView)
	{
		return nil;
	}
	
	nView.opaque = NO;
	nView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[aSuperview addSubview:nView];
            
	const CGFloat DEFAULT_LABEL_WIDTH = 280.0;
	const CGFloat DEFAULT_LABEL_HEIGHT = 50.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
	
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
	messageLabel.text = notificationMessage;
	messageLabel.textColor = [UIColor whiteColor];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.textAlignment = UITextAlignmentCenter;
    [messageLabel setFont:[UIFont boldSystemFontOfSize:24.0]];
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
	[nView addSubview:messageLabel];
	
    if (withIndicator == YES) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [nView addSubview:activityIndicatorView];
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [activityIndicatorView startAnimating];
        
        CGFloat totalHeight = messageLabel.frame.size.height + activityIndicatorView.frame.size.height;
        labelFrame.origin.x = floor(0.5 * (nView.frame.size.width - DEFAULT_LABEL_WIDTH));
        labelFrame.origin.y = floor(0.5 * (nView.frame.size.height - totalHeight));
        messageLabel.frame = labelFrame;
        
        CGRect activityIndicatorRect = activityIndicatorView.frame;
        activityIndicatorRect.origin.x = 0.5 * (nView.frame.size.width - activityIndicatorRect.size.width);
        activityIndicatorRect.origin.y = messageLabel.frame.origin.y + messageLabel.frame.size.height;
        activityIndicatorView.frame = activityIndicatorRect;
    } else {
        //No activity indicator
        CGFloat totalHeight = messageLabel.frame.size.height;
        labelFrame.origin.x = floor(0.5 * (nView.frame.size.width - DEFAULT_LABEL_WIDTH));
        labelFrame.origin.y = floor(0.5 * (nView.frame.size.height - totalHeight));
        messageLabel.frame = labelFrame;
        
    }
    
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
    //Ensure the orientation of the message is the correct orientation.
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation]; 
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeRight:
            nView.transform = CGAffineTransformRotate(nView.transform, 90 * (M_PI/180));
            break;
        case UIInterfaceOrientationLandscapeLeft:
            nView.transform = CGAffineTransformRotate(nView.transform, 270 * (M_PI/180));
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            nView.transform = CGAffineTransformRotate(nView.transform, 180 * (M_PI/180));
            break;
        case UIInterfaceOrientationPortrait:
            nView.transform = CGAffineTransformRotate(nView.transform, 0 * (M_PI/180));
            
            break;
        default:
            break;
    }
    
	return nView;
}


- (void)removeView
{
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];
    
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

- (void)drawRect:(CGRect)rect
{
    
    rect.size.height -= 1;
    rect.size.width -= 1;
    CGFloat INSET_X;
    CGFloat INSET_Y;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        INSET_X = 250;
        INSET_Y = 425;
    } else {
        INSET_X = 25;
        INSET_Y = 125;
    }
    const CGFloat RECT_PAD_X = INSET_X;
    const CGFloat RECT_PAD_Y = INSET_Y;
    rect = CGRectInset(rect, RECT_PAD_X, RECT_PAD_Y);
    
    const CGFloat ROUND_RECT_CORNER_RADIUS = 25.0;
    CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //const CGFloat BACKGROUND_OPACITY = 1.0;
    const CGFloat BACKGROUND_OPACITY = 0.65;
    CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
    CGContextAddPath(context, roundRectPath);
    CGContextFillPath(context);
    
    const CGFloat STROKE_OPACITY = 0;
    CGContextSetRGBStrokeColor(context, 0, 0, 0, STROKE_OPACITY);
    CGContextAddPath(context, roundRectPath);
    CGContextStrokePath(context);
    
    CGPathRelease(roundRectPath);
}


@end
