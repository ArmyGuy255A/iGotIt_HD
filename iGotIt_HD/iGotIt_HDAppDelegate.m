//
//  iGotIt_HDAppDelegate.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "iGotIt_HDAppDelegate.h"

#import "MasterViewController.h"

#import "DetailTableViewController.h"

#import "IPhoneParentTableViewController.h"

#import "IPhoneChildTableViewController.h"

#import "IPhoneFavoriteTableViewController.h"

#import "ActionClass.h"

#import "SettingsClass.h"


@implementation iGotIt_HDAppDelegate

@synthesize window;
@synthesize splitViewController = _splitViewController;
@synthesize oldOrientation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Capture the current managedObjectContext
    //managedObjectContext__ = [self managedObjectContext];
    
    //Load Application Settings
    [SettingsClass loadSettings];
    
    // Detect orientation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConfigMenu:) name:@"Shake" object:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self loadIPadInterface];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self loadIPhoneInterface];
    }
    
    //Load the custom data model if none exists.
    /*
    NSLog(@"Context: %@",self.managedObjectContext);
    NSLog(@"PS Coord : %@",self.managedObjectContext.persistentStoreCoordinator);
    NSLog(@"MOM : %@", self.managedObjectContext.persistentStoreCoordinator.managedObjectModel);
    NSLog(@"Entities : %@",[[self.managedObjectContext.persistentStoreCoordinator.managedObjectModel entities] valueForKey:@"name"]); 
     */
    /*
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[entity name]];
    NSArray *items = [moc executeFetchRequest:request error:nil];
    if ([items count] == 0) {
        [ActionClass loadDefaultDataModel:moc];
    }
    ////////////////////////////
    */
    [self.window makeKeyAndVisible];
    return YES;
    

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [ActionClass saveContext:managedObjectContext__ exclusive:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [ActionClass saveContext:managedObjectContext__ exclusive:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [ActionClass saveContext:managedObjectContext__ exclusive:YES];
}

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [ActionClass saveContext:managedObjectContext];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext__ != nil)
    {
        return managedObjectContext__;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
         
        [moc performBlockAndWait:^{
        [moc setPersistentStoreCoordinator:coordinator];
        //[moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
       }];
        
        //Add undo support
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        [moc setUndoManager:undoManager];
        
        managedObjectContext__ = moc;
        
    }
    
    return managedObjectContext__;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel__ != nil)
    {
        return managedObjectModel__;
    }
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iGotIt_HD" withExtension:@"momd"];
    //managedObjectModel__ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    managedObjectModel__ = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel__;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator__ != nil)
    {
        return persistentStoreCoordinator__;
    }
    
    persistentStoreCoordinator__ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSPersistentStoreCoordinator *psc = persistentStoreCoordinator__;
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"iGotIt_HD.sqlite"];
    
    // do this asynchronously since if this is the first time this particular device is syncing with preexisting iCloud content it may take a long long time to download
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSURL *storeURL = [NSURL fileURLWithPath:storePath];
        // this needs to match the entitlements and provisioning profile
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"iGotItv1.07"];
        cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
        
        //Used for debugging only!!
        //[fileManager removeItemAtURL:cloudURL error:nil];
        
        
        //  The API to turn on Core Data iCloud support here.
        NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@"appeid.iGotIt", NSPersistentStoreUbiquitousContentNameKey, cloudURL, NSPersistentStoreUbiquitousContentURLKey, [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,nil];
        
        /*
        //iCloud Loading
        BOOL enabled = [iCloudCoreData isEnabled];
        NSDictionary *iCloudOptions;
        if (enabled) {
            //proceed with iCloud loading
            NSLog(@"iCloud Enabled");
            iCloudOptions = [[iCloudCoreData persistentStoreOptions] mutableCopy];
        } else {
            NSLog(@"iCloud Disabled");
        }
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iGotIt_HD.sqlite"];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        //add the iCloud options to the options dictionary
        if (iCloudOptions) {
            [options addEntriesFromDictionary:iCloudOptions];
        }
        */
        [psc lock];
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            [ActionClass showCoreDataError];
        }    
        [psc unlock];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"asynchronously added persistent store!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFetchedResults" object:self userInfo:nil];
        });
        
    });
    return persistentStoreCoordinator__;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma QuartzCore Animation Delegate Methods
-(void)animationDidStart:(CAAnimation *)anim {
    
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
   
}

