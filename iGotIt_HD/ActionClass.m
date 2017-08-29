//
//  ActionClass.m
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "ActionClass.h"
#import "iGotIt_HDAppDelegate.h"
#import <CoreData/CoreData.h>
#import "NotificationView.h"
#import "HelpView.h"
#import "Parent.h"
#import "Child.h"

@implementation ActionClass
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#define RGBA(r, g, b, a)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#pragma mark - Managed Object Modification

+(void)loadDefaultDataModel:(NSManagedObjectContext *)moc{
    
    [self createParent:@"Default Item" managedObjectContext:moc];
}
   

+(Parent *)createParent:(NSString *)title managedObjectContext:(NSManagedObjectContext *)moc{
    
    //Create a new item with title = title
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:moc];
    Parent *newParent = [NSEntityDescription insertNewObjectForEntityForName:[itemEntity name] inManagedObjectContext:moc];
    
    //NSLog(@"ADD PARENT == MOC: %@", [moc description]);

    //Load default values for the Item
    [newParent setID:@"0x1234"];
    if (newParent.permanentID == nil) {
        //save the context to get a permanant ID
        [self saveContext:moc];
        //set the permanant ID
        NSString *permID = [[[newParent objectID] URIRepresentation] description];
        permID = [permID lastPathComponent];
        [newParent setPermanentID:permID];
    }
    [newParent setTitle:title];
    [newParent setCatColor:RGBA(235, 235, 235, 1)];
    [newParent setDateCreated:[NSDate date]];
    //Setup a time interval in seconds
    NSTimeInterval time24hr = 24 * 60 * 60;
    NSTimeInterval time3hr = 3 * 60 * 60;
    [newParent setDateStart:[NSDate dateWithTimeInterval:time3hr sinceDate:newParent.dateCreated]];
    [newParent setDateEnd:[NSDate dateWithTimeInterval:time24hr sinceDate:newParent.dateStart]];
    [self saveContext:moc];
    return newParent;
}

+(Child *)createChildItem:(NSString *)title parentManagedObject:(NSManagedObject *)pmo{
    //NSLog(@"<<<<< ACTION CLASS >>>>> ADD Child START");
    
    NSManagedObjectContext *context = [pmo managedObjectContext];
    
    //Create a new item with title = variable title
    
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Child" inManagedObjectContext:context];
    Child *newChildItem = [NSEntityDescription insertNewObjectForEntityForName:[itemEntity name] inManagedObjectContext:context];
    
    //Set the parent ID
    [newChildItem setParentID:[pmo valueForKey:@"permanentID"]];
    
    if (newChildItem.permanentID == nil) {
        //save the context to get a permanant ID
        [self saveContext:[newChildItem managedObjectContext]];
        //set the permanant ID
        NSString *permID = [[[newChildItem objectID] URIRepresentation] description];
        permID = [permID lastPathComponent];
        [newChildItem setPermanentID:permID];
    }
    
    //Load default values for the Item
    [newChildItem setTitle:title];
    [newChildItem setCatColor:RGBA(235, 235, 235, 1)];
    [newChildItem setDateCreated:[NSDate date]];
    //Setup a time interval in seconds
    NSTimeInterval time24hr = 24 * 60 * 60;
    NSTimeInterval time3hr = 3 * 60 * 60;
    [newChildItem setDateStart:[NSDate dateWithTimeInterval:time3hr sinceDate:newChildItem.dateCreated]];
    [newChildItem setDateEnd:[NSDate dateWithTimeInterval:time24hr sinceDate:newChildItem.dateStart]];
    
    //Add the new subitem (Old Way)
    
    NSMutableSet *childrenSet = [pmo mutableSetValueForKey:@"children"];
    [childrenSet addObject:newChildItem];
    
    //Save and continue
    [self saveContext:[newChildItem managedObjectContext]];
    return newChildItem;
    //NSLog(@"<<<<< ACTION CLASS >>>>> ADD Child DONE");
    
}

