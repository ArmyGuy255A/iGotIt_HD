//
//  ChildTableViewController.m
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//


#import "ActionClass.h"
#import "SettingsClass.h"
#import "DrawingClass.h"
#import "ChildTableViewController.h"
#import "DetailTableViewController.h"
#import "AddItemTableViewController.h"
#import "NotificationView.h"
#import "CustomModalAlert.h"
#import "ControlExtras.h"
#import "Parent.h"
#import "ParentCell.h"
#import "CustomCellBackground.h"
#import "Child.h"
#import "CustomBarButtonItem.h"


@interface ChildTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureView;

@end

@implementation ChildTableViewController

@synthesize detailItem = _detailItem;
@synthesize popoverController = _myPopoverController;
@synthesize itemPopover;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObject = __managedObject;
@synthesize editButtonItemCustom = __editButtonItemCustom;


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        [self.navigationController setView:self.view];
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
        
    //Additional taleView initializaiton
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    //Validate Children
    [ActionClass validateChildrenRelationship:self.managedObject];
    
    // Set up the navbar
    self.navigationItem.leftItemsSupplementBackButton = YES;
        
    NSString *titlePrefix = self.title;
    NSString *titleSuffix = [self.managedObject valueForKey:@"title"];
    if (self.title) {
        self.title = [NSString stringWithFormat:@"%@%@", titlePrefix, titleSuffix];
    } else {
        self.title = titleSuffix;
    }
    
    
    [self.fetchedResultsController setDelegate:self];
    
}

- (void)viewDidUnload
{
    //NSLog(@"------------CHILD VIEW DID UNLOAD-----------");
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"------------CHILD VIEW WILL APPEAR-----------");
    [super viewWillAppear:animated];
    //[self.tableView reloadData];
    [self.splitViewController setDelegate:self];
    
    // Setup Toolbar
    [self setupToolbar];
    
    // Setup RightBarButtons
    [self setupRightBarButtons];
    
    
    //////////////////////////////
    //Take care of the SVC Button
    UISplitViewController *svc = self.splitViewController;
    UIViewController *mVC = [svc.viewControllers objectAtIndex:0];
    UIBarButtonItem *bbi = svc.barButtonItem;
    if (UIDeviceOrientationIsPortrait(svc.interfaceOrientation)) {
        [self splitViewController:svc willHideViewController:mVC withBarButtonItem:bbi forPopoverController:self.popoverController];
    } else {
        [self splitViewController:svc willShowViewController:mVC invalidatingBarButtonItem:bbi];
    }
    //////////////////////////////
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"------------CHILD VIEW DID APPEAR-----------");
    [super viewDidAppear:animated];

    [ActionClass showHelpMenu:kChildHelpMenu];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"------------CHILD VIEW WILL DISAPPEAR-----------");
    [super viewWillDisappear:animated];
    [ActionClass hideHelpMenu:YES menuType:kChildHelpMenu];
    self.fetchedResultsController = nil;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"------------CHILD VIEW DID DISAPPEAR-----------");
    [super viewDidDisappear:animated];
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if ([toolbarItems containsObject:self.editButtonItemCustom]) {
        [toolbarItems removeObject:self.editButtonItemCustom];
        [self setToolbarItems:toolbarItems];
    }
    
    
}

#pragma mark - Table Rotation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}

