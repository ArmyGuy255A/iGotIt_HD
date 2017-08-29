//
//  SettingsClass.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "SettingsClass.h"

@implementation SettingsClass

+(void)loadSettings{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //detect first app launch (firstLaunch should be 'nil') if true
    id firstLaunch = [defaults objectForKey:@"SHOW_HELP"];
    if (!firstLaunch) {
        [self setDefaultSettings];
        return;
    }
    
    //Help Menus
    BOOL showHelp = [self getShowHelp];
    [self setShowHelp:showHelp];
    ////////////////
}
+(void)setDefaultSettings{
    //First App Launch Default Settings Here!
    [self setShowHelp:YES];
    [self setThemeButtonBackgroundImage];
}
+(BOOL)getShowHelp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:@"SHOW_HELP"];
    return value;
}
+(void)setShowHelp:(BOOL)value{
    /* CAUTION */
    //Toggling this setting will also toggle all other help settings
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"SHOW_HELP"];
    
    [self setShowChildHelp:value];
    [self setShowFavoriteHelp:value];
    [self setShowParentHelp:value];
    
}
+(BOOL)getShowFavoriteHelp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:@"SHOW_FAVORITE_HELP"];
    return value;
}
+(void)setShowFavoriteHelp:(BOOL)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"SHOW_FAVORITE_HELP"];
}
+(BOOL)getShowParentHelp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:@"SHOW_PARENT_HELP"];
    return value;
}
+(void)setShowParentHelp:(BOOL)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"SHOW_PARENT_HELP"];
}
+(BOOL)getShowChildHelp{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [defaults boolForKey:@"SHOW_CHILD_HELP"];
    return value;
}
+(void)setShowChildHelp:(BOOL)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"SHOW_CHILD_HELP"];
}

+(void)setThemeButtonBackgroundImage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [NSString stringWithFormat:@"PURPLE"];
    [defaults setValue:value forKey:@"TB_BTN_BG_IMG"];
}

+(UIImage *)getThemeButtonBackgroundImage:(ThemeButtonState)state{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults valueForKey:@"TB_BTN_BG_IMG"];
    
    switch (state) {
        case kStateNormal:
            value = [NSString stringWithFormat:@"UITB_%@_NRM", value];
            break;
        case kStateSelected:
            value = [NSString stringWithFormat:@"UITB_%@_SEL", value];
            break;
        default:
            value = [NSString stringWithFormat:@"UITB_%@_NRM", value];
            break;
    }
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:value ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    return image;
}

+(NSString *)getThemeButtonBackgroundValue{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults valueForKey:@"TB_BTN_BG_IMG"];
    return value;
}

+(void)setThemeButtonTextColor:(UIButton *)button{
    NSString *imageColor = [self getThemeButtonBackgroundValue];
        
    if ([imageColor isEqualToString:@"GOLD"]){
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

+(UIImage *)getThemeFavoriteButtonImage{
    NSString *imageColor = [self getThemeButtonBackgroundValue];
    NSString *imageName = [NSString stringWithFormat:@"FAV_%@", imageColor];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
+(UIImage *)getThemeCheckBoxImage{
    NSString *imageColor = [self getThemeButtonBackgroundValue];
    NSString *imageName = [NSString stringWithFormat:@"CHK_%@", imageColor];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}
+(UIImage *)getThemeCheckBoxAllImage{
    NSString *imageColor = [self getThemeButtonBackgroundValue];
    NSString *imageName = [NSString stringWithFormat:@"CHK_ALL_%@", imageColor];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}



@end
