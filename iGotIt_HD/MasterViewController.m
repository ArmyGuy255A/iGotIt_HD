//
//  MasterViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailTableViewController.h"
#import "ChildTableViewController.h"
#import "AddItemTableViewController.h"
#import "CustomCellBackground.h"
#import "NotificationView.h"
#import "ActionClass.h"
#import "SettingsClass.h"
#import "Parent.h"
#import "ControlExtras.h"
#import "FavoriteCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

@synthesize detailTableViewController = _detailTableViewController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize itemPopover;
@synthesize nView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Favorites", @"Favorites");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        id delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [delegate managedObjectContext];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    /*
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(countDatabaseObjects)];
    self.navigationItem.rightBarButtonItem = button1;
    */
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
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
    
    
    
}

-(void)removePCon:(id)sender{
    UIButton *theBlocker = sender;
    [theBlocker removeFromSuperview];
    
    UIPopoverController *pc = self.detailTableViewController.popoverController;
    BOOL isVisible = [pc isPopoverVisible];
    if (isVisible) {
        UINavigationController *nvc = (UINavigationController *)pc.contentViewController;
        [nvc.topViewController.view removeFromSuperview];
        [nvc.view removeFromSuperview];
        [pc dismissPopoverAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ActionClass showHelpMenu:kFavoriteHelpMenu];
    
    UIPopoverController *pc = self.detailTableViewController.popoverController;
    BOOL isVisible = [pc isPopoverVisible];
    if (isVisible) {
        //Only allow a button as the passthrough view
        //The button will properly dismiss the popover so that animations perform properly.
        
        CGRect windowFrame = CGRectMake(0, 0, 1024, 1024);
        UIButton *theBlocker = [[UIButton alloc] initWithFrame:windowFrame];
        [theBlocker setTag:666];
        [theBlocker setBackgroundColor:[UIColor clearColor]];
        
        //Add the button to the navigation controller
        [self.detailTableViewController.navigationController.view addSubview:theBlocker];
        
        [theBlocker.layer setZPosition:100];
        [theBlocker addTarget:self action:@selector(removePCon:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *passthroughViews = [NSArray arrayWithObject:theBlocker];
        [pc setPassthroughViews:passthroughViews];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [ActionClass hideHelpMenu:YES menuType:kFavoriteHelpMenu];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
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
        [self saveContext];
        
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
    
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
    //[sectionLabel addSubview:bgView];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -2, 400, 30)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [bgView addSubview:sectionLabel];
    
    
    NSString *value = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    [sectionLabel setText:value];
    
    return bgView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect box = CGRectMake(0.0, 0.0, 0.0, 30.0);
    return box.size.height;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
    //Create an instance of the selected object
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ChildTableViewController *childTVC = [[ChildTableViewController alloc] init];
    [childTVC setManagedObject:selectedObject];
    [childTVC setManagedObjectContext:[selectedObject managedObjectContext]];
    [childTVC setPopoverController:itemPopover];
    [childTVC setTitle:@"Editing Favorite: "];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    DetailTableViewController *dtVC = self.detailTableViewController;
    [dtVC.navigationItem setBackBarButtonItem:bbi];  
    
    [dtVC.splitViewController setDelegate:childTVC];     
    [dtVC.navigationController pushViewController:childTVC animated:YES];
    
    //Future release. Implement this funcationality. Or make it open in another popover.
    //[self.navigationController pushViewController:childTVC animated:YES];
    
    
    BOOL isVisible = [dtVC.popoverController isPopoverVisible];
    if (isVisible) {
        UINavigationController *nvc = (UINavigationController *)dtVC.popoverController.contentViewController;
        [nvc.topViewController.view removeFromSuperview];
        [nvc.view removeFromSuperview];
        [dtVC.popoverController dismissPopoverAnimated:YES];
    }
    
    //get rid of the blocker button
    NSArray *subViews = self.detailTableViewController.navigationController.view.subviews;
    NSEnumerator *e = [subViews objectEnumerator];
    UIView *theBlocker;
    while (theBlocker = [e nextObject]) {
        if (theBlocker.tag == 666) {
            [theBlocker removeFromSuperview];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    //Alternate cell background color
    if((indexPath.row + (indexPath.section % 2))% 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    }
    */
}

#pragma mark - GestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}
#pragma mark - Fetched results controller

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
            NSLog(@"mtvc Insert");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"mtvc Delete");
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"mtvc Update");
            
            if (indexPath.row < r) {
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"mtvc Move");
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

#pragma mark - Custom Implementation
-(void)performClone:(id)sender{
    UIButton *button2 = sender;
    Parent *favorite = [[self fetchedResultsController] objectAtIndexPath:button2.indexPath];
    
    UINavigationController *navCon = self.detailTableViewController.navigationController;
    UIViewController *detailView = navCon.topViewController;
    
    if ([detailView isKindOfClass:[DetailTableViewController class]]) {
        //Clone, Delete
        //NSLog(@"DetailTableViewController");
        //Always a parent set tag to 0x1234
        Parent *newObject = (Parent *)[ActionClass cloneManagedObject:favorite];
        [newObject setID:@"0x1234"];
        [newObject setFavorite:[NSNumber numberWithBool:NO]];
        //[newObject setChecked:[NSNumber numberWithBool:NO]];
    } else if ([detailView isKindOfClass:[ChildTableViewController class]]) {
        //Clone, Convert, Delete
        Parent *clonedFavorite = (Parent *)[ActionClass cloneManagedObject:favorite];
        Child *convertedChild = [ActionClass convertParentToChild:clonedFavorite];
        
        [[convertedChild managedObjectContext] deleteObject:clonedFavorite];
        [self saveContext];
        
        //Always a child set parentID the class's managedObject
        ChildTableViewController *ctvc = (ChildTableViewController *)detailView;
        NSManagedObject *parentObject = ctvc.managedObject;
        NSString *parentID = [parentObject valueForKey:@"permanentID"];
        NSMutableSet *children = [parentObject mutableSetValueForKey:@"children"];
        [children addObject:convertedChild];
        
       
        [convertedChild setFavorite:[NSNumber numberWithBool:NO]];
        //[convertedChild setID:@""];
        [self saveContext];
        [convertedChild setParentID:parentID];
        //[convertedChild setChecked:[NSNumber numberWithBool:NO]];
        //[ActionClass validateChildrenRelationship:parentObject];
    }
    
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:0];
    [self saveContext];
    NSLog(@"completed");
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
    // Create a new instance of the entity managed by the fetched results controller.
    
    if (![self.itemPopover isPopoverVisible]) {
        
        //Create the new TableView for the Popover
        AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        UINavigationController *addItemNavController = [[UINavigationController alloc] initWithRootViewController:aiTVC];
        [addItemNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [aiTVC setTitle:@"Edit Item"];
        
        /*
        /////////////////////
        //Setup Toolbar
        /////////////////////
        //Setup the toolbar
        NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:nil];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:nil];
        
        //Use this to put space in between the toolbox buttons
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [toolbarButtons addObject:doneButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:deleteButton];
        
        [aiTVC setToolbarItems:toolbarButtons animated:NO];
        [aiTVC.navigationController.toolbar setBarStyle:UIBarStyleBlack];
        [aiTVC.navigationController setToolbarHidden:NO animated:NO];
        
        */
        /////////////////////
        
        
        //Capture the existing Parent
        
        aiTVC.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aiTVC.mainTableView = self.tableView;
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:addItemNavController];
        CGRect box = CGRectMake(0, 0, 300, 350);
        popover.popoverContentSize = box.size;
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        aiTVC.popoverController = popover;
        
    } 
    //NSLog(@"%@", indexPath.description);
    
    //Present the View from cell
     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
     //CGRect cellRect = cell.bounds;
     [self.itemPopover presentPopoverFromRect:cell.bounds inView:cell permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
     
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [cell setSelected:NO];
        [self editObject:indexPath];
        
    }
}
-(void)saveContext {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [ActionClass saveContext:context];
    /*
    NSError *error = nil;
    if (![context save:&error]) {
        //NSLog(@"Child TVC - Unresolved saving error: %@, %@", error, [error userInfo]);
        [ActionClass showCoreDataError];
        //abort();
    }
     */
}

-(void)validateViewHeirarchy:(NSManagedObject *)managedObject{
    UINavigationController *dtnvc = self.detailTableViewController.navigationController;
    NSArray *viewControllers = dtnvc.viewControllers;
    NSEnumerator *e = [viewControllers objectEnumerator];
    UITableViewController *tvc;
    while (tvc = [e nextObject]) {
        if ([tvc isKindOfClass:[ChildTableViewController class]]) {
            ChildTableViewController *ctvc = (ChildTableViewController *)tvc;
            NSManagedObject *ctvcMO = ctvc.managedObject;
            if (ctvcMO == managedObject) {
                //Return the Navcon to the root view controller
                [dtnvc popToRootViewControllerAnimated:YES];
            }
            
        }
    }
    
}

@end
