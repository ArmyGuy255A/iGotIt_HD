//
//  IPhoneItemViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import "IPhoneItemViewController.h"
#import "ControlExtras.h"


@implementation IPhoneItemViewController

@synthesize managedObject, parentManagedObject;
@synthesize mainTableView;
@synthesize notificationPanel;

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
    
    //setup toolbar
    [self setupToolbar];
    
    //setup navbar
    [self setupNavBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    //[self.navigationController setToolbarHidden:YES animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //fixes backbarbutton on navbar
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:INDEX00_TEXTBOX_TAG];
    [textField becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveContext];
    [self.mainTableView.tableView reloadData];
    
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
            textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 0.0, cell.frame.size.width - cell.frame.size.height - (25/*padding*/), cell.frame.size.height)];
            
            //Setting textField Done Editing action
            [textField setDelegate:self];
            [textField addTarget:self action:@selector(saveTextField:) forControlEvents:UIControlEventEditingDidEnd];
            [textField setBackgroundColor:[UIColor clearColor]];
            [textField setIndexPath:indexPath];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            //Create a UIButton for the makeFavorite function
            faveButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - cell.frame.size.height, 0.0, cell.frame.size.height, cell.frame.size.height)];
            [faveButton setBackgroundColor:[UIColor clearColor]];
            [faveButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            //Create an image for the favorites button
            UIImage *faveImage = [SettingsClass getThemeFavoriteButtonImage];
            UIImageView *iv = [[UIImageView alloc] initWithImage:faveImage];
            [iv setAutoresizesSubviews:YES];
            [iv setFrame:CGRectMake(0, 0, 35, 35)];
            
            [faveButton setShowsTouchWhenHighlighted:YES];
            
            [faveButton addTarget:self action:@selector(makeFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            //Set Tags
            [textField setTag:INDEX00_TEXTBOX_TAG];
            [faveButton setTag:INDEX00_BUTTON_TAG];
            //Add to content View
            [cell.contentView addSubview:textField];
            [cell.contentView addSubview:faveButton];
            [faveButton addSubview:iv];
            CGPoint fcenter = CGPointMake(faveButton.frame.size.height / 2, faveButton.frame.size.width / 2);
            [iv.layer setPosition:fcenter];
            
        } else if ((section == 0 && row == 1) || (section == 1 && row == 0)) {
            //DESC & CATEGORY TITLE TEXTBOX
            //Text Field Setup
            textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 0.0, cell.frame.size.width - 5.0, cell.frame.size.height)];
            [textField setDelegate:self];
            //Setting textField Done Editing action
            [textField addTarget:self action:@selector(saveTextField:) forControlEvents:UIControlEventEditingDidEnd];
            [textField setBackgroundColor:[UIColor clearColor]];
            [textField setIndexPath:indexPath];
            [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [textField setReturnKeyType:UIReturnKeyDone];
            if (section == 0 && row == 1) {
                [textField setTag:INDEX01_TEXTBOX_TAG];
            } else {
                [textField setTag:INDEX10_TEXTBOX_TAG];
            }
            
            [cell.contentView addSubview:textField];
        } else if (section == 1 && row == 1){
            //CATEGORY COLOR LABEL
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
#pragma mark - Custom Implementation
-(void)setupNavBar {
    [self setupRightBarButtons];
}

-(void)setupRightBarButtons {
    NSMutableArray *rightBBItems = [[NSMutableArray alloc] init];
    
    NSString *title = self.title;
    
    if ([title isEqualToString:@"New Item"]) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createAdditionalItem)];
        
        [rightBBItems insertObject:addButton atIndex:0];
    }    
    
    [self.navigationItem setRightBarButtonItems:rightBBItems animated:NO];
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
    
    if ([title isEqualToString:@"New Item"]) {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
        
        //UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createAdditionalItem)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        //[toolbarButtons addObject:addItem];
        //[toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
        
    } else if ([title isEqualToString:@"New List"]) {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
        
    } else if ([title isEqualToString:@"Edit Item"]) {
        
        deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteAction:)];
        
        [toolbarButtons addObject:deleteButton];
        [toolbarButtons addObject:flexItem];
        [toolbarButtons addObject:doneButton];
    }
    
    [self setToolbarItems:toolbarButtons animated:NO];
    //[self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    //[self.navigationController setToolbarHidden:NO animated:NO];
    
    [self setToolbarItems:toolbarButtons];
}


