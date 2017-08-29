//
//  UIVerticalTabBar.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 11/18/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "UIVerticalToolBar.h"

@implementation UIVerticalToolBar
@synthesize backgroundPattern = _backgroundPattern;
@synthesize tabBarItems = _tabBarItems;

- (id)initWithFrame:(CGRect)frame
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    float width = 40;
    float height = 300;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        width = width * 2;
        height = height / 2; 
    } 
    
    frame = CGRectMake(0, 0, width, height);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.layer setZPosition:100];
    }
    
    [self setBackgroundColor:[UIColor greenColor]];
    
    return self;
}

-(void)displayFrom:(StartLocation)startLocation ofView:(UIView *)parentView target:(id)target{
    
    [parentView addSubview:self];
    /*
    CGRect parentViewFrame = parentView.frame;
    CGRect parentViewLayerFrame = parentView.layer.frame;
    CGPoint parentViewLayerPosition = parentView.layer.position;
    CGPoint parentViewCenter = parentView.center;
    */
    [self.layer setPosition:CGPointMake(parentView.window.layer.position.x / 2, parentView.layer.position.y)];
    
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //draw a box at the top of the
}

#pragma mark - 

-(NSMutableArray *)tabBarItems {
    if (_tabBarItems) {
        return _tabBarItems;
    }
    
    _tabBarItems = self.tabBarItems;
    return _tabBarItems;
}

-(BackgroundPattern)backgroundPattern {
    if (_backgroundPattern) {
        return _backgroundPattern;
    }
    //default color is the white pattern
    if (!self.backgroundPattern) {
        self.backgroundPattern = zPatternWhite;
        _backgroundPattern = self.backgroundPattern;
        return _backgroundPattern;
    }
    
    return _backgroundPattern;
}

@end
