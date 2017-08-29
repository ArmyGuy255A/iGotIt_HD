//
//  UIVerticalToolBar.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 11/18/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    zPatternBlack,
    zPatternWhite
}BackgroundPattern;

typedef enum {
    zBottomRight,
    zBottomLeft,
    zTopRight,
    zTopLeft
}StartLocation;

@interface UIVerticalToolBar : UIView

@property (nonatomic) BackgroundPattern backgroundPattern;
@property (nonatomic, retain) NSMutableArray *tabBarItems;

-(void)displayFrom:(StartLocation)startLocation ofView:(UIView *)parentView target:(id)target;
@end
