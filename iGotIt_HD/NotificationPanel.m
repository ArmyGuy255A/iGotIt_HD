//
//  NotificationPanel.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/30/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "NotificationPanel.h"
#import "NPCloseButton.h"
#import "DrawingClass.h"
#import <QuartzCore/QuartzCore.h>

@implementation NotificationPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)notificationViewInView:(UIView *)aSuperview title:(NSString *)title message:(NSString *)message withView:(UIView *)view
{
    //Create a blocker
    UIButton *theBlocker = [[UIButton alloc] initWithFrame:aSuperview.window.frame];
    
    [theBlocker setTag:THE_BLOCKER];
    [theBlocker setBackgroundColor:[UIColor clearColor]];
    [theBlocker addTarget:nil action:@selector(removePanel) forControlEvents:UIControlEventTouchUpInside];
    [theBlocker setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [aSuperview addSubview:theBlocker];
    //End Blocker
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation    ;
    CGRect newRect;

    if (UIInterfaceOrientationIsLandscape(orientation)) {
        newRect = [aSuperview bounds];
        newRect.size.width = aSuperview.bounds.size.height;
        newRect.size.height = aSuperview.bounds.size.width;
    } else {
        newRect = [aSuperview bounds];
    }
    const CGFloat ALPHA_VALUE = 1.00;
    const CGFloat OUTER_STROKE_WIDTH = 2.0;
    const CGFloat RATIO = 0.1;
    const CGFloat RECT_PAD_X = newRect.size.width * RATIO;
    const CGFloat RECT_PAD_Y = newRect.size.height * (RATIO * 2.5);
    newRect = CGRectInset(newRect, RECT_PAD_X, RECT_PAD_Y);
    NotificationPanel *nView = [[NotificationPanel alloc] initWithFrame:newRect];
	if (!nView)
	{
		return nil;
	}
    
	
	[nView setOpaque:NO];
    [nView setTag:NOTIFICATION_PANEL];
    [nView setBackgroundColor:[UIColor clearColor]];
    [nView setClearsContextBeforeDrawing:YES];
	//[nView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [nView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
	[aSuperview addSubview:nView];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [nView.layer setPosition:CGPointMake(aSuperview.frame.size.height / 2, aSuperview.frame.size.width / 2)];
    }
    
    
    //Close Button
    const CGFloat DEFAULT_BUTTON_SIZE = 45;
    CGRect buttonRect = CGRectMake(-12, -12, DEFAULT_BUTTON_SIZE, DEFAULT_BUTTON_SIZE);
    NPCloseButton *closeButton = [[NPCloseButton alloc] initWithFrame:buttonRect];
    [closeButton setShowsTouchWhenHighlighted:YES];
    [closeButton addTarget:nil action:@selector(removePanel) forControlEvents:UIControlEventTouchUpInside];
    [nView addSubview:closeButton];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    
    //Title
    const CGFloat DEFAULT_LABEL_WIDTH = nView.frame.size.width;
	const CGFloat DEFAULT_LABEL_HEIGHT = 25.0;
	CGRect labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH - OUTER_STROKE_WIDTH * 2, DEFAULT_LABEL_HEIGHT);
    labelFrame.origin.y += OUTER_STROKE_WIDTH;
    labelFrame.origin.x += OUTER_STROKE_WIDTH;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [titleLabel setAlpha:ALPHA_VALUE];
    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:DEFAULT_LABEL_HEIGHT]];
    [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [nView addSubview:titleLabel];
    
    
    //Message
    const CGFloat ROUND_RECT_CORNER_RADIUS = 25.0;
    if (view) {
        labelFrame = CGRectMake(0, 0, DEFAULT_LABEL_WIDTH - OUTER_STROKE_WIDTH * 2, DEFAULT_LABEL_HEIGHT);
        labelFrame.origin.x += OUTER_STROKE_WIDTH;
        labelFrame.size.height += labelFrame.size.height / 2;
    } else {
        labelFrame = CGRectMake(0,0, DEFAULT_LABEL_WIDTH - OUTER_STROKE_WIDTH * 2, CGRectGetHeight(newRect) - DEFAULT_LABEL_HEIGHT - 25 );
    }
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [messageLabel setAlpha:ALPHA_VALUE];
	[messageLabel setText:message];
    //[messageLabel setText:@"Hello World - This Is a Test of my Custom Notification Panel That will eventually rule the world. I only want to allow 3 lines."];
	[messageLabel setTextColor:[UIColor whiteColor]];
	[messageLabel setBackgroundColor:[UIColor clearColor]];
	[messageLabel setTextAlignment:UITextAlignmentCenter];
    [messageLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [messageLabel setNumberOfLines:0];
    [messageLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [nView addSubview:messageLabel];
    CGPoint messageCenter = CGPointMake(titleLabel.center.x, (titleLabel.center.y + titleLabel.frame.size.height / 2)  + labelFrame.size.height / 2);
    [messageLabel.layer setPosition:messageCenter];
    labelFrame.size.height -= labelFrame.size.height / 2;
    
    
    //SubView
    
        /*
    UIView *dumbView = [[UIView alloc] initWithFrame:subViewRect];
    [dumbView setBackgroundColor:[UIColor redColor]];
    [dumbView setAlpha:ALPHA_VALUE];
    [nView addSubview:dumbView];
    */ 
    if (view) {
        CGRect subViewRect = CGRectMake(OUTER_STROKE_WIDTH + (ROUND_RECT_CORNER_RADIUS / 2), messageLabel.center.y + messageLabel.frame.size.height / 2, DEFAULT_LABEL_WIDTH - (OUTER_STROKE_WIDTH * 2 + ROUND_RECT_CORNER_RADIUS), (nView.frame.size.height - (OUTER_STROKE_WIDTH + ROUND_RECT_CORNER_RADIUS / 2)) - (messageLabel.center.y + messageLabel.frame.size.height / 2));
        
        UIView *viewContainer = [[UIView alloc] initWithFrame:subViewRect];
        [viewContainer setBackgroundColor:[UIColor clearColor]];
        [viewContainer setAutoresizesSubviews:YES];
        [viewContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [nView addSubview:viewContainer];
        [viewContainer addSubview:view];
        [view setCenter:CGPointMake(CGRectGetWidth(subViewRect)/2, CGRectGetHeight(subViewRect)/2)];
        /*
        UIView *shit = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        [shit setBackgroundColor:[UIColor purpleColor]];
        [viewContainer addSubview:shit];
        
        [shit setCenter:CGPointMake(CGRectGetWidth(subViewRect)/2, CGRectGetHeight(subViewRect)/2)];
        CGPoint center = shit.center;
         */
    } 
	
    
    
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
	
    //Ensure the orientation of the message is the correct orientation.
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation]; 
    
    if ([[aSuperview class].description isEqualToString:@"UIWindow"]) {
        
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
    }
    
	return nView;
}

- (void)removePanel
{
    
	UIView *aSuperview = [self superview];
    UIButton *theBlocker = (UIButton *)[aSuperview viewWithTag:THE_BLOCKER];
    [theBlocker removeFromSuperview];
    [super removeFromSuperview];
    
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat HEIGHT_PAD = 2;
    const CGFloat WIDTH_PAD = 2;
    rect.size.height -= HEIGHT_PAD;
    rect.size.width -= WIDTH_PAD;
    rect.origin.x += HEIGHT_PAD / 2;
    rect.origin.y += WIDTH_PAD / 2;
    
    const CGFloat ROUND_RECT_CORNER_RADIUS = 25.0;
    CGPathRef roundRectPath = NewPathWithRoundRect(rect, ROUND_RECT_CORNER_RADIUS);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //stroke the background
    //const CGFloat BACKGROUND_OPACITY = 1;
    //CGContextSetGrayFillColor(context, .75, BACKGROUND_OPACITY);
    CGContextAddPath(context, roundRectPath);
    CGContextClip(context);
    //CGContextFillPath(context);
    //stroke gradient background
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    struct CGColor *lightGrayColor = [[UIColor lightGrayColor] CGColor];
    struct CGColor *darkGrayColor = [[UIColor darkGrayColor] CGColor];
    CGFloat locations[] = {0,.15,1};
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)lightGrayColor,(__bridge id)darkGrayColor, (__bridge id)darkGrayColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetWidth(rect) / 2, 0), CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect)), 0);

    //stroke the border
    const CGFloat STROKE_OPACITY = 1;
    CGContextSetRGBStrokeColor(context, 0, 0, 0, STROKE_OPACITY);
    CGContextSetLineWidth(context, 4.0);
    CGContextAddPath(context, roundRectPath);
    CGContextStrokePath(context);
    
    
    
}


@end
