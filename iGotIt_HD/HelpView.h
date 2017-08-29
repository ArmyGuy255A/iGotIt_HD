//
//  HelpView.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionClass.h"

@interface HelpView : UIView

@property (nonatomic, retain) UIButton *btnDisableHelp;
@property (nonatomic, retain) UIButton *btnHideHelp;
@property (nonatomic, retain) UILabel *lblMain;
@property (strong, nonatomic) NSNumber *menuType;
//@property (assign) HelpMenus *asdf;


-(void)configureView;
-(void)configureButtons;
-(void)loadParentHelp;
-(void)loadChildHelp;
-(void)loadFavoriteHelp;
@end
