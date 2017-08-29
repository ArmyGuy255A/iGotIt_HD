//
//  iCloudCoreData.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 11/19/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "iCloudCoreData.h"

@implementation iCloudCoreData

+(BOOL)isEnabled {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSURL *iCloudDirectory = [fm URLForUbiquityContainerIdentifier:nil];
    
    BOOL result;
    if (iCloudDirectory) {
        result = YES;
    } else {
        result = NO;
    }
    
    return result;
}

+(NSDictionary *)persistentStoreOptions {
    //Create a file manager
    NSFileManager *fm = [[NSFileManager alloc] init];
    //Locate the extended sandbox in iCloud
    NSURL *URLValue = [fm URLForUbiquityContainerIdentifier:nil];
    //Create a directory for the log files associated with the sqlite database
    NSString *nameValue = [[URLValue path]stringByAppendingPathComponent:@"sqlite.logFiles"];
    //Create the full directory URL for iCloudCoreData transaction logs
    URLValue = [NSURL fileURLWithPath:nameValue];
    //Associate the persistent store iCloud values with their required option keys.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"appeid.iGotIt.v1", NSPersistentStoreUbiquitousContentNameKey, URLValue, NSPersistentStoreUbiquitousContentURLKey, nil];
    return options;
}

+(void)syncDatabase:(id)object {
    iGotIt_HDAppDelegate *delegate = AppDelegate;
    NSManagedObjectContext *moc = delegate.managedObjectContext;
    //Capture the entities
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:moc];
    //Perform a fetch for all objects of that entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects) {
        NSEnumerator *m = [fetchedObjects objectEnumerator];
        NSManagedObject *mo;
        while (mo = [m nextObject]) {
            NSManagedObject *nmo = [ActionClass cloneManagedObject:mo];
            [nmo setValue:[mo valueForKey:@"checked"] forKey:@"checked"];
            [nmo setValue:[mo valueForKey:@"ID"] forKey:@"ID"];
            [nmo setValue:[mo valueForKey:@"favorite"] forKey:@"favorite"];
            [moc deleteObject:mo];
            //[moc deleteObject:nmo];
        }
    } else {
        NSLog(@"No Objects Exist.");
    }
    [ActionClass saveContext:moc exclusive:YES];
}

@end
