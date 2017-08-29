//
//  AddItemTableViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 8/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddItemTableViewController.h"
#import "DetailTableViewController.h"
#import "ChildTableViewController.h"
#import "ColorGridViewController.h"

#import "Parent.h"
#import "Child.h"
#import "ControlExtras.h"
#import "ActionClass.h"
#import <CoreData/CoreData.h>

@implementation AddItemTableViewController

#define INDEX00_TEXTBOX_TAG 1
#define INDEX00_BUTTON_TAG 2
#define INDEX01_TEXTBOX_TAG 3
#define INDEX10_LABEL_TAG 4
#define INDEX11_LABEL_TAG 5
#define INDEX20_TEXTBOX_TAG 6
#define INDEX21_SLIDER_TAG 7
#define INDEX21_LABEL_TAG 8
#define INDEX22_LABEL_TAG 9
#define INDEX30_LABEL_TAG 10
#define INDEX31_SLIDER_TAG 11
#define INDEX31_LABEL_TAG 12


@synthesize parentManagedObject;
@synthesize managedObject;
@synthesize mainTableView;
@synthesize popoverController, itemPopover;

NSNumberFormatter *sliderValueFormatter;
NSDateFormatter *dateFormat;

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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"------------AddItem TVC DID LOAD-----------");
    
    [super viewDidLoad];
    sliderValueFormatter = [[NSNumberFormatter alloc] init];
    [sliderValueFormatter setMaximumFractionDigits:0];
    
    //Date Formatter for the dates
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM d, YYYY - hh:mm:ss a"];
    
    
    /////////////////////
    //Setup Toolbar
    /////////////////////
    //Setup the toolbar
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];

    toolbarButtons = [self.toolbarItems mutableCopy];
    self.toolbarItems = nil;
    
    int x = 0;
    for (x=0; x < toolbarButtons.count; x++) {
        UIBarButtonItem * barButton = [toolbarButtons objectAtIndex:x];
        if (barButton.title == @"Delete") {
            [barButton setTarget:self];
            [barButton setAction:@selector(deleteAction:)];
            
        } else if (barButton.title == @"Done") {
            [barButton setTarget:self];
            [barButton setAction:@selector(doneAction:)];
        }

    }
    [self setToolbarItems:toolbarButtons];
    //////////////////////
    
    //reload the main tableView
    [mainTableView reloadData];
    
    
    
}

-(void)doneAction:(id)sender{
    
    [self.popoverController dismissPopoverAnimated:YES];
}

-(void)deleteAction:(id)sender {
    //Show an action sheet to confirm the delete
    //NSLog(@"preToolbar position: %@", [self.navigationController.toolbar bounds]);
    if (managedObject != nil) {
        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:@"Do you want to proceed with deleting this item?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Proceed" otherButtonTitles:nil];
        [confirm setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        UIBarButtonItem *deleteButton = [self.toolbarItems objectAtIndex:2];
        [confirm showFromBarButtonItem:deleteButton animated:YES];
        
    }
   
}



