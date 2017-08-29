//
//  IPhoneChildTableViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "IPhoneChildTableViewController.h"
#import "IPhoneItemViewController.h"
#import "ParentCell.h"
#import "CustomCellBackground.h"
#import "CustomBarButtonItem.h"
#import "UIVerticalToolBar.h"



@implementation IPhoneChildTableViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObject;
@synthesize editButtonItemCustom = __editButtonItemCustom;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
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

    //Additional taleView initializaiton
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    [self.fetchedResultsController setDelegate:self];
    
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
    
    
    [self setupNavBar];
    [self setupTabBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
#pragma mark - TODO 
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    // Setup Toolbar

    [self setupToolbar];

    // Setup RightBarButtons
    //[self setupRightBarButtons];
    

}
#pragma mark - 
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[ActionClass showHelpMenu:kChildHelpMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
    //[ActionClass hideHelpMenu:YES menuType:kChildHelpMenu];
    self.fetchedResultsController = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
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
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ParentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ParentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        [ActionClass saveContext:self.managedObjectContext];
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
            } else {
                //increment everything else by one
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:i + 1]];
            }
        } else if (toIndex > fromIndex) {
            if (i == fromIndex && toIndex > fromIndex) {
                //original item, set its index to the finish
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:finish]];
            } else {
                //decrement everything else by one
                item = [fetchedResults objectAtIndex:i];
                [item setOrder:[NSNumber numberWithInt:i - 1]];
            }
        }
    }
    
    [ActionClass saveContext:self.managedObjectContext];
    
}

#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float sectionHeight = 30.0;
    
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
    
    //checkbox
    UIButton *checkBox = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 35)];
    [checkBox setBackgroundColor:[UIColor clearColor]];
    [checkBox setShowsTouchWhenHighlighted:YES];
    [bgView addSubview:checkBox];
    NSString *imagePath;    
    UIImage *theImage;
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkBox.frame.size.width - 5, 0, 400, 25)];
    [sectionLabel.layer setPosition:CGPointMake(sectionLabel.layer.position.x, sectionHeight / 2)];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [sectionLabel setTextColor:[UIColor whiteColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    [bgView addSubview:sectionLabel];
    
    
    
    NSString *value = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    NSInteger intValue = [value integerValue];
    
    
    switch (intValue) {
        case 0:
            [sectionLabel setText:@"In-Progress:"];
            [checkBox addTarget:self action:@selector(checkAll) forControlEvents:UIControlEventTouchUpInside];
            theImage = [SettingsClass getThemeCheckBoxAllImage];
            break;
        case 1:
            [sectionLabel setText:@"Completed:"];
            [checkBox addTarget:self action:@selector(uncheckAll) forControlEvents:UIControlEventTouchUpInside];
            imagePath = [[NSBundle mainBundle] pathForResource:@"UNCHK_ALL" ofType:@"png"];
            theImage = [UIImage imageWithContentsOfFile:imagePath];
            break;
        default:
            break;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:theImage];
    [imageView setFrame:CGRectMake(14,2.5,25,25)];
    [checkBox addSubview:imageView];
    
    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect box = CGRectMake(0.0, 0.0, 0.0, 30.0);
    return box.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get the managedObject color
    UIColor *color = [[self.fetchedResultsController objectAtIndexPath:indexPath] valueForKey:@"catColor"];
    //Create the gradient background
    id bgView = [[CustomCellBackground alloc] init];
    //Set the start and end colors of the gradient
    [bgView setTheBaseColor:color];
    //assign the backgroundView   
    cell.backgroundView = bgView;
} 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create an instance of the selected object
    
    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    IPhoneChildTableViewController *childTVC = [[IPhoneChildTableViewController alloc] init];
    [childTVC setManagedObject:selectedObject];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:bbi];  
    
    [self.navigationController pushViewController:childTVC animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    
    
    
    [cell setSelected:NO];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //Hide the thirdLabel when the delete button appears.
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:THIRDLABEL_TAG];
    CABasicAnimation *anim = [CoreAnimation opacityAnimation:1.0 toValue:0.0 duration:0.25];
    [thirdLabel.layer addAnimation:anim forKey:@"opacity"];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:THIRDLABEL_TAG];
    CABasicAnimation *anim = [CoreAnimation opacityAnimation:0.0 toValue:1.0 duration:0.25];
    [thirdLabel.layer addAnimation:anim forKey:@"opacity"];
}

