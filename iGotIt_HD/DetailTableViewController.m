//
//  DetailViewController.m
//  iGotIt HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//


//#import "RootViewController.h"
#import "ActionClass.h"
#import "SettingsClass.h"
#import "Parent.h"
#import "DetailTableViewController.h"
#import "ChildTableViewController.h"
#import "AddItemTableViewController.h"
#import "NotificationView.h"
#import "ControlExtras.h"
#import "ParentCell.h"
#import "CustomCellBackground.h"
#import "CustomModalAlert.h"
#import "CustomBarButtonItem.h"


@interface DetailTableViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//- (void)configureView;
//@property (strong, nonatomic) UIPopoverController *popoverController;

@end

@implementation DetailTableViewController

@synthesize detailItem = _detailItem;
@synthesize popoverController = _myPopoverController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize itemPopover;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
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
-(void)reloadView:(NSNotification *)notification {
    
}
-(void)reloadFetchedResults:(NSNotification *)notification {
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}		
    
    if (notification) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"iGot It";
    
	[self.navigationController setToolbarHidden:NO animated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView:) name:@"RefreshAllViews" object:[[UIApplication sharedApplication] delegate]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"ReloadFetchedResults" object:[[UIApplication sharedApplication] delegate]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //This was the missing delegate method. Jeez!!
    [self.splitViewController setDelegate:self];
    [self.tableView reloadData];
    
    
    
    //Setup Toolbar
    [self setupToolbar];
    
    //Setup rightBarButtons
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
    //NSLog(@"------------Detail TVC DID APPEAR-----------");
    //Display help menu if necessary
    [ActionClass showHelpMenu:kParentHelpMenu];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"------------Detail TVC WILL DISAPPEAR-----------");
    
    [super viewWillDisappear:animated];
    [ActionClass hideHelpMenu:YES menuType:kParentHelpMenu];
}

- (void)viewDidDisappear:(BOOL)animated
{
	//NSLog(@"------------Detail TVC DID DISAPPEAR-----------");
    
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
#define MAINLABEL_TAG 1
#define SECONDLABEL_TAG 2
#define THIRDLABEL_TAG 3
#define CHECKBOX_TAG 4


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ImageOnRightCell";
    UILabel *mainLabel, *secondLabel, *thirdLabel;
    UIButton *checkBox;
    
    Parent *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];    
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
    mainLabel.text = [[managedObject valueForKey:@"title"] description];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle;
    switch (section) {
        case 0:
            //[sectionLabel setText:@"  In-Progress:"];
            sectionTitle = [[NSString alloc] initWithFormat:@"In-Progress"];
            break;
        case 1:
            // [sectionLabel setText:@"  Completed:"];
            sectionTitle = [[NSString alloc] initWithFormat:@"In-Progress"];
            
            break;
        default:
            break;
    }
    return sectionTitle;
}*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
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

/*
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // The table view should not be re-orderable.
 return NO;
 }
 */

#pragma mark - TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
   
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 400, 30)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [bgView addSubview:sectionLabel];
    
    NSString *value = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    NSInteger intValue = [value integerValue];
    
    
    switch (intValue) {
        case 0:
            [sectionLabel setText:@"  In-Progress:"];
            break;
        case 1:
            [sectionLabel setText:@"  Completed:"];
            break;
        default:
            break;
    }
    return bgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect box = CGRectMake(0.0, 0.0, 0.0, 30.0);
    return box.size.height;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get the managedObject color
    UIColor *color = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"catColor"];
    //Create the gradient background
    id bgView = [[CustomCellBackground alloc] init];
    //Set the start and end colors of the gradient
    [bgView setTheBaseColor:color];
    //[bgView setTheEndColor:color2];
    //assign the backgroundView   
    cell.backgroundView = bgView;
    
    
    
}  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create an instance of the selected object
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    ChildTableViewController *childTVC = [[ChildTableViewController alloc] init];
    [childTVC setManagedObject:selectedObject];
    [childTVC setManagedObjectContext:[selectedObject managedObjectContext]];
    [childTVC setPopoverController:self.popoverController];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:bbi];  

    
    [self.splitViewController setDelegate:childTVC];     
    [self.navigationController pushViewController:childTVC animated:YES];
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /////////////////////
    //Set up the fetched results controller.
    /////////////////////
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Parent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *initialSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"checked" ascending:YES];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:initialSortDescriptor,sortDescriptor, nil];
    
    // Set the Predicate for only Parent and no favorite items
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID='0x1234' AND favorite=%d",0];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSLog(@"Creating the FRC for == DetailTVC ==");
    
    [NSFetchedResultsController deleteCacheWithName:@"Detail"];    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"checked" cacheName:@"Detail"];
    aFetchedResultsController.delegate = self;
    
    self.fetchedResultsController = aFetchedResultsController;
    
    //NSLog(@"Executing Fetch Request with == DetailTVC moc- %@", [self.fetchedResultsController.managedObjectContext description]);
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    [ActionClass showCoreDataError];
        //abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    //NSLog(@"Detail TVC Begin Updates - FRC");
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
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
     
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            NSLog(@"dtvc Insert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"dtvc Delete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"dtvc Update");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"dtvc Move");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    [self.tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    //NSLog(@"Detail TVC End Updates - FRC");
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    [barButtonItem setTitle:@"Favorites"];  
    //prepares the "popController" button to be removed when tilted landscape
    
    ////////////////////////
    //Program the Background Image
    UIImage *theImage = [SettingsClass getThemeButtonBackgroundImage:kStateNormal];
    UIBarButtonItem *bbi = [UIBarButtonItem barButtonWithBackground:theImage title:barButtonItem.title target:barButtonItem.target action:barButtonItem.action];
    barButtonItem.customView = bbi.customView;
    /////////////////////////
    
    NSMutableArray *navItemButtons = [NSMutableArray arrayWithArray:[self.navigationItem leftBarButtonItems]];
    [navItemButtons removeAllObjects];
    [navItemButtons addObject:barButtonItem];
    
    [svc setBarButtonItem:barButtonItem];
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


- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController{
    
}



#pragma mark - Custom Implementation
-(void)sortAscending:(id)sender {
    //NSLog(@"Sort Ascending");
    
}

-(void)sortDescending:(id)sender {
    //NSLog(@"Sort Descending");
}

-(void)tableViewCheckBox:(id)sender {
    UIButton *checkBoxButton = (UIButton *)sender;
    
    Parent *selectedObject = [[self fetchedResultsController] objectAtIndexPath:checkBoxButton.indexPath];
    //get the inverse bool value for checking and unchecking
    BOOL selObjSetChecked = ![[selectedObject valueForKey:@"checked"] boolValue];
    
    //Check to see if any children are unchecked. NO == something unchecked
    BOOL allChildrenChecked = [ActionClass childrenItemsChecked:selectedObject includeChildren:NO];
    
        
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
            
            
        }
    }
    //check the object no matter what
    [selectedObject setChecked:[NSNumber numberWithBool:selObjSetChecked]];

    [self saveContext];
    [self.tableView reloadData];
}



