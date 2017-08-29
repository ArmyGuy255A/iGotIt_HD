//
//  IPhoneFavoriteTableViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "IPhoneFavoriteTableViewController.h"
#import "IPhoneItemViewController.h"
#import "IPhoneParentTableViewController.h"
#import "IPhoneChildTableViewController.h"
#import "FavoriteCell.h"
#import "CustomCellBackground.h"
#import "ControlExtras.h"
#import "NotificationView.h"
#import "NotificationPanel.h"


@implementation IPhoneFavoriteTableViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext;
@synthesize nView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"TAB_FAV" ofType:@"png"];
        UIImage *tabBarItemImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        UITabBarItem *tbi = [[UITabBarItem alloc] initWithTitle:@"" image:tabBarItemImage tag:0];
        [self setTabBarItem:tbi];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setDelegate:self];
    [self setupNavBar];
    [self setupTabBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table Rotation 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        //NSLog(@"Portrait Orientation");
    } else {
        //NSLog(@"Landscape Orientation");
    }
    // Return YES for supported orientations
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
}

#pragma mark - TableView Data Source Protocol
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FavoriteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        //if the item is a part of the navigation controller heirarchy, navigate to root.
        [self validateViewHeirarchy:mo];
        
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:mo];
        
        
        //save the context
        [ActionClass saveContext:context];
        
    }   
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
#pragma mark - TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float sectionHeight = 30.0;
    
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 400, 25)];
    [sectionLabel.layer setPosition:CGPointMake(sectionLabel.layer.position.x, sectionHeight / 2)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [bgView addSubview:sectionLabel];
    
    
    NSString *value = [NSString stringWithFormat:@"%@",[[[self.fetchedResultsController sections] objectAtIndex:section] name]];
    [sectionLabel setText:value];
    
    return bgView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    IPhoneChildTableViewController *childTVC = [[IPhoneChildTableViewController alloc] init];
    [childTVC setManagedObject:selectedObject];
    [childTVC setTitle:@"*"];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:bbi];  
    
    [self.navigationController pushViewController:childTVC animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelected:NO];
}

/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/
#pragma mark - Fetched Results Controller Delegate

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"catTitle" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *sD2 = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, sD2, nil];
    
    // Set the Predicate for only Favorite items
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID='0x6969' AND favorite=%d", 1];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite=%d", 1];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"catTitle" cacheName:@"Favorite"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    [ActionClass showCoreDataError];
        //abort();
	}
    
    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    int r = [self.tableView numberOfRowsInSection:indexPath.section];
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            //NSLog(@"mtvc Insert");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"mtvc Delete");
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //NSLog(@"mtvc Update");
            
            if (indexPath.row < r) {
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            //NSLog(@"mtvc Move");
            if (indexPath.row < r) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            
            
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    [self.tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - GestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}


#pragma mark - Custom Implementation
-(void)setupNavBar {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}
-(void)setupTabBar{
    
}

#pragma mark - Custom Implementation (iPad Version)
-(void)performClone:(id)sender{
    
    UIButton *button2 = sender;
    Parent *favorite = [[self fetchedResultsController] objectAtIndexPath:button2.indexPath];
    NSManagedObjectContext *context = [favorite managedObjectContext];
    
    UINavigationController *navCon = [self.tabBarController.viewControllers objectAtIndex:1];
    UIViewController *viewController = navCon.topViewController;
    
    if ([viewController isKindOfClass:[IPhoneParentTableViewController class]]) {
        //Clone, Delete
        //Always a parent set tag to 0x1234
        Parent *newObject = (Parent *)[ActionClass cloneManagedObject:favorite];
        [newObject setID:@"0x1234"];
        [newObject setFavorite:[NSNumber numberWithBool:NO]];
        
    } else if ([viewController isKindOfClass:[IPhoneChildTableViewController class]]) {
        //Clone, Convert, Delete
        Parent *clonedFavorite = (Parent *)[ActionClass cloneManagedObject:favorite];
        Child *convertedChild = [ActionClass convertParentToChild:clonedFavorite];
        
        [context deleteObject:clonedFavorite];
        [ActionClass saveContext:context];
        
        //Always a child set parentID the class's managedObject
        IPhoneChildTableViewController *ctvc = (IPhoneChildTableViewController *)viewController;
        NSManagedObject *parentObject = ctvc.managedObject;
        NSString *parentID = [parentObject valueForKey:@"permanentID"];
        NSMutableSet *children = [parentObject mutableSetValueForKey:@"children"];
        [children addObject:convertedChild];

        [convertedChild setFavorite:[NSNumber numberWithBool:NO]];
        [ActionClass saveContext:context];
        [convertedChild setParentID:parentID];
        
    } else {
        [NotificationPanel notificationViewInView:self.view title:@"Failure" message:@"A valid target does not exist. \n Make sure you are not adding or editing an item." withView:nil];
        return;
    }
    
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:0];
    [ActionClass saveContext:context];    
    [self.tabBarController setSelectedIndex:1];
}

-(void)copyFavorite:(id)sender{
    
    UIButton *button2 = sender;
    [self performSelector:@selector(showInsert:) withObject:button2 afterDelay:0];
    
    nView = [NotificationView notificationViewInView:self.view.window notificationMessage:@"Processing ..." withIndicator:YES];
    
    //prepare all items needed for the function
    [self performSelector:@selector(performClone:) withObject:button2 afterDelay:0.2];
    
}