+(NSManagedObject *)cloneManagedObject:(NSManagedObject *)managedObject{
    NSString *entityName = [[managedObject entity] name];
    NSManagedObjectContext *context = [managedObject managedObjectContext];
    
    //create a new managedObject
    NSManagedObject *clone = [NSEntityDescription
                               insertNewObjectForEntityForName:entityName
                               inManagedObjectContext:context];
    
    //Save and get permanentID
    //[self saveContext:context];
    
    NSString *permID = [[[clone objectID] URIRepresentation] description];
    permID = [permID lastPathComponent];
    
    //loop through all attributes and assign then to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:entityName
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        //only clone certain attributes. the following should be set to defaults.
        if ([attr isEqualToString:@"checked"]) {
            [clone setValue:[NSNumber numberWithBool:NO] forKey:attr];
        } else if ([attr isEqualToString:@"ID"]) {
            [clone setValue:@"" forKey:attr];
        } else if ([attr isEqualToString:@"permanentID"]) {
            [clone setValue:permID forKey:attr];
        } else if ([attr isEqualToString:@"favorite"]) {
            [clone setValue:[NSNumber numberWithBool:NO] forKey:attr];
        } else {
            [clone setValue:[managedObject valueForKey:attr] forKey:attr];
        }
    }
    
    //Now duplicate all relationships in the model.
   
    NSDictionary *relationships = [[NSEntityDescription
                                    entityForName:entityName
                                    inManagedObjectContext:context] relationshipsByName];
    
    for (NSRelationshipDescription *rel in relationships){
        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
        //get a set of all objects in the relationship
        if ([keyName isEqualToString:@"children"]) {
            NSMutableSet *sourceSet = [managedObject mutableSetValueForKey:keyName];
            NSMutableSet *clonedSet = [clone mutableSetValueForKey:keyName];
            NSEnumerator *e = [sourceSet objectEnumerator];
            NSManagedObject *relatedObject;
            while (relatedObject = [e nextObject]){
                //Clone it, and add clone to set
                NSManagedObject *clonedRelatedObject = [ActionClass cloneManagedObject:relatedObject];
                [clonedRelatedObject setValue:permID forKey:@"parentID"];
                [clonedSet addObject:clonedRelatedObject];
            }
        }
        
        
    }
    
    //save a return the new object.
    [self saveContext:context];
    return clone;
}

+(NSNumber *)countDatabaseWithContext:(NSManagedObjectContext *)moc{
    NSFetchRequest *fetch1 = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    [fetch1 setEntity:entity];
    [fetch1 setIncludesSubentities:YES];
    
    NSError *error;
    int count = 0;
    count = [moc countForFetchRequest:fetch1 error:&error];
    return [NSNumber numberWithInt:count];
    
}

+(NSNumber *)countObjectsInObject:(NSManagedObject *)mo {
    int count = 0;
    NSString *entityName = [[mo entity] name];
    NSManagedObjectContext *moc = [mo managedObjectContext];
    NSDictionary *relationships = [[NSEntityDescription entityForName:entityName inManagedObjectContext:moc] relationshipsByName];
    
    for (NSRelationshipDescription *rel in relationships){
        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
        //get a set of all objects in the relationship
        //only use one though...
        if ([keyName isEqualToString:@"children"]) {
            NSMutableSet *sourceSet = [mo mutableSetValueForKey:keyName];
            count += sourceSet.count;
            //sort through all objects
            NSEnumerator *e = [sourceSet objectEnumerator];
            NSManagedObject *relatedObject;
            while (relatedObject = [e nextObject]){
                //Perform another count of the object
                NSNumber *x = [ActionClass countObjectsInObject:relatedObject];
                count += [x intValue];
            }
        }
    }
    //Continue returning the numbers and adding to the function.
    return [NSNumber numberWithInt:count];
}