#pragma mark - Fetched Results Controller Delegate

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
            [self configureCell:[self.tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:newIndexPath];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"dtvc Delete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"dtvc Update");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            
            break;
            
        case NSFetchedResultsChangeMove:
            NSLog(@"dtvc Move");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[self.tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:newIndexPath];
            [self.tableView reloadData];
            break;
    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    Child *child;
    if (buttonIndex == 0) {
        child = (Child *)self.managedObject;
        [child setSortValue:[NSNumber numberWithInt:0]];
        UIBarButtonItem *button = [self.toolbarItems objectAtIndex:0];
        [self renameSortButton:button];
        [ActionClass saveContext:self.managedObjectContext];
        
    }
    
    self.fetchedResultsController = nil;
    __fetchedResultsController = nil;
    //NSLog(@"Reloading TV - toggleAutoNumbering");
    [self.tableView reloadData];
    
    
}

#pragma mark - Variable Initialization
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    __managedObjectContext = [managedObject managedObjectContext];
    return __managedObjectContext;
}
- (NSFetchedResultsController *)fetchedResultsController
{
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
	   [ActionClass showCoreDataError];
	}
    //NSLog(@"========Exit Child TVC FRC========");
    return __fetchedResultsController;
} 

#pragma mark - Custom Implementation

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *managedObj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    UILabel *mainLabel = (UILabel *)[cell viewWithTag:MAINLABEL_TAG];
    UILabel *secondLabel = (UILabel *)[cell viewWithTag:SECONDLABEL_TAG];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:THIRDLABEL_TAG];
    UIButton *checkBox = (UIButton *)[cell viewWithTag:CHECKBOX_TAG];
    
    
    //Add touch to hold gesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longPressGesture setMinimumPressDuration:0.75];
    longPressGesture.delegate = self;
    [cell addGestureRecognizer:longPressGesture];
    
    //MainLabel
    BOOL autoNumbering = [[self.managedObject valueForKey:@"autoNumberValue"] boolValue];
    if (autoNumbering == 1) {
        NSString *moTitle = [[managedObj valueForKey:@"title"] description];
        mainLabel.text = [NSString stringWithFormat:@"%i - %@",indexPath.row + 1,moTitle];
    } else if (autoNumbering == 0) {
        mainLabel.text = [[managedObj valueForKey:@"title"] description];
    }
    
    //SecondLabel
    secondLabel.text = [[managedObj valueForKey:@"desc"] description];
    
    
    //Center the mainLabel if the secondlabel is empty
    if ((secondLabel.text == nil) || (secondLabel.text == [NSString stringWithFormat:@""])) {
        [secondLabel setHidden:YES];
        CGRect mainLabelFrame = CGRectMake(secondLabel.frame.origin.x, secondLabel.frame.origin.y - (secondLabel.frame.size.height / 2), secondLabel.frame.size.width, secondLabel.frame.size.height);
        [mainLabel setFrame:mainLabelFrame];
    } else {
        [secondLabel setHidden:NO];
        CGRect mainLabelFrame = CGRectMake(secondLabel.frame.origin.x, 0, secondLabel.frame.size.width, secondLabel.frame.size.height);
        [mainLabel setFrame:mainLabelFrame];    
    }
    
    ///////////////////////////////////////////////////
    //Setting Third Label
    ///////////////////////////////////////////////////
    //Get children item count
    NSSet *children = [managedObj valueForKey:@"children"];
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
        thirdLabel.text = [NSString stringWithFormat:@"Completed: \n%i of %d",completedChildren, children.count];
    }
    
    
    ///////////////////////////////////////////////////
    //Setting Check Box
    ///////////////////////////////////////////////////
    //Capture indexPath for the action
    [checkBox setIndexPath:indexPath];
    //Set action
    [checkBox addTarget:self action:@selector(tableViewCheckBox:) forControlEvents:UIControlEventTouchUpInside];
    //Determine if managedObjec is checked
    BOOL isChecked = [[managedObj valueForKey:@"checked"] boolValue];
    float imgHW = 30;
    //Set appropriate image
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
    } else if (isChecked == NO) {
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"CHK_BOX" ofType:@"png"];
        UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *iv = [[UIImageView alloc] initWithImage:theImage];
        [iv setAutoresizesSubviews:YES];
        [iv setFrame:CGRectMake(0,0,imgHW, imgHW)];
        [checkBox addSubview:iv];
        [iv.layer setPosition:checkBox.layer.position];
    }
    ///////////////////////////////////////////////////
    
    
}

