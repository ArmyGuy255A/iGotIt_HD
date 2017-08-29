//
//  FavoriteCell.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "FavoriteCell.h"
#import "CustomCellBackground.h"
#import <QuartzCore/QuartzCore.h>

@implementation FavoriteCell
#define MAINLABEL_TAG 10
#define SECONDLABEL_TAG 20
#define THIRDLABEL_TAG 30
#define FOURTHLABEL_TAG 40
#define BUTTON1_TAG 50
#define BUTTON2_TAG 60

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UILabel *mainLabel, *secondLabel, *thirdLabel;
    //*fourthLabel
    UIButton *button1, *button2;
        
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 200, 20)];
    [mainLabel setTag:MAINLABEL_TAG];
    [mainLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [mainLabel setTextAlignment:UITextAlignmentLeft];
    [mainLabel setTextColor:[UIColor blackColor]];
    [self.contentView addSubview:mainLabel];
    
    secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 26, 100, 15)];
    [secondLabel setTag:SECONDLABEL_TAG];
    [secondLabel setFont:[UIFont systemFontOfSize:12.0]];
    [secondLabel setTextAlignment:UITextAlignmentLeft];
    [secondLabel setTextColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:secondLabel];
    
    thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 26, 125, 15)];
    [thirdLabel setTag:THIRDLABEL_TAG];
    [thirdLabel setFont:[UIFont systemFontOfSize:12.0]];
    [thirdLabel setTextAlignment:UITextAlignmentLeft];
    [thirdLabel setTextColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:thirdLabel];
    /*
    fourthLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 26, 75, 15)];
    [fourthLabel setTag:FOURTHLABEL_TAG];
    [fourthLabel setFont:[UIFont systemFontOfSize:12.0]];
    [fourthLabel setTextAlignment:UITextAlignmentRight];
    [fourthLabel setTextColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:fourthLabel];
    */
    /////BUTTON SETUP/////////
    CGRect size = CGRectMake(251, 6, 60, 32);
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButtonStateNormal" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIEdgeInsets insets = UIEdgeInsetsMake(16, 10, 16, 10);
    button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setFrame:size];
    [button1 setTag:BUTTON1_TAG];
    [button1 setBackgroundColor:[UIColor clearColor]];
    [button1 setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButtonStateSelected" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    [button1 setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateSelected];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setShowsTouchWhenHighlighted:NO];
    [button1 setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.contentView addSubview:button1];
    
    //UIImage *theImage2 = [UIImage imageWithContentsOfFile:imagePath2];

    button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setFrame:size];
    [button2 setTag:BUTTON2_TAG];
    [button2 setBackgroundColor:[UIColor clearColor]];
    imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButton2StateNormal" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    [button2 setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButton2StateSelected" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    [button2 setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateSelected];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setShowsTouchWhenHighlighted:NO];
    [button2 setHidden:YES];
    [button2 setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.contentView addSubview:button2];
    
    /*
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:nil];
    longPressGesture.delegate = self;
    [button2 removeGestureRecognizer:longPressGesture];
     */
    //[button2 addGestureRecognizer:longPressGesture];
     
    /////END BUTTON SETUP/////
    
    [mainLabel setBackgroundColor:[UIColor clearColor]];
    [secondLabel setBackgroundColor:[UIColor clearColor]];
    [thirdLabel setBackgroundColor:[UIColor clearColor]];
    //[fourthLabel setBackgroundColor:[UIColor clearColor]];
       
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor whiteColor]];
    [bgView setTheEndColor:[UIColor lightGrayColor]];
    self.backgroundView = bgView;
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
