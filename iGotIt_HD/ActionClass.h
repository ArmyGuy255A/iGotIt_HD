//
//  ActionClass.h
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NotificationView.h"
#import "HelpView.h"
#import "Parent.h"
#import "Child.h"

typedef enum {
    kFavoriteHelpMenu,
    kParentHelpMenu,
    kChildHelpMenu   
} HelpMenus; 

@interface ActionClass : NSObject
{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark - Managed Object Modification
+(void)loadDefaultDataModel:(NSManagedObjectContext *)moc;
+(Parent *)createParent:(NSString *)title managedObjectContext:(NSManagedObjectContext *)moc;
+(Child *)createChildItem:(NSString *)title parentManagedObject:(NSManagedObject *)pmo;
+(NSManagedObject *)cloneManagedObject:(NSManagedObject *)managedObject;
+(NSNumber *)countDatabaseWithContext:(NSManagedObjectContext *)moc;
+(NSNumber *)countObjectsInObject:(NSManagedObject *)mo;
+(Child *)convertParentToChild:(Parent *)managedObject;
+(Parent *)convertChildToParent:(Child *)managedObject; 
+(void)validateOrderForSection:(NSIndexPath *)indexPath fetchedResultsController:(NSFetchedResultsController *)frc;
+(BOOL)childrenItemsChecked:(NSManagedObject *)parentManagedObject includeChildren:(BOOL)includeChildren;
+(void)toggleChildItemsChecked:(NSManagedObject *)parentManagedObject toggle:(BOOL)toggle includeChildren:(BOOL)includeChildren;
+(void)validateChildrenRelationship:(NSManagedObject *)managedObject;
#pragma mark - Core Data Stack
+(NSManagedObjectContext *)managedObjContext;
+(NSManagedObjectModel *)managedObjModel;
+(void)saveContext:(NSManagedObjectContext *)context exclusive:(BOOL)exclusive;
+(void)saveContext:(NSManagedObjectContext *)context;

+(void)showCoreDataError;
+(void)undo:(NSManagedObjectContext *)context;
+(void)redo:(NSManagedObjectContext *)context;
-(NSURL *)applicationDocumentsDirectory;

#pragma mark - Misc Methods
+(CGRect)rectTopRightCorner:(UIView *)sourceView;
+(void)disableAllTouches:(float)timeInterval;
+(CGSize)getViewDimensions:(UIView *)view;
+(UIView *)createColorGrid:(id)target action:(SEL)action delegate:(id)delegate;
#pragma mark - Settings Methods
+(void)showHelpMenu:(HelpMenus)menuType;
+(void)hideHelpMenu:(BOOL)animated menuType:(HelpMenus)menuType;
#pragma mark - iCloud Methods



@end
