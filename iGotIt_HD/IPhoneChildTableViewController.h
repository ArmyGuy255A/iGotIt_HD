//
//  IPhoneChildTableViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneChildTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

#pragma mark - FRC Delegate
@property (strong, nonatomic) NSManagedObject *managedObject;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark - Other Global Variables
@property (strong, nonatomic) UIBarButtonItem *editButtonItemCustom;

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setupNavBar;
-(void)setupTabBar;
-(void)setupRightBarButtons;

-(void)setupToolbar;
-(void)renameAutoNumberButton:(UIButton *)button;
-(void)renameSortButton:(UIBarButtonItem *)button;
-(void)displayEditButton:(BOOL)value;
-(void)toggleEdit;

@end