#pragma mark - TableView Data Source Protocol

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageOnRightCell";
    UILabel *mainLabel, *secondLabel, *thirdLabel;
    UIButton *checkBox;
    
    Child *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];    
    ParentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Create a new cell if one doesn't exist
    if (cell == nil) {
        cell = [[ParentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } 
    
    //Capture contentView Objects
    mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
    secondLabel = (UILabel *)[cell.contentView viewWithTag:SECONDLABEL_TAG];
    thirdLabel = (UILabel *)[cell.contentView viewWithTag:THIRDLABEL_TAG];
    checkBox = (UIButton *)[cell.contentView viewWithTag:CHECKBOX_TAG];
    
    //Add touch to hold gesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressGesture.delegate = self;
    [cell addGestureRecognizer:longPressGesture];
    ///////////////////////////////////////////////////
    //Setting Labels
    ///////////////////////////////////////////////////
    
    //MainLabel
    
    BOOL autoNumbering = [[self.managedObject valueForKey:@"autoNumberValue"] boolValue];
    if (autoNumbering == 1) {
        NSString *moTitle = [[managedObject valueForKey:@"title"] description];
        mainLabel.text = [NSString stringWithFormat:@"%i - %@",indexPath.row + 1,moTitle];
    } else if (autoNumbering == 0) {
        mainLabel.text = [[managedObject valueForKey:@"title"] description];
        //NSString *moTitle = [[managedObject valueForKey:@"title"] description];
        //mainLabel.text = [NSString stringWithFormat:@"%@ - %i",moTitle,[[managedObject valueForKey:@"order"] intValue]];
    }
    //SecondLabel
    secondLabel.text = [[managedObject valueForKey:@"desc"] description];
    
    //Center the mainLabel if the secondlabel is empty
    if ((secondLabel.text == nil) || (secondLabel.text == [NSString stringWithFormat:@""])) {
        [secondLabel setHidden:YES];
        CGRect mainLabelFrame = CGRectMake(secondLabel.frame.origin.x, cell.frame.size.height / 4, secondLabel.frame.size.width, secondLabel.frame.size.height);
        [mainLabel setFrame:mainLabelFrame];
    } else {
        [secondLabel setHidden:NO];
        CGRect mainLabelFrame = CGRectMake(secondLabel.frame.origin.x, 0, secondLabel.frame.size.width, secondLabel.frame.size.height);
        [mainLabel setFrame:mainLabelFrame];    
    }
    //ThirdLabel
    //Get children item count
    NSSet *children = [managedObject valueForKey:@"children"];
    NSEnumerator *e = [children objectEnumerator];
    NSManagedObject *mo;
    int completedChildren = 0;
    while (mo = [e nextObject]) {
        BOOL b = [[mo valueForKey:@"checked"] boolValue];
        if (b) {
            completedChildren += 1;
        }
    }
    
    if (children.count == 0) {
        thirdLabel.text = nil;
    } else {
        thirdLabel.text = [NSString stringWithFormat:@"Completed: %i of %d",completedChildren, children.count];
    }
    
    
    //Find out how many children there are and how many are checked.
    
    ///////////////////////////////////////////////////
    //Setting Check Box
    /////////////////////////////////////////////////////Capture indexPath for the action
    [checkBox setIndexPath:indexPath];
    //Set action
    [checkBox addTarget:self action:@selector(tableViewCheckBox:) forControlEvents:UIControlEventTouchUpInside];
    //Determine if managedObjec is checked
    BOOL isChecked = [[managedObject checked] boolValue];
    //Set appropriate image
    CGFloat imgHW = 40;
    //first remove any subViews
    if (checkBox.subviews.count >0) {
        NSEnumerator *e = [checkBox.subviews objectEnumerator];
        UIView *subview;
        while (subview = [e nextObject]) {
            [subview removeFromSuperview];
        }
    }
    if (isChecked == YES) {
        UIImage *theImage = [SettingsClass getThemeCheckBoxImage];
        UIImageView *iv = [[UIImageView alloc] initWithImage:theImage];
        [iv setAutoresizesSubviews:YES];
        [iv setFrame:CGRectMake(0, 0, imgHW, imgHW)];
        [checkBox addSubview:iv];
        [iv.layer setPosition:checkBox.layer.position];
        //[checkBox setImage:theImage forState:UIControlStateNormal];
    } else if (isChecked == NO) {
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"CHK_BOX" ofType:@"png"];
        UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *iv = [[UIImageView alloc] initWithImage:theImage];
        [iv setAutoresizesSubviews:YES];
        [iv setFrame:CGRectMake(0,0,imgHW, imgHW)];
        [checkBox addSubview:iv];
        [iv.layer setPosition:checkBox.layer.position];
        //[checkBox setImage:theImage forState:UIControlStateNormal];
    }
    ///////////////////////////////////////////////////    
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
	NSLog(@"%@", [[[self.fetchedResultsController sections] objectAtIndex:section] name]);
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSManagedObject *trashMO = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:trashMO];
        
        // Save the context.
        [self saveContext];
    }   
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    Child *child = (Child *)self.managedObject;
    int value = [[child sortValue] intValue];
    if (value == 0) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:fromIndexPath.section];
    NSMutableArray *fetchedResults = [[sectionInfo objects] mutableCopy];
    
    if (fetchedResults == nil) {
        return;
    }
    
    //dont allow moves between sections
    if (fromIndexPath.section != toIndexPath.section) {
        //NSLog(@"Reloading Data - moveRowAtIndexPath");
        [tableView reloadData];
        return;
    }
    
    int fromIndex = fromIndexPath.row;
    int toIndex = toIndexPath.row;
    
    int start = fromIndex;
    int finish = toIndex;
    
    if (fromIndex > toIndex) {
        start = toIndex;
        finish = fromIndex;
    }
    
    Item *item = nil;

    for (int i = start; i <= finish; i++) {
        
        
        if (fromIndex > toIndex) {
            if (i == fromIndex && fromIndex > toIndex) {
                //original item, set its index at the start
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:start]];
                //NSLog(@"Item: %@ - New Order:%i", item.title, [item.order intValue]);
            } else {
                //increment everything else by one
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:i + 1]];
                //NSLog(@"Item: %@ - New Order:%i", item.title, [item.order intValue]);
            }
        } else if (toIndex > fromIndex) {
            if (i == fromIndex && toIndex > fromIndex) {
                //original item, set its index to the finish
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:finish]];
                //NSLog(@"Item: %@ - New Order:%i", item.title, [item.order intValue]);
            } else {
                //decrement everything else by one
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:i - 1]];
                //NSLog(@"Item: %@ - New Order:%i", item.title, [item.order intValue]);
            }

        }
    }
    
    [self saveContext];
    
}

