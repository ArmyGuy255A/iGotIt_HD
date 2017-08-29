//
//  AddItemTableViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "AddItemTableViewController.h"
#import "DetailTableViewController.h"
#import "ChildTableViewController.h"
#import "ColorGridViewController.h"
#import "NotificationView.h"
#import "CustomModalAlert.h"

#import "Parent.h"
#import "Child.h"
#import "ControlExtras.h"
#import "ActionClass.h"
#import "SettingsClass.h"

#import <CoreData/CoreData.h>

@implementation AddItemTableViewController

#define INDEX00_TEXTBOX_TAG 1
#define INDEX00_BUTTON_TAG 2
#define INDEX01_TEXTBOX_TAG 3
#define INDEX10_TEXTBOX_TAG 4
#define INDEX11_LABEL_TAG 5


@synthesize parentManagedObject;
@synthesize managedObject;
@synthesize mainTableView;
@synthesize popoverController, itemPopover;
NSManagedObjectContext *context;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //NSLog(@"------------AddItem TVC DID LOAD-----------");
    
    [super viewDidLoad];
    
    //setup toolbar
    [self setupToolbar];
    
    //setup navbar
    [self setupLeftBarButtons];
    
    //Set managedObjectContext
    context = [managedObject managedObjectContext];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    //Fixes the resize issue when you select "createAdditionalItem"
    CGSize size = CGSizeMake(300, 250);
    [self setContentSizeForViewInPopover:size];
   
    //fixes backbarbutton on navbar
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [super viewWillAppear:animated];
    
   
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"------------AddItem TVC DID APPEAR-----------");
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:INDEX00_TEXTBOX_TAG];
    [textField becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self saveContext];
    [self.mainTableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UILabel *sectionLabel = [[UILabel alloc] init];
    [sectionLabel setBackgroundColor:[UIColor clearColor]];
    [sectionLabel setShadowColor:[UIColor blackColor]];
    
    switch (section) {
        case 0:
            //Title and Desc
            [sectionLabel setText:@"  Basic Information:"];
            break;
        case 1:
            //Category Title and Number
            [sectionLabel setText:@"  Favorites Settings:"];
            break;
        case 2:
            //Date Start and End
            //[sectionLabel setText:@"  Dates:"];
            break;
        case 3:
            //Priority Color and Number
            //[sectionLabel setText:@"  Priority:"];
            break;
        default:
            break;
    }
    return sectionLabel;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGRect rect = CGRectMake(0.0, 0.0, 0.0, 25.0);
    return CGRectGetHeight(rect);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    switch (section) {
        case 0:
            //Title (Favorite built into title cell) and Description
            return 2;
            break;
        case 1:
            //Category Title and Number and Color
            return 2;
            break;
        case 2:
            //Date Start, End 
            return 2;
            break;
        case 3:
            //Priority Color and Number
            return 2;
            break;
        default:
            return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITextField *textField = nil;
    //UISlider *numberSlider = nil;
    UILabel *label = nil;
    UIButton *faveButton = nil;

    int section = indexPath.section;
    int row = indexPath.row;
    
    UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

        //Add sliders to the required indexes
        if (section == 0 && row == 0){  
            //TITLE & FAVEBUTTON
            textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 1.0, 230.0, 40)];
            
            //Setting textField Done Editing action
            [textField setDelegate:self];
            [textField addTarget:self action:@selector(saveTextField:) forControlEvents:UIControlEventEditingDidEnd];
            [textField setBackgroundColor:[UIColor clearColor]];
            [textField setIndexPath:indexPath];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            //Create a UIButton for the makeFavorite function
            faveButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 1.0, 40, 40)];
            [faveButton setBackgroundColor:[UIColor clearColor]];
            //Create an image for the favorites button
            //NSString *imagePath1 = [[NSBundle mainBundle] pathForResource:@"favoriteButton" ofType:@"png"];
            UIImage *faveImage = [SettingsClass getThemeFavoriteButtonImage];
            [faveButton setImage:faveImage forState:UIControlStateNormal];
            NSString *imagePath2 = [[NSBundle mainBundle] pathForResource:@"FAV_SEL" ofType:@"png"];
            UIImage *fileCopyPressed = [UIImage imageWithContentsOfFile:imagePath2];
            [faveButton setImage:fileCopyPressed forState:UIControlStateHighlighted];
            [faveButton setShowsTouchWhenHighlighted:YES];
            
            [faveButton addTarget:self action:@selector(makeFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            //Set Tags
            [textField setTag:INDEX00_TEXTBOX_TAG];
            [faveButton setTag:INDEX00_BUTTON_TAG];
            //Add to content View
            [cell.contentView addSubview:textField];
            [cell.contentView addSubview:faveButton];
            
            
        } else if ((section == 0 && row == 1) || (section == 1 && row == 0)) {
            //DESC & CATEGORY TITLE TEXTBOX
            //Text Field Setup
            textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 1.0, 270.0, 40)];
            [textField setDelegate:self];
            //Setting textField Done Editing action
            [textField addTarget:self action:@selector(saveTextField:) forControlEvents:UIControlEventEditingDidEnd];
            [textField setBackgroundColor:[UIColor clearColor]];
            [textField setIndexPath:indexPath];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            if (section == 0 && row == 1) {
                [textField setTag:INDEX01_TEXTBOX_TAG];
            } else {
                [textField setTag:INDEX10_TEXTBOX_TAG];
            }
            
            [cell.contentView addSubview:textField];
        } else if (section == 1 && row == 1){
            //CATEGORY COLOR LABEL
            label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 1.0, 270, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            //Set Tag
            [label setTag:INDEX11_LABEL_TAG];
            //Add to content View
            [cell.contentView addSubview:label];
            
        } 
        
    } else {
        
        //Cells already exist. Get the contents of them
      
        if (section == 0) {
            if (row == 0) {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX00_TEXTBOX_TAG];
                [textField setText:@""];
                //faveButton = (UIButton *)[cell.contentView viewWithTag:INDEX00_BUTTON_TAG];
            } else if (row == 1) {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX01_TEXTBOX_TAG];
                [textField setText:@""];
            }
            
        } else if (section == 1) {
            if (row == 0) {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX10_TEXTBOX_TAG];
                [textField setText:@""];
            } else if (row == 1) {
                label = (UILabel *)[cell.contentView viewWithTag:INDEX11_LABEL_TAG];
            }
        } 
    }
    
    //////////////////////////////////////////
    //Disable the selection style for all cells
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (managedObject != nil) {
        switch (section) {
            case 0:
                if (row == 0) {
                    //Title (Favorite built into title cell) and Description
                    [textField setText:[managedObject valueForKey:@"title"]];
                    [textField setPlaceholder:@"Title"];
                    //Favorite Star
                    bool fave = [[managedObject valueForKey:@"favorite"] boolValue];
                    if (fave == YES) {
                        //[faveButton setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>];
                        //[faveButton setBackgroundColor:[UIColor yellowColor]];
                    } else {
                    
                        //[faveButton setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>];
                        //[faveButton setBackgroundColor:[UIColor grayColor]];
                    }
                    
                } else {
                    [textField setText:[managedObject valueForKey:@"desc"]];
                    [textField setPlaceholder:@"Description"];
                }
                break;
            case 1:
                //Category Title and Number
                if (row == 0) {
                    [textField setText:[managedObject valueForKey:@"catTitle"]];
                    [textField setPlaceholder:@"Category"];
                } else if (row == 1) {
                    [label setText:@"Tap to change Item Color."];
                    [label setTextAlignment:UITextAlignmentCenter];
                    UIColor *catColor = [managedObject valueForKey:@"catColor"];
                    [cell setBackgroundColor:catColor];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
                }
                break;
        }
    }

    return cell;
}