-(void)setupNavBar {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self setupRightBarButtons];
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

-(void)setupTabBar{
    
}
#pragma mark - Toolbar Setup

/*
-(void)setupToolbar {
    UIVerticalToolBar *toolBar = [[UIVerticalToolBar alloc] init];
    
    //Set the toolBar Items
    
    
    //Set the position and add to the screen
    iGotIt_HDAppDelegate *delegate = AppDelegate;
    UITabBarController *rootViewController = (UITabBarController *)delegate.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)[[rootViewController viewControllers] objectAtIndex:1];
    
    //Display from the top right of the tab bar.
    [toolBar displayFrom:zTopRight ofView:rootViewController.view target:self];
    
}
 */
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
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    
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
    [ActionClass saveContext:self.managedObjectContext];
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
    
    [ActionClass saveContext:self.managedObjectContext];
    
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

#pragma mark - 

-(void)makeFavorite:(id)sender{
    
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

-(void)performClone:(id)sender {
    //Item will always become a parent. No matter what!
    
    NotificationView *nView = sender;
    
    NSString *moClass = [[managedObject class] description];
    
    Parent *mo;
    if ([moClass isEqualToString:@"Child"]) {
        //Item is a child - Clone, Convert, Delete
        Child *cmo = (Child *)[ActionClass cloneManagedObject:managedObject];
        mo = [ActionClass convertChildToParent:cmo];
        [mo setPermanentID:[cmo permanentID]];
        [[mo managedObjectContext] deleteObject:cmo];
        
    } else {
        //Item is a parent
        mo = (Parent *)[ActionClass cloneManagedObject:managedObject];
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
    [ActionClass saveContext:self.managedObjectContext];   
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
    
    [ActionClass saveContext:self.managedObjectContext];
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


- (void)insertNewObject:(id)sender {
    
    //WORKING
    //Create the new TableView for the Popover
    IPhoneItemViewController *ipIVC = [[IPhoneItemViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //[ipIVC setHidesBottomBarWhenPushed:YES];
    [ipIVC setTitle:@"New Item"];
    
    //Create the new Item
    NSString *title = [NSString stringWithFormat:@""];
    Child *newParent = [ActionClass createChildItem:title parentManagedObject:self.managedObject];
    [ActionClass saveContext:self.managedObjectContext];
    ipIVC.managedObject = newParent;
    ipIVC.mainTableView = self;
    ipIVC.parentManagedObject = self.managedObject;
    
    //Create the new Popover Controller
    //Present the View
    [self.navigationController pushViewController:ipIVC animated:YES];
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
    
    //Present the View
    [self.navigationController pushViewController:ipIVC animated:YES];
}

-(void)longPress:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)[gesture view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self editObject:indexPath];
        
    }
}
@end