#pragma mark - Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
    
    //label title
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 2, 400, 30)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [bgView addSubview:sectionLabel];
    
    //checkbox
    UIButton *checkBox = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 35)];
    [checkBox setBackgroundColor:[UIColor clearColor]];
    [checkBox setShowsTouchWhenHighlighted:YES];
    [bgView addSubview:checkBox];
    
    NSString *imagePath;    
    UIImage *theImage;
        
    NSString *value = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    NSInteger intValue = [value integerValue];
    
    
    switch (intValue) {
        case 0:
            [sectionLabel setText:@"  In-Progress:"];
            [checkBox addTarget:self action:@selector(checkAll) forControlEvents:UIControlEventTouchUpInside];
            theImage = [SettingsClass getThemeCheckBoxAllImage];
            break;
        case 1:
            [sectionLabel setText:@"  Completed:"];
            [checkBox addTarget:self action:@selector(uncheckAll) forControlEvents:UIControlEventTouchUpInside];
            imagePath = [[NSBundle mainBundle] pathForResource:@"UNCHK_ALL" ofType:@"png"];
            theImage = [UIImage imageWithContentsOfFile:imagePath];
            break;
        default:
            break;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:theImage];
    [imageView setFrame:CGRectMake(16,2.5,30,30)];
    [checkBox addSubview:imageView];
    /////////////////////
    
    return bgView;

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect box = CGRectMake(0.0, 0.0, 0.0, 35.0);
    return box.size.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"catColor"];
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:color];
     cell.backgroundView = bgView;
   
    
}  
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    ChildTableViewController *cTVC = [[ChildTableViewController alloc] init];
    [cTVC setManagedObject:selectedObject];
    [cTVC setManagedObjectContext:[selectedObject managedObjectContext]];
    
    [self.navigationController pushViewController:cTVC animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
    //return UITableViewCellEditingStyleInsert;
    //return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"willBeginEditingRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"didEndEditingRowAtIndexPath");
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    //NSLog(@"======Enter Child TVC fetchedResultsController======");
    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
   
    // Create the fetch request for the entity.
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Child" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    NSSortDescriptor *initialSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checked" ascending:YES];
    
    int sortValue = [[self.managedObject valueForKey:@"sortValue"] intValue];
    NSSortDescriptor *sortDescriptor;

    switch (sortValue) {
        case 0:
            //Manual Sort
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
            break;
        case 1:
            //Ascending
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            break;
        case 2:
            //Descending
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        break;
                
        default:
        break;
    }
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:initialSortDescriptor, sortDescriptor, nil];
    
    // Find the child objects
    NSManagedObjectID *permanentID = [self.managedObject objectID];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentID=%@", permanentID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent=%@", permanentID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    [NSFetchedResultsController deleteCacheWithName:@"Child"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self.managedObject managedObjectContext] sectionNameKeyPath:@"checked" cacheName:@"Child"];
    [aFetchedResultsController setDelegate:self];
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    [ActionClass showCoreDataError];
        //abort();
	}
    //NSLog(@"========Exit Child TVC FRC========");
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    //NSLog(@"Child TVC Begin Updates - FRC");
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
    //NSLog(@"Reloading Data - didChangeSection");
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"ctvc Insert");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [ActionClass validateOrderForSection:newIndexPath fetchedResultsController:controller];
            //NSLog(@"Child TVC - didChangeObject - Insert - FRC");
            [tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"ctvc Delete");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //NSLog(@"Child TVC - didChangeObject - Delete - FRC");
            [tableView reloadData];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"ctvc Update");
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //NSLog(@"Child TVC - didChangeObject - Update - FRC");
            break;
        case NSFetchedResultsChangeMove:
            NSLog(@"ctvc Move");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
           
            [ActionClass validateOrderForSection:newIndexPath fetchedResultsController:controller];
            //NSLog(@"Child TVC - didChangeObject - Move - FRC");
            [tableView reloadData];
            break;
    }
    
    
