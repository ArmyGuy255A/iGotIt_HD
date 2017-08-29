//
//  SettingsClass.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kStateNormal,
    kStateSelected
} ThemeButtonState; 

@interface SettingsClass : NSObject

+(void)loadSettings;
+(void)setDefaultSettings;
+(BOOL)getShowHelp;
+(void)setShowHelp:(BOOL)value;
+(BOOL)getShowFavoriteHelp;
+(void)setShowFavoriteHelp:(BOOL)value;
+(BOOL)getShowParentHelp;
+(void)setShowParentHelp:(BOOL)value;
+(BOOL)getShowChildHelp;
+(void)setShowChildHelp:(BOOL)value;
+(void)setThemeButtonBackgroundImage;
+(UIImage *)getThemeButtonBackgroundImage:(ThemeButtonState)state;
+(NSString *)getThemeButtonBackgroundValue;
+(void)setThemeButtonTextColor:(UIButton *)button;
+(UIImage *)getThemeFavoriteButtonImage;
+(UIImage *)getThemeCheckBoxImage;
+(UIImage *)getThemeCheckBoxAllImage;



@end