#pragma mark - Custom Implementation
-(void)setupLeftBarButtons {
    
    NSMutableArray *leftBBItems = [self.navigationItem.leftBarButtonItems mutableCopy];
    [leftBBItems removeAllObjects];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createAdditionalItem)];
    [leftBBItems insertObject:addItem atIndex:0];
    
    self.navigationItem.leftBarButtonItems = leftBBItems;
     
}

-(void)setupToolbar {
    NSString *title = self.title;
    
    if (self.toolbarItems.count != 0) {
        return;
    }
    
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
    //Use this to put space in between the toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)];
    UIBarButtonItem *deleteButton;
    
    if (title == @"New Item") {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
        
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createAdditionalItem)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:addItem];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
        
    } else if (title == @"New List") {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
        
    } else if (title == @"Edit Item") {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction:)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
    }
    
    [self setToolbarItems:toolbarButtons animated:NO];
    //[self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    [self setToolbarItems:toolbarButtons];
}

-(void)doneAction:(id)sender{
    [self validateTitle];
    [self.popoverController dismissPopoverAnimated:YES];
}
-(void)cancelAction:(id)sender {
    if (managedObject != nil) {
        [self resignResponder];
        [context deleteObject:managedObject];
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

-(void)deleteAction:(id)sender {
   if (managedObject != nil) {
       
       [self resignResponder];
       BOOL result = [ModalAlert ask:@"Do you want to proceed with deleting this item?" title:@"Delete Item"];
       if (result == YES) {
           [context deleteObject:managedObject];
           [self.popoverController dismissPopoverAnimated:YES];
        } else {
           [self.popoverController dismissPopoverAnimated:YES];
       }
    }
    
}

-(void)createAdditionalItem {
    [self validateTitle];
    
    //will always be a child
    [self resignResponder];
    [self saveContext];
    
    AddItemTableViewController *aiTVC = [[AddItemTableViewController alloc] initWithNibName:@"AddItemTableViewController" bundle:nil];
    
    [aiTVC setTitle:@"New Item"];
    
    //Create the new Child
    Child *newChild = [ActionClass createChildItem:@"" parentManagedObject:self.parentManagedObject];
    [newChild setOrder:[NSNumber numberWithInt:1000]];
    aiTVC.managedObject = newChild;
    aiTVC.parentManagedObject = self.parentManagedObject;
    aiTVC.mainTableView = self.mainTableView;
    aiTVC.popoverController = self.popoverController;
    
    [self.navigationController pushViewController:aiTVC animated:YES];
    
}

-(void)resignResponder {
    //set the first text field as the first responder then dismiss it.
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    UITextField *textField = (UITextField *)[cell viewWithTag:INDEX00_TEXTBOX_TAG];
    
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    
}

-(void)showColorPallette:(id)sender {
    
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    if (![self.itemPopover isPopoverVisible]) {
    
        //Create the new View for the Popover
        ColorGridViewController *colorViewController = [[ColorGridViewController alloc] init];
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:colorViewController];
        CGRect box = CGRectMake(0, 0, 155, 185);
        popover.popoverContentSize = box.size;
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        colorViewController.popoverController = popover;
        colorViewController.managedObject = self.managedObject;
        colorViewController.mainTableView = self.mainTableView;
        colorViewController.aiTV = self.tableView;
    
    } 

    //Present the View
    [self.itemPopover presentPopoverFromRect:cell.bounds inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    [cell setSelected:NO];

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
    [self saveContext];   
    [self.popoverController dismissPopoverAnimated:YES];
}
-(void)makeFavorite:(id)sender{
    [self resignResponder];
    NotificationView *nView;
    //if title is empty, abort the procedure
    NSString *title = [managedObject valueForKey:@"title"];
    if ([title isEqualToString:@""] || title == nil) {
        //NSLog(@"Aborting Operation Clone");
        nView = [NotificationView notificationViewInView:self.view.window notificationMessage:@"Clone Aborted." withIndicator:NO];
        
        [nView performSelector:@selector(removeView) withObject:nil afterDelay:2.0];
        return;
    }
    
    //Sometimes this operation takes a few seconds. Show an indicator
    nView = [NotificationView notificationViewInView:self.view.window notificationMessage:@"Adding to Favorites ..." withIndicator:YES];
    
    [self performSelector:@selector(performClone:) withObject:nView afterDelay:0.2];
    
}



-(void)saveTextField:(id)sender {
    UITextField *theTextField = sender;
    
    int section = theTextField.indexPath.section;
    int row = theTextField.indexPath.row;
    
    if (section == 0 && row == 0) {
        [self.managedObject setValue:theTextField.text forKey:@"title"];
        //NSLog(@"saving title");
    } else if (section == 0 && row == 1) {
        [self.managedObject setValue:theTextField.text forKey:@"desc"];
        //NSLog(@"saving description");
    } else if (section == 1 && row == 0) {
        [self.managedObject setValue:theTextField.text forKey:@"catTitle"];
        //NSLog(@"saving cat title");
    }
    
    [self saveContext];
    
}

-(void)validateTitle {
    //check the first textfield to see if text exists.
    
    //get the correct tableView
    AddItemTableViewController *tv = (AddItemTableViewController *)self.navigationController.topViewController;
    //get the title row
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //get the title cell
    UITableViewCell *cell = [tv.tableView cellForRowAtIndexPath:indexPath];
    //get the title textField
    UITextField *textField = (UITextField *)[cell viewWithTag:INDEX00_TEXTBOX_TAG];
    if ([textField.text isEqualToString:@""]) {
        BOOL delete = [ModalAlert ask:@"The title is required.\n Do you want to DELETE the item?" title:@"Blank Title"];
        if (managedObject != nil && delete == YES) {
            [self resignResponder];
            NSManagedObjectContext *context = managedObject.managedObjectContext;
            [context deleteObject:managedObject];
        }
    }    
}

-(void)saveContext {
    NSManagedObjectContext *context = [parentManagedObject managedObjectContext];
    if (context != nil) {
        [ActionClass saveContext:context];
        if (managedObject != nil && mainTableView != nil) {
            [mainTableView reloadData];
        }
    }
}



#pragma mark - Table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    int section = indexPath.section;
    int row = indexPath.row;

    if (section == 1 && row == 1) {
        [self resignResponder];
        [self performSelector:@selector(showColorPallette:) withObject:cell afterDelay:0.3];
      
    }
    
    
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
  
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

}

//input validation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength <= 100) ? YES : NO;
}

#pragma mark - popoverController delegate
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    //Called when the user taps outside the popover
    [self validateTitle];
    return YES;
}

@end