- (void)viewDidUnload
{
    NSLog(@"------------AddItem TVC DID UNLOAD-----------");
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"------------AddItem TVC WILL APPEAR-----------");
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"------------AddItem TVC DID APPEAR-----------");
    
    [super viewDidAppear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:INDEX00_TEXTBOX_TAG];
    [textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"------------AddItem TVC WILL DISAPPEAR-----------");
    
    [self saveContext];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"------------AddItem TVC DID DISAPPEAR-----------");
    
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
/////////warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
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
            //Date Start and End
            [sectionLabel setText:@"  Dates:"];
            break;
        case 2:
            //Category Title and Number
            [sectionLabel setText:@"  Category:"];
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
            //Date Start, End
            return 2;
            break;
        case 2:
            //Category Title and Number and Color
            return 3;
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
    UISlider *numberSlider = nil;
    UILabel *label = nil;
    UIButton *faveButton = nil;
    

   
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    UITableViewCell *cell;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
       
       
        //Add sliders to the required indexes
        if (section == 0 && row == 0){  
            textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 1.0, 230.0, 40)];
            //Setting textField Done Editing action
            [textField setDelegate:self];
            [textField addTarget:self action:@selector(saveTextField:) forControlEvents:UIControlEventEditingDidEnd];
            [textField setBackgroundColor:[UIColor clearColor]];
            [textField setIndexPath:indexPath];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            
            //Create a UIButton for the star
            faveButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 1.0, 40, 40)];
            [faveButton setBackgroundColor:[UIColor grayColor]];
            [faveButton addTarget:self action:@selector(makeFavorite:) forControlEvents:UIControlEventTouchUpInside];
            
            //Set Tags
            [textField setTag:INDEX00_TEXTBOX_TAG];
            [faveButton setTag:INDEX00_BUTTON_TAG];
            //Add to content View
            [cell.contentView addSubview:textField];
            [cell.contentView addSubview:faveButton];
            
            
        } else if (section == 1) { 
#warning Set a datePicker for the date fields
            label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 1.0, 270, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            
            //ADD TAGS
            if (row == 0) {
                [label setTag:INDEX10_LABEL_TAG];
            } else {
                [label setTag:INDEX11_LABEL_TAG];
            }
            //Add to content View
            [cell.contentView addSubview:label];
            
        } else if ((section == 2 /*|| section == 3*/) && row == 1) {
            //UISlider Setup
            numberSlider = [[UISlider alloc] initWithFrame:CGRectMake(5.0, 1.0, 200.0, 40)];
            //Setting slider label updates action
            [numberSlider addTarget:self action:@selector(updateSliderLabel:) forControlEvents:UIControlEventValueChanged];
            [numberSlider addTarget:self action:@selector(saveSliderValue:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
            
            [numberSlider setIndexPath:indexPath];
            [numberSlider setMinimumValue:0.0];
            [numberSlider setMaximumValue:1.0];
            [numberSlider setBackgroundColor:[UIColor clearColor]];
            
            //Associated Label
            label = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 1.0, 50.0, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            
            //Set Tags
            if (section == 2) {
                [label setTag:INDEX21_LABEL_TAG];
                [numberSlider setTag:INDEX21_SLIDER_TAG];
            } else {
                [label setTag:INDEX31_LABEL_TAG];
                [numberSlider setTag:INDEX31_SLIDER_TAG];
            }
            
            //Add to SubView
            [cell.contentView addSubview:numberSlider];
            [cell.contentView addSubview:label];
            
        }  else if (section == 2 && row == 2){
            label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 1.0, 270, 40)];
            [label setBackgroundColor:[UIColor clearColor]];
            //Set Tag
            [label setTag:INDEX22_LABEL_TAG];
            //Add to content View
            [cell.contentView addSubview:label];
            
            //Disable the selection style for this cell
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if ((section == 0 && row == 1) || (section == 2 && row == 0)) {
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
                [textField setTag:INDEX20_TEXTBOX_TAG];
            }
            
            [cell.contentView addSubview:textField];
        }
        
    } else {
        
        //Cells already exist. Get the contents of them
      
        if (section == 0) {
            if (row == 0) {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX00_TEXTBOX_TAG];
                faveButton = (UIButton *)[cell.contentView viewWithTag:INDEX00_BUTTON_TAG];
            } else {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX01_TEXTBOX_TAG];
            }
            
        } else if (section == 1) {
            if (row == 0) {
                label = (UILabel *)[cell.contentView viewWithTag:INDEX10_LABEL_TAG];
            } else {
                label = (UILabel *)[cell.contentView viewWithTag:INDEX11_LABEL_TAG];
            }
        } else if (section == 2) {
            if (row == 0) {
                textField = (UITextField *)[cell.contentView viewWithTag:INDEX20_TEXTBOX_TAG];
            } else if (row == 1) {
                numberSlider = (UISlider *)[cell.contentView viewWithTag:INDEX21_SLIDER_TAG];
                label = (UILabel *)[cell.contentView viewWithTag:INDEX21_LABEL_TAG];
            } else if (row == 2) {
                 label = (UILabel *)[cell.contentView viewWithTag:INDEX22_LABEL_TAG];
            }
        } else if (section == 3) {
            /*
            if (row == 0) {
                label = (UILabel *)[cell.contentView viewWithTag:INDEX30_LABEL_TAG];
            } else {
                numberSlider = (UISlider *)[cell.contentView viewWithTag:INDEX31_SLIDER_TAG];
                label = (UILabel *)[cell.contentView viewWithTag:INDEX31_LABEL_TAG];
                
            }
             */
        }
    }
    
    //////////////////////////////////////////
   
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
                        [faveButton setBackgroundColor:[UIColor yellowColor]];
                    } else {
                    
                        //[faveButton setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>];
                        [faveButton setBackgroundColor:[UIColor grayColor]];
                    }
                    
                } else {
                    [textField setText:[managedObject valueForKey:@"desc"]];
                    [textField setPlaceholder:@"Description"];
                }
                break;
            case 1:
                //Date Start, End
                if (row == 0) {
                    [label setText:[dateFormat stringFromDate:[managedObject valueForKey:@"dateStart"]]];
                } else {
                    [label setText:[dateFormat stringFromDate:[managedObject valueForKey:@"dateEnd"]]];
                }
                break;
            case 2:
                //Category Title and Number
                if (row == 0) {
                    [textField setText:[managedObject valueForKey:@"catTitle"]];
                    [textField setPlaceholder:@"Category Title"];
                } else if (row == 1) {
                    //id catNumber = [managedObject valueForKey:@"catNumber"];
                    
                    float catNumberFloat = [[managedObject valueForKey:@"catNumber"] floatValue];
                    [numberSlider setValue:catNumberFloat];
                    [label setText:[NSString stringWithFormat:@"%@", [sliderValueFormatter stringFromNumber:[NSNumber numberWithFloat:numberSlider.value * 10]]]];
                } else if (row == 2) {
                    [label setText:@"Tap to select a Category Color."];
                    [label setTextAlignment:UITextAlignmentCenter];
                    
                    UIColor *catColor = [managedObject valueForKey:@"catColor"];
                    [cell setBackgroundColor:catColor];
                }
                break;
            case 3:
                //Priority Color and Number
                /*
                if (row == 0) {
                    [label setText:@"Tap to select a Priority Color."];
                    [label setTextAlignment:UITextAlignmentCenter];
                 
                    UIColor *priColor = [managedObject valueForKey:@"priColor"];
                    [cell setBackgroundColor:priColor];
                    
                } else {
                    float priNumberFloat = [[managedObject valueForKey:@"priNumber"] floatValue];
                    [numberSlider setValue:priNumberFloat];
                    [label setText:[NSString stringWithFormat:@"%@", [sliderValueFormatter stringFromNumber:[NSNumber numberWithFloat:numberSlider.value * 10]]]];
                }
                 */
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Custom Implementation
-(void)showColorPallette:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    if (![self.itemPopover isPopoverVisible]) {
    
        //Create the new TableView for the Popover
        ColorGridViewController *colorViewController = [[ColorGridViewController alloc] init];
        //NSManagedObjectContext *context = [self.managedObject managedObjectContext];
        
        //Create the new Popover Controller
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:colorViewController];
        CGRect box = CGRectMake(0, 0, 155, 185);
        popover.popoverContentSize = box.size;
        
        //Set the class property to eliminate recursive lookups
        self.itemPopover = popover;
        colorViewController.popoverController = popover;
        colorViewController.managedObject = self.managedObject;
        colorViewController.mainTableView = self.tableView;
    
    } 

    //Present the View
    [self.itemPopover presentPopoverFromRect:cell.bounds inView:cell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    [cell setHighlighted:NO];

}