-(void)doneAction:(id)sender{
    [self validateTitle];
    [self.mainTableView.tableView reloadData];
    [self.navigationController popToViewController:self.mainTableView animated:YES];
}
-(void)cancelAction:(id)sender {
    if (managedObject != nil) {
        [self resignResponder];
        [[parentManagedObject managedObjectContext] deleteObject:managedObject];
        [self.navigationController popToViewController:self.mainTableView animated:YES];
    }
}

-(void)deleteAction:(id)sender {
    if (managedObject != nil) {
        
        [self resignResponder];
        BOOL result = [ModalAlert ask:@"Do you want to proceed with deleting this item?" title:@"Delete Item"];
        if (result == YES) {
            [[parentManagedObject managedObjectContext] deleteObject:managedObject];
            [self.navigationController popToViewController:self.mainTableView animated:YES];
        } else {
            [self.navigationController popToViewController:self.mainTableView animated:YES];
        }
    }
    
}

-(void)createAdditionalItem {
    [self validateTitle];
    
    //will always be a child
    [self resignResponder];
    [self saveContext];
    
    //Create the new TableView for the Popover
    IPhoneItemViewController *ipIVC = [[IPhoneItemViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //[ipIVC setHidesBottomBarWhenPushed:YES];
    [ipIVC setTitle:@"New Item"];

    //Create the new Child
    Child *newChild = [ActionClass createChildItem:@"" parentManagedObject:self.parentManagedObject];
    [newChild setOrder:[NSNumber numberWithInt:1000]];
    ipIVC.managedObject = newChild;
    ipIVC.parentManagedObject = self.parentManagedObject;
    ipIVC.mainTableView = self.mainTableView;
    
    [self.navigationController pushViewController:ipIVC animated:YES];
    
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
    
    UIView *colorGrid = [ActionClass createColorGrid:self action:@selector(setColor:) delegate:self];
    self.notificationPanel = [NotificationPanel notificationViewInView:self.tabBarController.view title:@"Select A Color" message:@"Colors will help easily identify your lists. \nUse them sparingly." withView:colorGrid];
    
    //show an action sheet
    
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Favorite Color" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Destructive" otherButtonTitles:nil, nil];
    
   
    
    UIView *colorGrid = [ActionClass createColorGrid:self action:@selector(setColor:) delegate:self];
    
    
    //[actionSheet addSubview:colorGrid];
    [colorGrid setFrame:CGRectMake(0, 10, 320, 320)];
    
    //[actionSheet setFrame:CGRectMake(actionSheet.frame.origin.x, actionSheet.frame.origin.y, actionSheet.frame.size.width, actionSheet.frame.size.height + colorGrid.frame.size.height)];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    //[actionSheet setBounds:CGRectMake(0, 0, 320, actionSheet.frame.size.height + colorGrid.frame.size.height)];
    
    NSEnumerator *e = [actionSheet.subviews objectEnumerator];
    UIView *subView;
    while (subView = [e nextObject]) {
        if ([[[subView class] description] isEqualToString:@"UIAlertButton"]) {
            //[subView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
            CGRect newFrame = CGRectMake(subView.frame.origin.x, 200, subView.frame.size.width, subView.frame.size.height);
            
            CGRect frame = subView.frame;
            CGRect bounds = subView.bounds;
            [subView setFrame:newFrame];
            NSLog(@"Boom");
        }
    }
    */
    
    
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
    [self.navigationController popToViewController:self.mainTableView animated:YES];
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
    IPhoneItemViewController *tv = (IPhoneItemViewController *)self.navigationController.topViewController;
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
            [self.mainTableView.tableView reloadData];
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



#pragma mark - Selectors

-(void)setColor:(UITapGestureRecognizer *)gesture{
    
    UIView *colorRect = (UIView *)[gesture view];
    UIColor *rectColor = [colorRect backgroundColor];
    
    //#warning Need a condition for saving "priColor"
    
    [managedObject setValue:rectColor forKey:@"catColor"];
    
    //Refresh the tableViews
    [self.mainTableView.tableView reloadData];
    [self.tableView reloadData];
    
    [self saveContext];
    //[mainTableView.mainTableView reloadData];
    
    [self.notificationPanel removePanel];
    
}

@end