+(Child *)convertParentToChild:(Parent *)managedObject{
    NSManagedObjectContext *context = [managedObject managedObjectContext];
    
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Child" inManagedObjectContext:context];
    
    Child *cmo = [NSEntityDescription insertNewObjectForEntityForName:[itemEntity name] inManagedObjectContext:context];
    
    //Save and set permanentID
    [self saveContext:context];
    
    NSString *permID = [[[cmo objectID] URIRepresentation] description];
    permID = [permID lastPathComponent];
    
    //loop through all attributes and assign them to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:[itemEntity name]
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        if ([attr isEqualToString:@"parentID"]) {
            //no parent ID. This is handled when the object is actually added to the Parent.
        } else if ([attr isEqualToString:@"permanentID"]) {
            [cmo setValue:permID forKey:attr];
        } else {
            [cmo setValue:[managedObject valueForKey:attr] forKey:attr];
        }
    }
   
    //Now move the children set from the parent to the child.
    
    NSDictionary *relationships = [[NSEntityDescription
                                    entityForName:[itemEntity name]
                                    inManagedObjectContext:context] relationshipsByName];
    
    for (NSRelationshipDescription *rel in relationships){
        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
        //get a set of all objects in the relationship
        if ([keyName isEqualToString:@"children"]) {
            NSMutableSet *sourceSet = [managedObject mutableSetValueForKey:keyName];
            [cmo setChildren:sourceSet];
            [managedObject removeChildren:sourceSet];
        }
    }
    
    //save a return the new object.
    [self saveContext:context];
    return cmo;

}

+(Parent *)convertChildToParent:(Child *)managedObject{
    NSManagedObjectContext *context = [managedObject managedObjectContext];
    
    NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:context];
    
    Parent *pmo = [NSEntityDescription insertNewObjectForEntityForName:[itemEntity name] inManagedObjectContext:context];
    
    //Save and set permanentID
    [self saveContext:context];
    
    NSString *permID = [[[pmo objectID] URIRepresentation] description];
    permID = [permID lastPathComponent];
    
    //loop through all attributes and assign them to the clone
    NSDictionary *attributes = [[NSEntityDescription
                                 entityForName:[itemEntity name]
                                 inManagedObjectContext:context] attributesByName];
    
    for (NSString *attr in attributes) {
        if ([attr isEqualToString:@"permanentID"]) {
            [pmo setValue:permID forKey:attr];
        } else if ([attr isEqualToString:@"ID"]) {
            [pmo setValue:@"0x1234" forKey:attr];
        } else {
            [pmo setValue:[managedObject valueForKey:attr] forKey:attr];
        }
        
    }
    
    
    //Now move the children set from the parent to the child.
    
    NSDictionary *relationships = [[NSEntityDescription
                                    entityForName:[itemEntity name]
                                    inManagedObjectContext:context] relationshipsByName];
    
    for (NSRelationshipDescription *rel in relationships){
        NSString *keyName = [NSString stringWithFormat:@"%@",rel];
        //get a set of all objects in the relationship
        if ([keyName isEqualToString:@"children"]) {
            NSMutableSet *sourceSet = [managedObject mutableSetValueForKey:keyName];
            [pmo setChildren:sourceSet];
            [managedObject removeChildren:sourceSet];
        }
    }
    
    //save a return the new object.
    [self saveContext:context];
    return pmo;
}

+(void)validateOrderForSection:(NSIndexPath *)indexPath fetchedResultsController:(NSFetchedResultsController *)frc{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:indexPath.section];
    NSMutableArray *fetchedObjects = [[sectionInfo objects] mutableCopy];
    for (int i = 0; i != fetchedObjects.count; i++) {
        Child *child = [fetchedObjects objectAtIndex:i];
        int order = [child.order intValue];
        
        if (i != order) {
            [child setOrder:[NSNumber numberWithInt:i]];
        } 
    }
    
    [self saveContext:frc.managedObjectContext];
    
}

