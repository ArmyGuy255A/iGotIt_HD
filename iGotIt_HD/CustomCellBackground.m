//
//  CustomCellBackground.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "CustomCellBackground.h"
#import "GradientFunction.h"

#define RGBA(r, g, b, a)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation CustomCellBackground

@synthesize theBaseColor;
@synthesize theStartColor;
@synthesize theEndColor;


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)getStartColor:(UIColor *)baseColor{
    //Lighter color on top

    const CGFloat *components = CGColorGetComponents(baseColor.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    CGFloat a = components[3];
    theStartColor = RGBA(r+25, g+25, b+25, a);
}
-(void)getEndColor:(UIColor *)baseColor{
    
    //Darker color on bottom
    const CGFloat *components = CGColorGetComponents(baseColor.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    CGFloat a = components[3];
    theEndColor = RGBA(r-25, g-25, b-25, a);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!theBaseColor) {
        theBaseColor = RGBA(235, 235, 235, 1);
    }
    //Set the start and end colors from the base color
    if (theStartColor == nil) {
        [self getStartColor:theBaseColor];
        [self getEndColor:theBaseColor];
    } else {
        //use the custom start and end colors
    }
    
    
    CGColorRef startColor = self.theStartColor.CGColor;
    CGColorRef endColor = self.theEndColor.CGColor;
    //Error control. Make the colors white if nothing was passed.
    
    if (startColor == nil) {
        startColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    }
    if (endColor == nil) {
        endColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    } 
    
    CGRect paperRect = self.bounds;
    
    //Draw the gradient from the GradientFunction class
    drawLinearGradient(context, paperRect, startColor, endColor);
    
    //Add a border to the background
    CGRect strokeRect = paperRect;
    strokeRect.size.height -= 1;
    strokeRect = rectFor1PxStroke(strokeRect);
    CGContextSetStrokeColorWithColor(context, theBaseColor.CGColor);
    //CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeRect(context, strokeRect);
    
    
    //Add a separator
    UIColor *separatorColor = RGBA(130, 130, 130, 1);
    CGColorRef sepColor = separatorColor.CGColor;
    CGPoint startPoint = CGPointMake(paperRect.origin.x, paperRect.origin.y + paperRect.size.height - 1);
    CGPoint endPoint = CGPointMake(paperRect.origin.x + paperRect.size.width - 1, paperRect.origin.y + paperRect.size.height - 1);
    draw1PxStroke(context, startPoint, endPoint, sepColor);
    
    
}


@end