-(void)updateSliderLabel:(id)sender{
    NSLog(@"Update Slider Label");
    UISlider *theSlider = sender;
    id sliderValue = [theSlider valueForKeyPath:@"value"];
    int section = theSlider.indexPath.section;
    int row = theSlider.indexPath.row;
    UILabel *theLabel;
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:theSlider.indexPath];
    if (section == 2 && row == 1) {
        theLabel = (UILabel *)[cell.contentView viewWithTag:INDEX21_LABEL_TAG];
        //[self.managedObject setValue:sliderValue forKey:@"catNumber"];
    } else if (section == 3 && row == 1) {
        theLabel = (UILabel *)[cell.contentView viewWithTag:INDEX31_LABEL_TAG];
        //[self.managedObject setValue:sliderValue forKey:@"priNumber"];
    }
    
    [theLabel setText:[NSString stringWithFormat:@"%@", [sliderValueFormatter stringFromNumber:[NSNumber numberWithFloat:theSlider.value * 10]]]];
    
    //[self saveContext];
}

-(void)saveSliderValue:(id)sender{
    NSLog(@"Save Slider Label");
    UISlider *theSlider = sender;
    id sliderValue = [theSlider valueForKeyPath:@"value"];
    int section = theSlider.indexPath.section;
    int row = theSlider.indexPath.row;
    UILabel *theLabel;
    
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:theSlider.indexPath];
    if (section == 2 && row == 1) {
        theLabel = (UILabel *)[cell.contentView viewWithTag:INDEX21_LABEL_TAG];
        [self.managedObject setValue:sliderValue forKey:@"catNumber"];
    } else if (section == 3 && row == 1) {
        theLabel = (UILabel *)[cell.contentView viewWithTag:INDEX31_LABEL_TAG];
        [self.managedObject setValue:sliderValue forKey:@"priNumber"];
    }
    
    [theLabel setText:[NSString stringWithFormat:@"%@", [sliderValueFormatter stringFromNumber:[NSNumber numberWithFloat:theSlider.value * 10]]]];
    
    [self saveContext];
}