+(BOOL)childrenItemsChecked:(NSManagedObject *)parentManagedObject includeChildren:(BOOL)includeChildren{
    //YES == all children items are checked
    //NO == one or more children are not checked.
    
    NSSet *childSet = [parentManagedObject valueForKey:@"children"];
    
    //no children. Item is ready to be marked "checked"
    if (childSet.count == 0) {
        return YES;
    }
    BOOL value = NO;
    //children. Find out if any of the children are checked.
    NSEnumerator *e = [childSet objectEnumerator];
    NSManagedObject *childObject;
    while (childObject = [e nextObject]){
        //if the child is unchecked, return no
        value = [[childObject valueForKey:@"checked"] boolValue];
        if (value == NO) {
            //An item is unchecked. it will cascade no.
            return NO;
        }
        
        //child is checked, check its children if they exist.
        
        if (includeChildren) {
                    
            //if children exist, check them.
            NSSet *children = [childObject valueForKey:@"children"];
            if (children.count != 0) {
                //children found, check them.
                value = [ActionClass childrenItemsChecked:childObject includeChildren:YES];
                if (value == NO) {
                    //An item is unchecked. it will cascade no.
                    return NO;
                }
            } 
            //NEXT OBJECT
        }
    }
    //Everything is good to go
    return value;
}
+(void)toggleChildItemsChecked:(NSManagedObject *)parentManagedObject toggle:(BOOL)toggle includeChildren:(BOOL)includeChildren{
    NSMutableSet *childSet = [parentManagedObject mutableSetValueForKey:@"children"];
    
    //If no children, abort
    if (childSet.count == 0) {
        return;
    }
    
    NSEnumerator *e = [childSet objectEnumerator];
    NSManagedObject *childObject;
    while (childObject = [e nextObject]) {
        //check the child object
        [childObject setValue:[NSNumber numberWithBool:toggle] forKey:@"checked"];
        
        //see if the child object has children.
        NSMutableSet *children = [childObject mutableSetValueForKey:@"children"];
        //children found, toggle them as well.
        if (children.count != 0 && includeChildren == YES) {
            [ActionClass toggleChildItemsChecked:childObject toggle:toggle includeChildren:includeChildren];
        }
    }
    //save
    [self saveContext:[parentManagedObject managedObjectContext]];
}

+(void)validateChildrenRelationship:(NSManagedObject *)managedObject {
    NSManagedObjectContext *context = [managedObject managedObjectContext];
    
    /////////////////////////////
    ///Perform the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Child" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSURL *permanentID = [managedObject valueForKey:@"permanentID"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentID=%@", permanentID];
    
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        return;
    }
    ////////////////////////////
    
    
    NSMutableSet *parentsChildren = [managedObject mutableSetValueForKey:@"children"];
    //Reassociate the orphans with the managedObject
    NSEnumerator *e = [fetchedObjects objectEnumerator];
    Child *childObject;
    while (childObject = [e nextObject]){
        //see if the object exists in the parent.
        if (![parentsChildren containsObject:childObject]) {
            [parentsChildren addObject:childObject];
            [self saveContext:context];
        }
    }

    
}

#pragma mark - Core Data Stack
//Global reference to get the current application's managedObjectContext
+(NSManagedObjectContext *)managedObjContext{
    ActionClass *cc = [[ActionClass alloc] init];
    NSManagedObjectContext *moc = [cc managedObjectContext];
    return moc;
    
}
//Global reference to get the current application's managedObjectModel
+(NSManagedObjectModel *)managedObjModel{
    ActionClass *cc = [[ActionClass alloc] init];
    NSManagedObjectModel *mom = [cc managedObjectModel];
    return mom;
}

+(void)saveContext:(NSManagedObjectContext *)context exclusive:(BOOL)exclusive{
    NSError *error = nil;
    if (context != nil && [context hasChanges]) {
        //handle exclusive saves and end
        if (exclusive) {
            if ([context hasChanges] && ![context save:&error]) {
                //Changes were not saved.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ActionClass showCoreDataError];
                //Attempt to undo any changes that were made
                [ActionClass undo:context];
                //try to save!
                [ActionClass saveContext:context];
            }
            //end the routine
            NSLog(@"Context Saved Exclusively");
            return;
        } else {
            [ActionClass saveContext:context];
        }
    }
}

+(void)saveContext:(NSManagedObjectContext *)context{
    NSError *error = nil;
    if (context != nil && [context hasChanges]) {
                
        NSSet *deletedObjects = [context deletedObjects];
        NSSet *insertedObjects = [context insertedObjects];
        NSSet *changedObjects = [context updatedObjects];
        int t = 5;
        int x = [deletedObjects count];
        int y = [insertedObjects count];
        int z = [changedObjects count];
        int total = x + y + z;
        //New save strategy. When there are a certain amount of CUD entries, perform the operation. The 'total' only serves as an overarching strategy to save if there is a culmination of CUD's that do not meet their maximums.
        if (x > t * 2 || y > t * 2 || z > t * 5|| total > (t * 6)) {
            //Proceed with save
            if (![context save:&error]) {
                //Changes were not saved.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ActionClass showCoreDataError];
                //Attempt to undo any changes that were made
                [ActionClass undo:context];
                //try to save!
                [ActionClass saveContext:context];
            }
            NSLog(@"Context Saved, %i changes", total);
        } else {
            NSLog(@"Not enough changes to save");
        }
        
    }
}

