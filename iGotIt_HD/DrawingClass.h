//
//  DrawingClass.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawingClass : NSObject

CGPathRef NewPathWithRoundRect(CGRect rect, CGFloat cornerRadius);

@end
