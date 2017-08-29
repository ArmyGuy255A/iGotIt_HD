//
//  CustomCellBackground.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCellBackground : UIView 

//Call this class in the willDisplayCell: tableView delegate method

//Usage
/* 
 
 
*/

@property (nonatomic, retain) UIColor *theBaseColor;
@property (nonatomic, retain) UIColor *theStartColor;
@property (nonatomic, retain) UIColor *theEndColor;



-(void)getStartColor:(UIColor *)baseColor;
-(void)getEndColor:(UIColor *)baseColor;

@end