-(void)makeFavorite:(id)sender{
    //The objective is to copy the object and set it as a favorite.
    //It should be converted to a parent if it is a child.
    
    NSString *moClass = [[managedObject class] description];
    
    if ([moClass isEqualToString:@"Child"]) {
        //Item is a child
        Child *cmo = (Child *)[ActionClass cloneManagedObject:managedObject];
        //No parent ID.
        
        Parent *mo = [ActionClass convertChildToParent:cmo];
        [mo setID:@"0x6969"];
        //[mo setParentID:@""];
        [mo setFavorite:[NSNumber numberWithBool:YES]];
        
        //delete the old cmo
        NSManagedObjectContext *context = [cmo managedObjectContext];
        [context deleteObject:cmo];
        //Convert to a Parent Item
    } else {
        //Item is a parent
        Parent *mo = (Parent *)[ActionClass cloneManagedObject:managedObject];
        //No parent ID.
        [mo setID:@"0x6969"];
        [mo setFavorite:[NSNumber numberWithBool:YES]];
    }
        
    
    /*
    UIButton *faveButton = sender;
    BOOL fave = [[managedObject valueForKey:@"favorite"] boolValue];
    
    if (fave == YES) {
        [managedObject setValue:[NSNumber numberWithBool:NO] forKey:@"favorite"];
        [faveButton setBackgroundColor:[UIColor grayColor]];
    } else if (fave == NO) {
        [managedObject setValue:[NSNumber numberWithBool:YES] forKey:@"favorite"];
        [faveButton setBackgroundColor:[UIColor yellowColor]];
    }
    */
    [self saveContext];    
}

-(void)saveTextField:(id)sender {
    UITextField *theTextField = sender;
    
    int section = theTextField.indexPath.section;
    int row = theTextField.indexPath.row;
    
    if (section == 0 && row == 0) {
        [self.managedObject setValue:theTextField.text forKey:@"title"];
        NSLog(@"saving title");
    } else if (section == 0 && row == 1) {
        [self.managedObject setValue:theTextField.text forKey:@"desc"];
        NSLog(@"saving description");
    } else if (section == 2 && row == 0) {
        [self.managedObject setValue:theTextField.text forKey:@"catTitle"];
        NSLog(@"saving cat title");
    }
    
    //[self saveContext];
    
}



-(void)saveContext {
    NSManagedObjectContext *context = [managedObject managedObjectContext];
    if (context != nil) {
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"AddItem TVC - Unresolved saving error: %@, %@", error, [error userInfo]);
            abort();
        }
        [mainTableView reloadData];
    }
    NSLog(@"----====SAVED CONTEXT====----");
    
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

#pragma mark - Table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    int section = indexPath.section;
    int row = indexPath.row;

    if (section == 2 && row == 2) {
        //display the color pallette
        [self showColorPallette:cell];
    }
    
    
}

#pragma mark - Action Sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSManagedObjectContext *context = managedObject.managedObjectContext;
    if (buttonIndex == 0) {
        //The delete button was clicked
        [context deleteObject:managedObject];
        [self.popoverController dismissPopoverAnimated:YES];
    } else {
        
    }
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
#warning Toolbar is bugged after ActionSheet is displayed.
        [self.navigationController setToolbarHidden:YES animated:NO];
        [self.navigationController setToolbarHidden:NO animated:NO];
        
        CGRect box = CGRectMake(0, 0, 300, 600);
        self.popoverController.popoverContentSize = box.size;
        
        
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //NSLog(@"textfield delegate");
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textfield didendediting");
    [self saveContext];
}


@end
