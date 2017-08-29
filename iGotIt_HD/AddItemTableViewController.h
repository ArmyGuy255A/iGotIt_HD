//
//  AddItemTableViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Child.h"
#import "Parent.h"


@interface AddItemTableViewController : UITableViewController <UITextFieldDelegate, UIPopoverControllerDelegate>

#pragma mark - FRC Delegate
@property (strong, nonatomic) NSManagedObject *managedObject;
@property (strong, nonatomic) NSManagedObject *parentManagedObject;

@property (strong, nonatomic) UITableView *mainTableView;

@property (strong, nonatomic) UIPopoverController *popoverController;

#pragma mark - Popover
@property (strong, nonatomic) UIPopoverController *itemPopover;



-(void)setupToolbar;
-(void)setupLeftBarButtons;
-(void)saveContext;
-(void)resignResponder;
-(void)validateTitle;
@end
