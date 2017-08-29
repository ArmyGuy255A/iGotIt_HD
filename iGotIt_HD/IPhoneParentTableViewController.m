//
//  IPhoneParentTableViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "IPhoneParentTableViewController.h"
#import "IPhoneChildTableViewController.h"
#import "IPhoneItemViewController.h"
#import "AddItemTableViewController.h"
#import "CustomCellBackground.h"
#import "ParentCell.h"
#import "ControlExtras.h"


@implementation IPhoneParentTableViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"TAB_LIST" ofType:@"png"];
        UIImage *tabBarItemImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
        UITabBarItem *tbi = [[UITabBarItem alloc] initWithTitle:@"" image:tabBarItemImage tag:1];
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
-(void)reloadView:(NSNotification*)notification {
    iGotIt_HDAppDelegate *delegate = AppDelegate;
    UITabBarController *tbc = (UITabBarController *)delegate.window.rootViewController;
    NSArray *navCons = [tbc viewControllers];
    NSEnumerator *n = [navCons objectEnumerator];
    UINavigationController *nvc;
    while (nvc = [n nextObject]) {
        //try to reload the tableViews of each view in the NVC's
        NSArray *tableViewControllers = [nvc viewControllers];
        NSEnumerator *v = [tableViewControllers objectEnumerator];
        UIView *view;
        while (view = [v nextObject]) {
            if ([[view class] isSubclassOfClass:[UITableViewController class]]) {
                UITableViewController *tvc = (UITableViewController *)view;
                [tvc.tableView reloadData];
            }
        }
    }
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

    [self.tableView setDelegate:self];
    [self setupNavBar];
    [self setupTabBar];
    
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
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ActionClass showHelpMenu:kParentHelpMenu];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [ActionClass hideHelpMenu:YES menuType:kParentHelpMenu];

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

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}
*/

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



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float sectionHeight = 30.0;
    
    id bgView = [[CustomCellBackground alloc] init];
    [bgView setTheBaseColor:[UIColor blackColor]];
    [bgView setTheStartColor:[UIColor lightGrayColor]];
    [bgView setTheEndColor:[UIColor blackColor]];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 400, 25)];
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
            break;
        case 1:
            [sectionLabel setText:@"Completed:"];
            break;
        default:
            break;
    }
    return bgView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
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
    //[bgView setTheEndColor:color2];
    //assign the backgroundView   
    cell.backgroundView = bgView;
}  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Create an instance of the selected object

    NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    IPhoneChildTableViewController *childTVC = [[IPhoneChildTableViewController alloc] init];
    [childTVC setManagedObject:selectedObject];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:nil action:nil];
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
            //NSLog(@"dtvc Insert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[self.tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:newIndexPath];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"dtvc Delete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //NSLog(@"dtvc Update");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            
            break;
            
        case NSFetchedResultsChangeMove:
            //NSLog(@"dtvc Move");
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

#pragma mark - Variable Initialization
-(NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController) {
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


#pragma mark - Custom Implementation
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
   
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
    mainLabel.text = [[managedObject valueForKey:@"title"] description];
    //SecondLabel
    secondLabel.text = [[managedObject valueForKey:@"desc"] description];
    
    
    
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
    BOOL isChecked = [[managedObject valueForKey:@"checked"] boolValue];
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

    
}
-(void)setupNavBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setBarStyle:UIBarStyleBlack];
    
    //insert 'add' button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    [self.navigationItem setRightBarButtonItem:addButton];
}
-(void)setupTabBar{
    
}

#pragma mark - Selectors
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

- (void)insertNewObject:(id)sender {
    
    //WORKING
    //Create the new TableView for the Popover
    IPhoneItemViewController *ipIVC = [[IPhoneItemViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [ipIVC setHidesBottomBarWhenPushed:YES];
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [ipIVC setTitle:@"New List"];
    
    //Create the new Parent
    //int x = self.fetchedResultsController.fetchedObjects.count;
    NSString *title = [NSString stringWithFormat:@""];
    Parent *newParent = [ActionClass createParent:title managedObjectContext:context];
    [ActionClass saveContext:self.managedObjectContext];
    ipIVC.managedObject = newParent;
    ipIVC.mainTableView = self;
    ipIVC.parentManagedObject = newParent;
    
    //Create the new Popover Controller
    //can I do this for the iPhone?

    
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
    
    //Create the new Popover Controller
    //can I do this for the iPhone?
    
    
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
