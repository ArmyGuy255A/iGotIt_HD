//
//  NPCloseButton.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 11/1/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "NPCloseButton.h"
#import "NotificationPanel.h"

@implementation NPCloseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    const CGFloat DEFAULT_BUTTON_IMAGE_SIZE = 25;
    float dx = (rect.size.width - DEFAULT_BUTTON_IMAGE_SIZE) / 2;
    float dy = (rect.size.height - DEFAULT_BUTTON_IMAGE_SIZE) / 2;
    CGRect circleRect = CGRectInset(rect, dx, dy);
    //CGPoint circleRectCenter = CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
    CGPoint circleRectCenter = CGPointMake(CGRectGetMidX(circleRect), CGRectGetMidY(circleRect));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw Circle Outline
    const CGFloat STROKE_OPACITY = 1;
    const CGFloat STROKE_WIDTH = 2.0;
    CGContextSetRGBStrokeColor(context, 0, 0, 0, STROKE_OPACITY);
    CGContextSetLineWidth(context, STROKE_WIDTH);
    CGContextStrokeEllipseInRect(context, circleRect);
    CGContextStrokePath(context);
    //Draw Gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    struct CGColor *red = [[UIColor redColor] CGColor];
    struct CGColor *white = [[UIColor blackColor] CGColor];
    //struct CGColor *lightGray = [[UIColor lightGrayColor] CGColor];
    CGFloat locations[] = {0.9,1};
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)red, (__bridge id)white, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawRadialGradient(context, gradient, circleRectCenter, 0, circleRectCenter, (CGRectGetHeight(circleRect) - STROKE_WIDTH) / 2, 0);
    
    //Draw X
    CGPoint topMiddle = CGPointMake((circleRect.size.width / 2) + circleRect.origin.x, circleRect.origin.y);
    CGPoint leftMiddle = CGPointMake(circleRect.origin.x, (circleRect.size.height / 2) + circleRect.origin.y);
    CGPoint rightMiddle = CGPointMake(circleRect.size.width + circleRect.origin.x,(circleRect.size.height / 2) + circleRect.origin.y);
    CGPoint bottomMiddle  = CGPointMake((circleRect.size.width / 2) + circleRect.origin.x, circleRect.size.height + circleRect.origin.y);
    CGPoint quad2 = CGPointMake((topMiddle.x + leftMiddle.x) / 2, (topMiddle.y + leftMiddle.y)/2); 
    CGPoint quad1 = CGPointMake((topMiddle.x + rightMiddle.x)/2, (topMiddle.y + rightMiddle.y)/2);
    CGPoint quad4 = CGPointMake((rightMiddle.x + bottomMiddle.x)/2, (rightMiddle.y + bottomMiddle.y)/2);
    CGPoint quad3 = CGPointMake((bottomMiddle.x + leftMiddle.x)/2, (bottomMiddle.y + leftMiddle.y)/2);
    CGMutablePathRef xPath = CGPathCreateMutable();
    CGPathMoveToPoint(xPath, nil, quad2.x, quad2.y);
    CGPathAddLineToPoint(xPath, nil, quad4.x, quad4.y);
    CGPathMoveToPoint(xPath, nil, quad1.x, quad1.y);
    CGPathAddLineToPoint(xPath, nil, quad3.x, quad3.y);
    CGContextAddPath(context, xPath);
    CGContextStrokePath(context);
    
}


@end
