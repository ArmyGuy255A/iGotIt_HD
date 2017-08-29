//
//  iGotIt_HDAppDelegate.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AppDelegate (iGotIt_HDAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface iGotIt_HDAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
@private
    NSManagedObjectModel *managedObjectModel__;
    NSManagedObjectContext *managedObjectContext__;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator__;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSString *)applicationDocumentsDirectory;
-(void)loadIPadInterface;
-(void)loadIPhoneInterface;
-(void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (nonatomic) UIDeviceOrientation oldOrientation;

@end


