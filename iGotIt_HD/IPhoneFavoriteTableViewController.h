//
//  IPhoneFavoriteTableViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPhoneFavoriteTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NotificationView *nView;

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)setupNavBar;
-(void)setupTabBar;
-(void)validateViewHeirarchy:(NSManagedObject *)managedObject;


@end
