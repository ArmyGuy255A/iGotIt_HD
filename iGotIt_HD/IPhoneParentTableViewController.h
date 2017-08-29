//
//  IPhoneParentTableViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneParentTableViewController : UITableViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

#pragma mark - FRC Delegate
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setupNavBar;
-(void)setupTabBar;
-(void)insertNewObject:(id)sender;
@end
