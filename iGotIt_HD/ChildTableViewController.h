//
//  ChildTableViewController.h
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Child.h"

@interface ChildTableViewController : UITableViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIActionSheetDelegate>

#pragma mark - Popover
@property (strong, nonatomic) UIPopoverController *itemPopover;
@property (strong, nonatomic) UIPopoverController *popoverController;

#pragma mark - Split View Items
@property (strong, nonatomic) id detailItem;

#pragma mark - FRC Delegate
@property (strong, nonatomic) NSManagedObject *managedObject;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Other Global Variables
@property (strong, nonatomic) UIBarButtonItem *editButtonItemCustom;

-(void)renameAutoNumberButton:(UIButton *)button;
-(void)renameSortButton:(UIBarButtonItem *)button;
-(void)setupToolbar;
-(void)setupRightBarButtons;
-(void)saveContext;
-(void)displayEditButton:(BOOL)value;
-(void)toggleEdit;
-(void)dismissItemPopover;

@end
