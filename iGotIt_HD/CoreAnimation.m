//
//  CoreAnimation.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/28/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "CoreAnimation.h"

@implementation CoreAnimation

+(CABasicAnimation *)opacityAnimation:(float)fromValue toValue:(float)toValue duration:(float)duration{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    [anim setDuration:duration];
    
    [anim setFromValue:[NSNumber numberWithFloat:fromValue]];
    [anim setToValue:[NSNumber numberWithFloat:toValue]];
    
    [anim setFillMode:kCAFillModeForwards];
    [anim setRemovedOnCompletion:NO];
    return anim;
}

+(CABasicAnimation *)positionAnimation:(CGPoint)fromValue toValue:(CGPoint)toValue duration:(float)duration{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    [anim setDuration:duration];
    [anim setFromValue:[NSValue valueWithCGPoint:fromValue]];
    [anim setToValue:[NSValue valueWithCGPoint:toValue]];
    [anim setFillMode:kCAFillModeForwards];
    [anim setRemovedOnCompletion:NO];
    return anim;
}

@end