+(void)showCoreDataError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"iGotIt had trouble processing the change.\nAttempting to undo the previous action.\nIf this error persists, restart the app." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

+(void)undo:(NSManagedObjectContext *)context {
    [[context undoManager] undo];
}
+(void)redo:(NSManagedObjectContext *)context {
    [[context undoManager] redo];
}
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Misc Methods
+(CGRect)rectTopRightCorner:(UIView *)sourceView{
    CGRect topRightCorner;    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;  
    CGRect sourceViewBounds = [sourceView bounds];
    //iPad dimensions are 1024x768
    float w = sourceViewBounds.size.width;
    float box = 30;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        topRightCorner = CGRectMake(w-box, 0, box, box);
    } else {
        //its in portrait
        topRightCorner = CGRectMake(w-box, 0, box, box);
    }

    return topRightCorner;
}

+(void)disableAllTouches:(float)timeInterval {
    CFTimeInterval ti = timeInterval;
    iGotIt_HDAppDelegate *delegate =  (iGotIt_HDAppDelegate *)[UIApplication sharedApplication].delegate;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGRect windowFrame;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        windowFrame = CGRectMake(0, 0, 768, 1024);
    } else {
        //portrait
        windowFrame = CGRectMake(0, 0, 1024, 768);
    }
    //CGRect testFrame = CGRectMake(0, 0, 480, 640);
    UIButton *theBlocker = [[UIButton alloc] initWithFrame:windowFrame];
    [theBlocker setBackgroundColor:[UIColor clearColor]];
    [delegate.window.rootViewController.view addSubview:theBlocker];
    [theBlocker performSelector:@selector(removeFromSuperview) withObject:theBlocker afterDelay:ti];
    
}

+(CGSize)getViewDimensions:(UIView *)view{
    CGSize size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        size.width = view.frame.size.width;
        size.height = view.frame.size.height;
    } else {
        size.width = view.frame.size.width;
        size.height = view.frame.size.height;
    }
    
    return size;
}

+(UIView *)createColorGrid:(id)target action:(SEL)action delegate:(id)delegate{
    UIView *colorGrid; 
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        colorGrid = [[UIView alloc] init];
    } else {
        colorGrid = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 185, 155)];
    }

    [colorGrid setAutoresizesSubviews:YES];
    [colorGrid setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //create the colors
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    
    //http://kuler.adobe.com/#create/fromacolor
    [colorArray addObject:RGBA(235, 25, 25, 1)];
    [colorArray addObject:RGBA(235, 77.5, 25, 1)];
    [colorArray addObject:RGBA(235, 130, 25, 1)];
    [colorArray addObject:RGBA(235, 182.5, 25, 1)];
    [colorArray addObject:RGBA(235, 235, 25, 1)];
    //set 2
    [colorArray addObject:RGBA(25, 235, 130, 1)];
    [colorArray addObject:RGBA(77.5, 235, 130, 1)];
    [colorArray addObject:RGBA(130, 235, 130, 1)];
    [colorArray addObject:RGBA(182.5, 235, 130, 1)];
    [colorArray addObject:RGBA(235, 235, 130, 1)];
    
    //set 3
    [colorArray addObject:RGBA(25, 235 ,25, 1)];
    [colorArray addObject:RGBA(25, 235 ,77.5, 1)];
    [colorArray addObject:RGBA(25, 235 ,130, 1)];
    [colorArray addObject:RGBA(25, 235 ,182.5, 1)];
    [colorArray addObject:RGBA(25, 235 ,235, 1)];
    
    //set 4
    [colorArray addObject:RGBA(25, 130 , 235 , 1)];
    [colorArray addObject:RGBA(77.5, 130, 235 , 1)];
    [colorArray addObject:RGBA(130, 130, 235 , 1)];
    [colorArray addObject:RGBA(182.5, 130, 235 , 1)];
    [colorArray addObject:RGBA(235, 130, 235 , 1)];
    
    //set 5
    [colorArray addObject:RGBA(25 , 25, 235 , 1)];
    [colorArray addObject:RGBA(77.5 , 25, 235 , 1)];
    [colorArray addObject:RGBA(130 , 25, 235 , 1)];
    [colorArray addObject:RGBA(182.5 , 25, 235 , 1)];
    [colorArray addObject:RGBA(235 , 25, 235 , 1)];
    
    //add a 4x4 square grid to the view
    float x = 0.0;
    float y = 0.0;
    float width = 25.0;
    float height = 25.0;
    int index = 0;
    
    //Dimension 5x5 w/ 5 pix padding and 30 pix box
    /*
     5   
     5-25-5-25-5-25-5-25-5-25-5 = 155px
     | 5
     | 25
     | 5
     | 25
     | 5
     | 25
     | 5
     | 25
     | 5
     ^ 25x70-5-25x70-5 = 155px
     5
     ||
     185px
     */
    for (y = 5.0; y <= 150; y = y + 30.0) {
        for (x = 5.0; x <= 150; x = x + 30.0) {
            CGRect rect = CGRectMake(x, y, width, height);
            
            UIView *colorView = [[UIView alloc] initWithFrame:rect];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
            tapGesture.delegate = delegate;
            
            [colorView setBackgroundColor:[colorArray objectAtIndex:index]];
            [colorView addGestureRecognizer:tapGesture];
            [colorGrid addSubview:colorView];
            index++;
        }
    } 
    //add a white color box
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        x = 5.0;
        y = 155.0;
        width = 145.0;
    } else {
        x = 155;
        y = 5;
        height = 145.0;
    }
    
    CGRect rect = CGRectMake(x, y, width, height);
    UIView *whiteView = [[UIView alloc] initWithFrame:rect];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    tapGesture.delegate = delegate;
    [whiteView setBackgroundColor:RGBA(235, 235, 235, 1)];
    [whiteView addGestureRecognizer:tapGesture];
    [colorGrid addSubview:whiteView];
    [colorGrid.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    return colorGrid;
    
}