#pragma mark - Notification Center Methods
#pragma mark - Gesture Recognizers

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([event type] == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Shake" object:nil];
    }
    
}
-(void)showConfigMenu:(NSNotification *)notification {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [button addTarget:[iCloudCoreData class] action:@selector(syncDatabase:) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor greenColor]];
    [button setBackgroundColor:[UIColor clearColor]];
    UIImage *bgImage = [SettingsClass getThemeButtonBackgroundImage:kStateNormal];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 10, 15, 10);
    
    [button setBackgroundImage:[bgImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    bgImage = [SettingsClass getThemeButtonBackgroundImage:kStateSelected];
    [button setBackgroundImage:[bgImage resizableImageWithCapInsets:insets] forState:UIControlStateSelected];
    [button setTitle:@"Sync" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [NotificationPanel notificationViewInView:window.rootViewController.view title:@"iCloud Sync" message:@"'Sync' only needs to be performed if your lists are not synchronized with your other devices." withView:button];
}

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc {
    [moc mergeChangesFromContextDidSaveNotification:note]; 
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {

    NSManagedObjectContext *moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}
-(void)orientationChanged{
    
    //NSLog(@"orientation detected");
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    BOOL isPortrait = UIDeviceOrientationIsPortrait(orientation);
    BOOL isLandscape = UIDeviceOrientationIsLandscape(orientation);
    if (!isPortrait && !isLandscape) {
        //Value is not portrait or landscape. Abort
        return;
    }
    //set the oldOrientation if one doesn't exist
    if (!oldOrientation) {
        oldOrientation = orientation;
    }
    //determine if oldOrientation is the same as the new orientation
    if ((UIDeviceOrientationIsLandscape(orientation) && UIDeviceOrientationIsLandscape(oldOrientation)) || (UIDeviceOrientationIsPortrait(orientation) && UIDeviceOrientationIsPortrait(oldOrientation))) {
        //orientation is the same, abort
        //NSLog(@"Same Orientation");
        return;
    }
    
    [ActionClass hideHelpMenu:NO menuType:kParentHelpMenu];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            //NSLog(@"Changed Orientation: Landscape Left");
        } else {
            //NSLog(@"Changed Orientation: Landscape Right");
        }
    } else if (UIDeviceOrientationIsPortrait(orientation)){
        if (orientation == UIDeviceOrientationPortrait) {
            //NSLog(@"Changed Orientation: Portrait");
        } else {
            //NSLog(@"Changed Orientation: Portrait Upside Down");
        }
    } 
    
    oldOrientation = orientation;
}

-(void)loadIPadInterface {
    
    
    //Setup the MasterViewController and navigationController
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [masterNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [masterViewController setManagedObjectContext:self.managedObjectContext];
    ////////////////////////////
    
    
    //Setup the DetailTableViewController and navigationController
    DetailTableViewController *detailTableViewController = [[DetailTableViewController alloc] initWithNibName:@"DetailTableViewController" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailTableViewController];
    [detailNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    [detailTableViewController setManagedObjectContext:self.managedObjectContext];
    ////////////////////////////
    
    
    
    //Setup the splitViewController
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailTableViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
    masterViewController.detailTableViewController = detailTableViewController;
    
    ////////////////////////////
    
    /*
    //Load the custom data model if none exists.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:managedObjectContext__];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[entity name]];
    NSArray *items = [managedObjectContext__ executeFetchRequest:request error:nil];
    if ([items count] == 0) {
        [ActionClass loadDefaultDataModel:managedObjectContext__];
    }
    ////////////////////////////
     */
    
    //Display the splitViewController
    self.window.rootViewController = self.splitViewController;
    
    ////////////////////////////
}

-(void)loadIPhoneInterface {
    IPhoneFavoriteTableViewController *ipFVC = [[IPhoneFavoriteTableViewController alloc] init];
    UINavigationController *favNavCon = [[UINavigationController alloc] initWithRootViewController:ipFVC];
    [favNavCon.toolbar setBarStyle:UIBarStyleBlack];
    [ipFVC setTitle:@"Favorites"];
    [ipFVC setManagedObjectContext:self.managedObjectContext];
    IPhoneParentTableViewController *ipTVC = [[IPhoneParentTableViewController alloc] init];
    UINavigationController *parNavCon = [[UINavigationController alloc]  initWithRootViewController:ipTVC];
    [parNavCon.toolbar setBarStyle:UIBarStyleBlack];
    [ipTVC setTitle:@"iGot It"];
    [ipTVC setManagedObjectContext:self.managedObjectContext];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setDelegate:self];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:favNavCon, parNavCon, nil];
    [tabBarController setViewControllers:viewControllers];
    [tabBarController setSelectedIndex:1];
   
    self.window.rootViewController = tabBarController;
}

#pragma mark - TabBarController Delegate Protocol
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    
}

- (void)tabBarController:(UITabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    
}

#pragma mark -

@end