//#warning - Need to reload individual cells for smoother UI
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
 // In the simplest, most efficient, case, reload the table view.
    //NSLog(@"controllerDidChangeContent");
    [self.tableView endUpdates];
    //NSLog(@"RELOAD - Child TVC - controllerDidChangeContent");
    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    //prepares the "popController" button to be removed when tilted landscape
    NSMutableArray *navItemButtons = [NSMutableArray arrayWithArray:[self.navigationItem leftBarButtonItems]];
    [barButtonItem setTitle:@"Favorites"];   
    [navItemButtons removeAllObjects];
    [navItemButtons insertObject:barButtonItem atIndex:0];
    
    self.navigationItem.leftBarButtonItems = navItemButtons;
    self.popoverController = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    
    NSMutableArray *navItemButtons = [NSMutableArray arrayWithArray:[self.navigationItem leftBarButtonItems]];
    [navItemButtons removeObjectIdenticalTo:barButtonItem];
    self.navigationItem.leftBarButtonItems = navItemButtons;
    self.popoverController = nil;
    
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        
    }
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    Child *child;
    if (buttonIndex == 0) {
        child = (Child *)self.managedObject;
        [child setSortValue:[NSNumber numberWithInt:0]];
        UIBarButtonItem *button = [self.toolbarItems objectAtIndex:0];
        [self renameSortButton:button];
        [self saveContext];
        
    }

    self.fetchedResultsController = nil;
    __fetchedResultsController = nil;
    //NSLog(@"Reloading TV - toggleAutoNumbering");
    [self.tableView reloadData];


}

#pragma mark - Custom Implementation

-(void)toggleAutoNumbering:(id)sender {
    
    //NSLog(@"Toggle Auto Numbering");
    Child *child = (Child *)self.managedObject;
    int value = [[child sortValue] intValue];
    BOOL autoNumbering = [[child autoNumberValue] boolValue];
    //Is Manual Sorting Enabled?
    if (value != 0 && !autoNumbering) {
        //It is not.  Ask to enable it.
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [actionSheet setTitle:@"Auto Numbering is optimized for manual sorting. Do you wish to enable manual sorting?"];
        [actionSheet setDestructiveButtonIndex:actionSheet.numberOfButtons - 1];
        UIButton *button = sender;
        [actionSheet showFromRect:button.bounds inView:self.navigationController.toolbar animated:YES];
        
    }
        
    value = [[child autoNumberValue] boolValue];
    
    if (value == 1) {
        [child setAutoNumberValue:[NSNumber numberWithBool:NO]];
    } else if (value == 0) {
        [child setAutoNumberValue:[NSNumber numberWithBool:YES]];
    }
    [self saveContext];
    UIButton *button = sender;
    [self renameAutoNumberButton:button];
    
    
    
}

