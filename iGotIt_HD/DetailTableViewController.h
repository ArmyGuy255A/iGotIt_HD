//
//  DetailViewController.h
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DetailTableViewController : UITableViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

#pragma mark - Popover
@property (strong, nonatomic) UIPopoverController *itemPopover;
@property (strong, nonatomic) UIPopoverController *popoverController;

#pragma mark - Split View Items
@property (strong, nonatomic) id detailItem;


#pragma mark - FRC Delegate
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


-(void)setupToolbar;
-(void)setupRightBarButtons;
-(void)saveContext;
-(void)editObject:(NSIndexPath *)indexPath;
-(void)dismissItemPopover;


@end
