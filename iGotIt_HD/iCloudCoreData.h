//
//  iCloudCoreData.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 11/19/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iCloudCoreData : NSObject


+(BOOL)isEnabled;
+(NSDictionary *)persistentStoreOptions;
+(void)syncDatabase:(id)object;
@end