-(void)toggleSort:(id)sender {
    //NSLog(@"Toggle Sort");
    Child *child = (Child *)self.managedObject;
    int value = [[child sortValue] intValue];

    
    NotificationView *nView;
    switch (value) {
        case 0:
            [child setSortValue:[NSNumber numberWithInt:1]];
            nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:@"Sorting: Ascending" withIndicator:NO];
            break;
        case 1:
            [child setSortValue:[NSNumber numberWithInt:2]];
            nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:@"Sorting: Descending" withIndicator:NO];
            break;
        case 2:
            [child setSortValue:[NSNumber numberWithInt:0]];
            nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:@"Sorting: Manual" withIndicator:NO];
            break;
        default:
            break;
    }
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:1.0];
    
    [self saveContext];

    //SortValues for the objects change. I need to dump the old 
    //frc and recreate it based on the new value.
    self.fetchedResultsController = nil;
    __fetchedResultsController = nil;
     
    //Change the barButton image accordingly
    UIBarButtonItem *button = sender;
    [self renameSortButton:button];
}


-(void)renameSortButton:(UIBarButtonItem *)button{
    Child *child = (Child *)self.managedObject;
    int value = [[child sortValue] intValue];
    NSString *imagePath;
    UIImage *theImage;
    switch (value) {
        case 0:
            imagePath = [[NSBundle mainBundle] pathForResource:@"orderManual" ofType:@"png"];
            //Display the reorder control and self.editButtonItem
            [self.tableView setEditing:YES animated:YES];
            [self displayEditButton:YES];
            [self toggleEdit];
            break;
        case 1:
            imagePath = [[NSBundle mainBundle] pathForResource:@"orderAscending" ofType:@"png"];
            [self.tableView setEditing:YES animated:YES];
            [self displayEditButton:NO];
            [self toggleEdit];
            break;
        case 2:
            imagePath = [[NSBundle mainBundle] pathForResource:@"orderDescending" ofType:@"png"];
            [self.tableView setEditing:YES animated:YES];
            [self displayEditButton:NO];
            [self toggleEdit];
            break;
        default:
            break;
    }
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    [button setImage:theImage];
    [self.tableView reloadData];
}

-(void)renameAutoNumberButton:(UIButton *)button{
    Child *child = (Child *)self.managedObject;
    BOOL value = [[child autoNumberValue] boolValue];
    
    //UILabel *label = (UILabel *)[button viewWithTag:10];
    UIImageView *imageView = (UIImageView *)[button viewWithTag:20];
    
    
    NSString *imagePath;
    
    NotificationView *nView;
    switch (value) {
        case 0:
            imagePath = [[NSBundle mainBundle] pathForResource:@"crystalRed" ofType:@"png"];
            nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:@"Auto Number: Off" withIndicator:NO];
            break;
        case 1:
            imagePath = [[NSBundle mainBundle] pathForResource:@"crystalGreen" ofType:@"png"];
            nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:@"Auto Number: On" withIndicator:NO];
            break;
        default:
            break;
    }
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:1.0];
    
    
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    [imageView setImage:theImage];
    
    //NSLog(@"Reloading TV - renameAutoNumbering");
    [self.tableView reloadData];
}


