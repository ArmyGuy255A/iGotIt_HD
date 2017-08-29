//
//  CoreAnimation.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/28/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreAnimation : NSObject

+(CABasicAnimation *)opacityAnimation:(float)fromValue toValue:(float)toValue duration:(float)duration;

+(CABasicAnimation *)positionAnimation:(CGPoint)fromValue toValue:(CGPoint)toValue duration:(float)duration;

@end