#pragma mark - Settings Methods
+(void)showHelpMenu:(HelpMenus)menuType{
    //used to indicate the favorite menu rootViewController index
    int rvcIndex;
    //Check if a helpmenu should be shown.
    BOOL showMenu;
    showMenu = [SettingsClass getShowHelp];
    if (!showMenu) {
        //Help Menus are disabled. Quit.
        return;
    }
    //Help Menus are enabled. Check if the menu should be displayed.
    if (menuType == kParentHelpMenu) {
        showMenu = [SettingsClass getShowParentHelp];
        if (!showMenu) {
            //Parent Help is disabled. Quit.
            return;
        }
        rvcIndex = 1;
        [SettingsClass setShowParentHelp:NO];
    } else if (menuType == kChildHelpMenu) {
        showMenu = [SettingsClass getShowChildHelp];
        if (!showMenu) {
            //Child Help is disabled. Quit.
            return;
        }
        rvcIndex = 1;
        [SettingsClass setShowChildHelp:NO];
    } else if (menuType == kFavoriteHelpMenu) {
        showMenu = [SettingsClass getShowFavoriteHelp];
        if (!showMenu) {
            //Favorite Help is disabled. Quit.
            return;
        }
        rvcIndex = 0;
        [SettingsClass setShowFavoriteHelp:NO];
    } else {
        //unknown menuType
        return;
    }
    
    iGotIt_HDAppDelegate *delegate =  AppDelegate;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *svc = [delegate splitViewController];
        UINavigationController *nvc = [svc.viewControllers objectAtIndex:rvcIndex];
        UITableViewController *tvc = (UITableViewController *)[nvc topViewController];
        UIView *tb = nvc.toolbar;
        
        //Resize the width of the helpMenu to accomodate the NVC
        CGRect newFrameWidth;
        newFrameWidth.origin.x = 0;
        newFrameWidth.origin.y = 0;
        newFrameWidth.size.height = 300;
        newFrameWidth.size.height = 300 + tb.layer.frame.size.height;
        newFrameWidth.size.width = nvc.view.frame.size.width;
        HelpView *helpMenu = [[HelpView alloc] initWithFrame:newFrameWidth];
        NSNumber *mType = [NSNumber numberWithInt:menuType];
        
        //Initialize the views
        [helpMenu setMenuType:mType];
        
        CGPoint tbOldPos = tb.layer.position;
        CGPoint tbNewPos = tbOldPos;
        tbNewPos.y -= helpMenu.frame.size.height;
        
        
        //ANIMATION SETTINGS
        CFTimeInterval animationDuration = 0.5f;
        //ANIMATION SETTINGS
        CABasicAnimation *toolBarAnimation;
        
        toolBarAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        [toolBarAnimation setDelegate:delegate];
        [toolBarAnimation setFromValue:[NSValue valueWithCGPoint:tbOldPos]];
        [toolBarAnimation setToValue:[NSValue valueWithCGPoint:tbNewPos]];
        [toolBarAnimation setDuration:animationDuration];
        [toolBarAnimation setFillMode:kCAFillModeForwards];
        [toolBarAnimation setRemovedOnCompletion:NO];
        [tb.layer setPosition:tbNewPos];
        [tb.layer addAnimation:toolBarAnimation forKey:@"position"];
        
        //set the anchor point to the top of helpMenu view
        [helpMenu.layer setAnchorPoint:CGPointMake(0.5, 0.0)];
        //position the layer at the bottom of nvc.view
        CGPoint nvcBottom = CGPointMake(tb.layer.position.x, tbOldPos.y);
        [helpMenu.layer setPosition:nvcBottom];
        //Create a new position underneath the toolbar's New position
        CGPoint tbBottom;
        tbBottom = CGPointMake(tb.layer.position.x, tb.layer.frame.origin.y + tb.layer.frame.size.height);
        
        //add the helpMenu.view
        [nvc.view addSubview:helpMenu];
        
        CABasicAnimation *helpMenuAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        [helpMenuAnimation setDelegate:toolBarAnimation.delegate];
        [helpMenuAnimation setFromValue:[NSValue valueWithCGPoint:tbOldPos]];
        [helpMenuAnimation setToValue:[NSValue valueWithCGPoint:tbBottom]];
        [helpMenuAnimation setDuration:animationDuration];
        [helpMenuAnimation setFillMode:toolBarAnimation.fillMode];
        [helpMenuAnimation setRemovedOnCompletion:[toolBarAnimation isRemovedOnCompletion]];
        [helpMenu.layer setPosition:tbBottom];
        [helpMenu.layer addAnimation:helpMenuAnimation forKey:@"position"];
        
        //make sure the table content fites
        tvc.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, helpMenu.frame.size.height, 0.0);
        tvc.tableView.scrollIndicatorInsets = tvc.tableView.contentInset;
    } else {
        //iPhone Help Menu
        UITabBarController *tabBarController = (UITabBarController *)[delegate.window rootViewController];
        UINavigationController *nvc = [tabBarController.viewControllers objectAtIndex:rvcIndex];
        NSString *title;
        NSString *messageFull, *ln1, *ln2, *ln3, *ln4, *ln5;
        
        switch (menuType) {
            case kChildHelpMenu:
                title = [NSString stringWithFormat:@"Child Help"];
                ln1 = [NSString stringWithFormat:@""];
                ln2 = [NSString stringWithFormat:@""];
                ln3 = [NSString stringWithFormat:@""];
                ln4 = [NSString stringWithFormat:@""];
                ln5 = [NSString stringWithFormat:@""];
                break;
            case kParentHelpMenu:
                title = [NSString stringWithFormat:@"Parent Help"];
                ln1 = [NSString stringWithFormat:@"Help Menus are great!"];
                ln2 = [NSString stringWithFormat:@"Of course this is only a test message"];
                ln3 = [NSString stringWithFormat:@"But you can get the point if something interesting was actually in here."];
                ln4 = [NSString stringWithFormat:@"Can you believe I wrote this?"];
                ln5 = [NSString stringWithFormat:@"Impressive Huh?"];
                break;
            case kFavoriteHelpMenu:
                title = [NSString stringWithFormat:@"Favorite Help"];
                ln1 = [NSString stringWithFormat:@""];
                ln2 = [NSString stringWithFormat:@""];
                ln3 = [NSString stringWithFormat:@""];
                ln4 = [NSString stringWithFormat:@""];
                ln5 = [NSString stringWithFormat:@""];
                break;
            default:
                break;
        }
        
        messageFull = [NSString stringWithFormat:@"• %@\n\n • %@\n\n • %@\n\n • %@\n\n • %@", ln1,ln2,ln3,ln4,ln5];
        
        [NotificationPanel notificationViewInView:nvc.view title:title message:messageFull withView:nil];
        //need a disable help button.
    }
    
}
+(void)hideHelpMenu:(BOOL)animated menuType:(HelpMenus)menuType{
    int svcIndex;
    if (menuType == kFavoriteHelpMenu) {
        svcIndex = 0;
    } else {
        svcIndex = 1;
    }
    iGotIt_HDAppDelegate *delegate =  AppDelegate;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UISplitViewController *svc = [delegate splitViewController];
        UINavigationController *nvc = [svc.viewControllers objectAtIndex:svcIndex];
        UITableViewController *tvc = (UITableViewController *)[nvc topViewController];
        
        
        //check if the helpMenu is present in the NVC
        NSArray *nvcSubviews = nvc.view.subviews;
        NSEnumerator *e = [nvcSubviews objectEnumerator];
        UIView *subview;
        while (subview = [e nextObject]) {
            
            if ([[[subview class] description] isEqualToString:@"HelpView"]) {
                //remove the view
                subview = (HelpView *)subview;
                
                UIToolbar *tb = nvc.toolbar;
                CABasicAnimation *oldTBAnimation = (CABasicAnimation *)[tb.layer animationForKey:@"position"];
                NSValue *tbNewPosV = oldTBAnimation.fromValue;
                NSValue *tbOldPosV = oldTBAnimation.toValue;
                CGPoint tbNewPos = [tbNewPosV CGPointValue];
                
                ////if (svcIndex != 0) {
                [tb.layer removeAnimationForKey:@"position"];
                ////}
                
                //ANIMATION SETTINGS
                CFTimeInterval animationDuration = 0.5f;
                //ANIMATION SETTINGS
                
                //disable selections on screen
                [ActionClass disableAllTouches:animationDuration];
                
                CABasicAnimation *toolBarAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                [toolBarAnimation setDelegate:delegate];
                [toolBarAnimation setFromValue:tbOldPosV];
                [toolBarAnimation setToValue:tbNewPosV];
                [toolBarAnimation setDuration:animationDuration];
                [toolBarAnimation setFillMode:kCAFillModeForwards];
                [toolBarAnimation setRemovedOnCompletion:NO];
                
                ////if (svcIndex != 0) {
                [tb.layer setPosition:tbNewPos];
                ////}
                
                
                CABasicAnimation *oldHMAnimation = (CABasicAnimation *)[subview.layer animationForKey:@"position"];
                NSValue *HMNewPosV = oldHMAnimation.fromValue;
                NSValue *HMOldPosV = oldHMAnimation.toValue;
                CGPoint hmNewPos = [HMNewPosV CGPointValue];
                hmNewPos.y += (tb.frame.size.height / 2);
                [subview.layer removeAnimationForKey:@"position"];
                CABasicAnimation *helpMenuAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                [helpMenuAnimation setDelegate:toolBarAnimation.delegate];
                [helpMenuAnimation setFromValue:HMOldPosV];
                [helpMenuAnimation setToValue:[NSValue valueWithCGPoint:hmNewPos]];
                [helpMenuAnimation setDuration:animationDuration];
                [helpMenuAnimation setFillMode:toolBarAnimation.fillMode];
                [helpMenuAnimation setRemovedOnCompletion:[toolBarAnimation isRemovedOnCompletion]];
                [subview.layer setPosition:hmNewPos];
                
                if (animated) {
                    
                    [subview.layer addAnimation:helpMenuAnimation forKey:@"position"];
                    if (svcIndex != 0) {
                        [tb.layer addAnimation:toolBarAnimation forKey:@"position"];
                    }
                    [subview performSelector:@selector(removeFromSuperview) withObject:subview afterDelay:animationDuration];
                } else {
                    
                    [subview removeFromSuperview];
                }
                
                //reset the tvc insets
                tvc.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
                tvc.tableView.scrollIndicatorInsets = tvc.tableView.contentInset;
                //removed the view
            }
            
        }
    } else {
        //iPhone Help Menu
    }
    
    
   
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