- (void)insertNewObject:(id)sender
{
    // Create a new instance of the entity managed by the fetched results controller.
    
    
    if (![self.itemPopover isPopoverVisible]) {
        
        //Create the new TableView for the Popover
        AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
        
        UINavigationController *addItemNavController = [[UINavigationController alloc] initWithRootViewController:aiTVC];
        [addItemNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [aiTVC setTitle:@"New Item"];
        
        //Create the new Child
        Child *newChild = [ActionClass createChildItem:@"" parentManagedObject:self.managedObject];
        [newChild setOrder:[NSNumber numberWithInt:1000]];
        aiTVC.managedObject = newChild;
        aiTVC.parentManagedObject = self.managedObject;
        aiTVC.mainTableView = self.tableView;
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:addItemNavController];
        CGSize size = CGSizeMake(300, 325);
        [self setContentSizeForViewInPopover:size];
        popover.popoverContentSize = size;
        [popover setPassthroughViews:nil];
        
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        aiTVC.popoverController = popover;
        [aiTVC.popoverController setDelegate:aiTVC];
        
    } 
    
    //Present the View
    [self.itemPopover presentPopoverFromRect:[ActionClass rectTopRightCorner:self.view]  inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void)editObject:(NSIndexPath *)indexPath
{
    // Create a new instance of the entity managed by the fetched results controller.
    
    if (![self.itemPopover isPopoverVisible]) {
        
        //Create the new TableView for the Popover
        AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
        
        UINavigationController *addItemNavController = [[UINavigationController alloc] initWithRootViewController:aiTVC];
        [aiTVC setTitle:@"Edit Item"];
        
        //Capture the existing Parent
        
        aiTVC.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aiTVC.parentManagedObject = self.managedObject;
        aiTVC.mainTableView = self.tableView;
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:addItemNavController];
        CGSize size = CGSizeMake(300, 325);
        [self setContentSizeForViewInPopover:size];
        popover.popoverContentSize = size;
        
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        aiTVC.popoverController = popover;
        [aiTVC.popoverController setDelegate:aiTVC];
        
    } 
    
    //Present the View
    [self.itemPopover presentPopoverFromRect:[ActionClass rectTopRightCorner:self.view]  inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

-(void)tableViewCheckBox:(id)sender {
    UIButton *checkBoxButton = (UIButton *)sender;
    
    Child *selectedObject = [[self fetchedResultsController] objectAtIndexPath:checkBoxButton.indexPath];
    
    //get the inverse bool value for checking and unchecking
    BOOL selObjSetChecked = ![[selectedObject valueForKey:@"checked"] boolValue];
    
    //Check to see if any children are unchecked. NO == something unchecked
    BOOL allChildrenChecked = [ActionClass childrenItemsChecked:selectedObject includeChildren:YES];
    
        
    //If all children are checked
    if (allChildrenChecked) {
        //If the selected object needs to be unchecked
        NSSet *children = [selectedObject valueForKey:@"children"];
        if (!selObjSetChecked && (children.count > 0)) {
            BOOL result;
            NSString *question = [NSString stringWithFormat:@"Do you want to uncheck all sub-items?"];
            result = [ModalAlert ask:question title:@"Uncheck All Sub-Items"];
            if (result) {
                [ActionClass toggleChildItemsChecked:selectedObject toggle:!selectedObject includeChildren:result];
            }
            
        }
        
    } else {
        //Some children are unchecked.
        //If the selected object wants to be checked
        if (selObjSetChecked) {
            BOOL result;
            NSString *question = [NSString stringWithFormat:@"Do you want to check all sub-items?"];
            result = [ModalAlert ask:question title:@"Incomplete Sub-Items"];
            if (result) {
                [ActionClass toggleChildItemsChecked:selectedObject toggle:selObjSetChecked includeChildren:result];
            }
            
        } else {
            //The object wants to be unchecked. so uncheck it.
           
        }
    }
    [selectedObject setChecked:[NSNumber numberWithBool:selObjSetChecked]];

    [self saveContext];
    //check if the parent should be checked/unchecked as well.
    allChildrenChecked = [ActionClass childrenItemsChecked:self.managedObject includeChildren:NO];
    [self.managedObject setValue:[NSNumber numberWithBool:allChildrenChecked] forKey:@"checked"];
   
    
    [self saveContext];
    [self.tableView reloadData];

}
-(void)checkAll{
    //get an array of unchecked objects
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSArray *uncheckedObjects = [sectionInfo objects];
    
    
    NSString *question = [NSString stringWithFormat:@"Do you want to check %i items?", uncheckedObjects.count];
    //show a confirmation dialog
    BOOL result = [ModalAlert ask:question title:@"Proceed?"];
    if (result == NO) {
        return;
    }
    
    //loop through each object and ensure all children are checked
    BOOL allChildrenChecked = YES;
    NSEnumerator *e = [uncheckedObjects objectEnumerator];
    NSManagedObject *childObject;
    while ((childObject = [e nextObject]) && (allChildrenChecked == YES)) {
        allChildrenChecked = [ActionClass childrenItemsChecked:childObject includeChildren:YES];
    }
    
    //if a child is unchecked, open a modalalert confirming
    if (allChildrenChecked == NO) {
        question = [NSString stringWithFormat:@"Do you want to check all sub-items?"];
        result = [ModalAlert ask:question title:@"Incomplete Sub-Items"];
    }
    
    //result == YES, unless the second modal alert appears and "no" is selected.
    [ActionClass toggleChildItemsChecked:self.managedObject toggle:YES includeChildren:result];
}
-(void)uncheckAll{
    //get an array of checked objects
    NSArray *sections = [self.fetchedResultsController sections];
    id <NSFetchedResultsSectionInfo> sectionInfo;
    if (sections.count == 1) {
        sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    } else {
        sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:1];
    }
    
    NSArray *checkedObjects = [sectionInfo objects];
    
    NSString *question = [NSString stringWithFormat:@"Do you want to uncheck %i items?", checkedObjects.count];
    //show a confirmation dialog
    BOOL result = [ModalAlert ask:question title:@"Proceed?"];
    if (result == NO) {
        return;
    }
    
    //detect if children items are present
    BOOL childrenPresent = NO;
    NSEnumerator *e = [checkedObjects objectEnumerator];
    NSManagedObject *childObject;
    while ((childObject = [e nextObject]) && (childrenPresent == NO)) {
        NSSet *children = [childObject valueForKey:@"children"];
        if (children.count != 0) {
            childrenPresent = YES;
        }
    }
    if (childrenPresent == YES) {
        question = [NSString stringWithFormat:@"Do you want to uncheck all sub-items?"];
        result = [ModalAlert ask:question title:@"Uncheck Sub-Items"]; 
    }
    
    
    [ActionClass toggleChildItemsChecked:self.managedObject toggle:NO includeChildren:result];
}

- (void)setupToolbar {
    //Setup the toolbar
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //Set Sorting Button
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(toggleSort:)];
        
    //Set Autonumber Button
    CGFloat width = 115.0;
    UIButton *anButton = [UIButton barButtonWithImage:nil title:@"Auto Number" width:width target:self action:@selector(toggleAutoNumbering:)];
    UIBarButtonItem *autoNumberButton = [[UIBarButtonItem alloc] initWithCustomView:anButton];
    [self renameAutoNumberButton:(UIButton *)autoNumberButton.customView];
    
    //Use this to put space in between buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [toolbarButtons addObject:sortButton];
    [toolbarButtons addObject:autoNumberButton];
    [toolbarButtons addObject:flexItem];
    
    [self setToolbarItems:toolbarButtons animated:NO];
    
    [self renameSortButton:sortButton];

    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    
}

