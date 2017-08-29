//
//  MasterViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NotificationView.h"
@class DetailTableViewController;



@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet DetailTableViewController *detailTableViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Popover
@property (strong, nonatomic) UIPopoverController *itemPopover;

@property (strong, nonatomic) NotificationView *nView;

-(void)saveContext;
-(void)validateViewHeirarchy:(NSManagedObject *)managedObject;

@end
