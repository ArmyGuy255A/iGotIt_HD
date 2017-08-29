//
//  UIColorRGBValueTransformer.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "UIColorRGBValueTransformer.h"

@implementation UIColorRGBValueTransformer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//Override the method that returns the class of objects that this transformer can convert
+(Class)transformedValueClass{
    return [NSData class];
}

//Indicate that our converter supports two-way conversions.
// Convert UIColor to NSData and reverse
+(BOOL)allowsReverseTransformation {
    return YES;
}

//Takes a UIColor, returns an NSData
-(id)transformedValue:(id)value{
    UIColor *color = value;
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    NSString *colorAsString = [NSString stringWithFormat:@"%f,%f,%f,%f", components[0], components[1], components[2], components[3]];
    return [colorAsString dataUsingEncoding:NSUTF8StringEncoding];
}

// Takes an NSData and returns a UIColor
-(id)reverseTransformedValue:(id)value{
    NSString *colorAsString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    NSArray *components = [colorAsString componentsSeparatedByString:@","];
    CGFloat r = [[components objectAtIndex:0] floatValue];
    CGFloat g = [[components objectAtIndex:1] floatValue];
    CGFloat b = [[components objectAtIndex:2] floatValue];
    CGFloat a = [[components objectAtIndex:3] floatValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
    
}
@end