-(void)setupRightBarButtons {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    ////////////////////////////
    //Need a button with a star.
    UIButton *faveButton = [UIButton barButtonWithImage:nil title:nil width:31 target:self action:@selector(makeFavorite:)];
    
    //get the star
    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"favoriteButton" ofType:@"png"];
    UIImage *image = [SettingsClass getThemeFavoriteButtonImage];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    [iv setFrame:CGRectMake(3, 2, 25, 25)];
    [faveButton addSubview:iv];
    
    //create the new barbutton item
    UIBarButtonItem *favoriteButton = [[UIBarButtonItem alloc] initWithCustomView:faveButton];
    
    //set the background image
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButtonStateNormal" ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 10, 15, 10);
    [favoriteButton setBackgroundImage:[image resizableImageWithCapInsets:insets] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    ////////////////////////////
    
    NSArray *buttons = [NSArray arrayWithObjects:addButton, favoriteButton, nil];
    [self.navigationItem setRightBarButtonItems:buttons animated:NO];
    //self.navigationItem.rightBarButtonItems = buttons;
    
}

-(void)saveContext {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [ActionClass saveContext:context];
    /*
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Child TVC - Unresolved saving error: %@, %@", error, [error userInfo]);
        [ActionClass showCoreDataError];
        //abort();
    }
    
    //NSLog(@"----====  Child TVC  ====----");
    //NSLog(@"----====SAVED CONTEXT====----");
     */
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self editObject:indexPath];
        
    }
}

-(void)countObjectsInObject{
    NSNumber *count = [ActionClass countObjectsInObject:self.managedObject];
    NSString *results = [NSString stringWithFormat:@"# Obj in MO: %i", count.intValue];
    NotificationView *nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:results withIndicator:NO];
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:2];
    
}