-(void)showInsert:(id)sender{
    UIButton *button2 = sender;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:button2.indexPath];
    UIButton *button1 = (UIButton *)[cell viewWithTag:50];
    
    [UIButton transitionWithView:button2 duration:.25 options:UIViewAnimationOptionTransitionFlipFromTop animations:nil completion:nil];
    [UIButton transitionWithView:button1 duration:.25 options:UIViewAnimationOptionTransitionFlipFromBottom animations:nil completion:nil];
    
    [button2 setHidden:YES];
    [button1 setHidden:NO];
}

-(void)revertShowInsert:(id)sender{
    UIButton *button2 = sender;
    if (![button2 isHidden]) {
        [self performSelector:@selector(showInsert:) withObject:button2 afterDelay:0];
    }
}

-(void)showConfirm:(id)sender {
    UIButton *button1 = sender;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:button1.indexPath];
    UIButton *button2 = (UIButton *)[cell viewWithTag:60];
    
    [UIButton transitionWithView:button1 duration:.25 options:UIViewAnimationOptionTransitionFlipFromTop animations:nil completion:nil];
    [UIButton transitionWithView:button2 duration:.25 options:UIViewAnimationOptionTransitionFlipFromBottom animations:nil completion:nil];
    
    [button2 setHidden:NO];
    [button1 setHidden:YES];
    
    [self performSelector:@selector(revertShowInsert:) withObject:button2 afterDelay:2];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FavoriteCell *currentCell = (FavoriteCell *)cell;
    Parent *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *mainLabel = (UILabel*)[currentCell.contentView viewWithTag:10];
    UILabel *secondLabel = (UILabel*)[currentCell.contentView viewWithTag:20];
    UILabel *thirdLabel = (UILabel*)[currentCell.contentView viewWithTag:30];
    //UILabel *fourthLabel = (UILabel*)[currentCell.contentView viewWithTag:40];
    UIButton *button1 = (UIButton*)[currentCell.contentView viewWithTag:50];
    UIButton *button2 = (UIButton*)[currentCell.contentView viewWithTag:60];
    //mainLabel
    [mainLabel setText:managedObject.title];
    
    //secondLabel values
    NSUInteger children = [[managedObject children] count];
    
    //thirdLabel values
    NSNumber *x = [ActionClass countObjectsInObject:managedObject];
    /*
     //fourthLabel values
     NSString *objID = [[[managedObject objectID] URIRepresentation] description];
     objID = [objID lastPathComponent];
     */
    NSString *secondText = [NSString stringWithFormat:@"Sub-Items: %i", children];
    NSString *thirdText = [NSString stringWithFormat:@"Total Sub-Items: %i", [x intValue]];
    //NSString *fourthText = [NSString stringWithFormat:@"ID: %@", objID];
    NSString *buttonText1 = [NSString stringWithFormat:@"Insert"];
    NSString *buttonText2 = [NSString stringWithFormat:@"Confirm"];
    
    [secondLabel setText:secondText];
    [thirdLabel setText:thirdText];
    //[fourthLabel setText:fourthText];
    [button1 setTitle:buttonText1 forState:UIControlStateNormal];
    [button2 setTitle:buttonText2 forState:UIControlStateNormal];
    [button2 setHidden:YES];
    
    //Add touch to hold gesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.delegate = self;
    [cell addGestureRecognizer:longPressGesture];
    
    [button1 addTarget:self action:@selector(showConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setIndexPath:indexPath];
    [button2 addTarget:self action:@selector(copyFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setIndexPath:indexPath];
    
}

-(void)countDatabaseObjects{
    NSNumber *count = [ActionClass countDatabaseWithContext:self.managedObjectContext];
    NSString *results = [NSString stringWithFormat:@"# Obj in DB: %i", count.intValue];
    
    nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:results withIndicator:NO];
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:2];
    
}
- (void)editObject:(NSIndexPath *)indexPath
{
    //Create the new TableView for the Popover
    IPhoneItemViewController *ipIVC = [[IPhoneItemViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [ipIVC setHidesBottomBarWhenPushed:YES];
    NSManagedObject *mo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *title = [NSString stringWithFormat:@"Edit Item"];
    [ipIVC setTitle:title];
    
    //Create the new Parent
    ipIVC.managedObject = mo;
    ipIVC.mainTableView = self;
    ipIVC.parentManagedObject = mo;
    
    //Create the new Popover Controller
    //can I do this for the iPhone?
    
    
    //Present the View
    [self.navigationController pushViewController:ipIVC animated:YES];

}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [cell setSelected:NO];
        [self editObject:indexPath];
        
    }
}


-(void)validateViewHeirarchy:(NSManagedObject *)managedObject{
    //This method is only really used for the iPad. I am using it in the iPhone just in case I run into issues down the road.
    UINavigationController *dtnvc = [self.tabBarController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = dtnvc.viewControllers;
    NSEnumerator *e = [viewControllers objectEnumerator];
    UITableViewController *tvc;
    while (tvc = [e nextObject]) {
        if ([tvc isKindOfClass:[IPhoneChildTableViewController class]]) {
            IPhoneChildTableViewController *ctvc = (IPhoneChildTableViewController *)tvc;
            NSManagedObject *ctvcMO = ctvc.managedObject;
            if (ctvcMO == managedObject) {
                //Return the Navcon to the root view controller
                [dtnvc popToRootViewControllerAnimated:YES];
            }
            
        }
    }
}



@end