- (void)setupToolbar {
    //Setup the toolbar
    //NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //Set Sorting Actions
    /*
    UIBarButtonItem *sortAscending = [[UIBarButtonItem alloc] initWithTitle:@"Sort Ascending" style:UIBarButtonItemStyleBordered target:self action:@selector(sortAscending:)];
    UIBarButtonItem *sortDescending = [[UIBarButtonItem alloc] initWithTitle:@"Sort Descending" style:UIBarButtonItemStyleBordered target:self action:@selector(sortDescending:)];
    */
    //Use this to put space in between the toolbox buttons
   //UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //[toolbarButtons addObject:sortAscending];
    //[toolbarButtons addObject:sortDescending];
    //[toolbarButtons addObject:flexItem];
    //[toolbarButtons addObject:addButton];
    
    //[self setToolbarItems:toolbarButtons animated:NO];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    
}

-(void)setupRightBarButtons {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}
- (void)insertNewObject:(id)sender
{
    // Create a new instance of the entity managed by the fetched results controller.
    
    
    if (![self.itemPopover isPopoverVisible]) {
        
        //Create the new TableView for the Popover
        AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        UINavigationController *addItemNavController = [[UINavigationController alloc] initWithRootViewController:aiTVC];
        //[addItemNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [aiTVC setTitle:@"New List"];
        
        //Create the new Parent
        Parent *newParent = [ActionClass createParent:@"" managedObjectContext:context];
        aiTVC.managedObject = newParent;
        aiTVC.mainTableView = self.tableView;
        aiTVC.parentManagedObject = newParent;
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:addItemNavController];
        /*
        CGSize size = CGSizeMake(300, 325);
        popover.popoverContentSize = size;
        */
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

- (void)editObject:(NSIndexPath *)indexPath
{
    // Create a new instance of the entity managed by the fetched results controller.
    
    if (![self.itemPopover isPopoverVisible]) {
        
        //Create the new TableView for the Popover
        AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        UINavigationController *addItemNavController = [[UINavigationController alloc] initWithRootViewController:aiTVC];
        //[addItemNavController.navigationBar setBarStyle:UIBarStyleBlack];
        [aiTVC setTitle:@"Edit Item"];
        
        //Capture the existing Parent
        
        aiTVC.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aiTVC.mainTableView = self.tableView;
        aiTVC.parentManagedObject = aiTVC.managedObject;
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:addItemNavController];
        /*
        CGSize size = CGSizeMake(300, 325);
        popover.popoverContentSize = size;
        */
        CGSize size = CGSizeMake(300, 325);
        [self setContentSizeForViewInPopover:size];
        popover.popoverContentSize = size;
        
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        aiTVC.popoverController = popover;
        [aiTVC.popoverController setDelegate:aiTVC];
        
    } 
    //NSLog(@"%@", indexPath.description);
    
    //Present the View
    [self.itemPopover presentPopoverFromRect:[ActionClass rectTopRightCorner:self.view]  inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


-(void)saveContext {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [ActionClass saveContext:context];
    
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self editObject:indexPath];

    }
}

-(void)dismissItemPopover {
    if ([self.itemPopover isPopoverVisible]) {
        [self.itemPopover dismissPopoverAnimated:YES];
    }
}
@end