-(void)displayEditButton:(BOOL)value {
    NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
    
    if (value == YES) {
        if ([toolbarButtons containsObject:self.editButtonItemCustom] == NO) {
            [toolbarButtons insertObject:self.editButtonItemCustom atIndex:2];
        }
    } else if (value == NO) {
        if ([toolbarButtons containsObject:self.editButtonItemCustom] == YES) {
            [toolbarButtons removeObjectIdenticalTo:self.editButtonItemCustom];
        }
    }
    
    [self setToolbarItems:toolbarButtons animated:NO]; 
}

-(void)toggleEdit {
    BOOL editing = [self.tableView isEditing];
    
    UIButton *anButton = (UIButton *)self.editButtonItemCustom.customView;
    UIImageView *imageView = (UIImageView *)[anButton viewWithTag:20];
    NSString *imagePath; 
    
    //NSString *status;
    
    if (!editing == YES) {
        imagePath = [[NSBundle mainBundle] pathForResource:@"crystalGreen" ofType:@"png"];
        //status = @"Reorder Control: On";
    } else {
        imagePath = [[NSBundle mainBundle] pathForResource:@"crystalRed" ofType:@"png"];
        //status = @"Reorder Control: Off";
    }
    [self.tableView setEditing:!editing animated:YES]; 
    
    //set the image
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    [imageView setImage:theImage];
    
    //display the alert
    //NotificationView *nView = [NotificationView notificationViewInView:self.tableView.window notificationMessage:status withIndicator:NO];
    
    //[nView performSelector:@selector(removeView) withObject:nil afterDelay:2];
    
}

-(UIBarButtonItem *)editButtonItemCustom{
    if (__editButtonItemCustom != nil) {
        return __editButtonItemCustom;
    }
    
    //////////////////////////////
    //Create a custom edit button
    //////////////////////////////
    CGFloat width = 115.0;
    UIButton *anButton = [UIButton barButtonWithImage:nil title:@"Reorder List" width:width target:self action:@selector(toggleEdit)];
    UIBarButtonItem *editButtonItemCustom = [[UIBarButtonItem alloc] initWithCustomView:anButton];
    //////////////////////////////
    
    __editButtonItemCustom = editButtonItemCustom;
    return __editButtonItemCustom;
    
}

-(void)performClone:(id)sender {
    //Item will always become a parent. No matter what!
    
    NotificationView *nView = sender;
    
    NSString *moClass = [[self.managedObject class] description];
    
    Parent *mo;
    if ([moClass isEqualToString:@"Child"]) {
        //Item is a child - Clone, Convert, Delete
        Child *cmo = (Child *)[ActionClass cloneManagedObject:self.managedObject];
        mo = [ActionClass convertChildToParent:cmo];
        [mo setPermanentID:[cmo permanentID]];
        [[mo managedObjectContext] deleteObject:cmo];
        
    } else {
        //Item is a parent
        mo = (Parent *)[ActionClass cloneManagedObject:self.managedObject];
    }
    
    
    //Category title is necessary
    NSString *catTitle = mo.catTitle;
    if ([catTitle isEqualToString:@""] || catTitle == nil) {
        [mo setCatTitle:@"Default Category"];
    }
    
    //Replace ID with the favorite tag.
    [mo setID:@"0x6969"];
    [mo setFavorite:[NSNumber numberWithBool:YES]];
    
    [nView performSelector:@selector(removeView) withObject:nil afterDelay:0];
    [self saveContext];   
    
}
-(void)makeFavorite:(id)sender{
    if ([self.itemPopover isPopoverVisible]) {
        [self.itemPopover dismissPopoverAnimated:YES];
    }
    NotificationView *nView;
    //if title is empty, abort the procedure
    NSString *title = [self.managedObject valueForKey:@"title"];
    NSString *question = [NSString stringWithFormat:@"Do you want to make '%@' a favorite?", title];
    BOOL result = [ModalAlert ask:question title:@"Make Favorite"];
    if (result == NO) {
        return;
    }
    //Sometimes this operation takes a few seconds. Show an indicator
    nView = [NotificationView notificationViewInView:self.view.window notificationMessage:@"Adding to Favorites ..." withIndicator:YES];
    //Finally, if in landscape, rotate the view 90 degrees.
    
    [self performSelector:@selector(performClone:) withObject:nView afterDelay:0.2];
    
}
-(void)dismissItemPopover {
    if ([self.itemPopover isPopoverVisible]) {
        [self.itemPopover dismissPopoverAnimated:YES];
    }
}
@end
