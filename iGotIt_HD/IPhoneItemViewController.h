//
//  IPhoneItemViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/26/11.
//  Copyright (c) 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDEX00_TEXTBOX_TAG 1
#define INDEX00_BUTTON_TAG 2
#define INDEX01_TEXTBOX_TAG 3
#define INDEX10_TEXTBOX_TAG 4
#define INDEX11_LABEL_TAG 5

@interface IPhoneItemViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>


@property (nonatomic, retain) NSManagedObject *managedObject;
@property (nonatomic, retain) NSManagedObject *parentManagedObject;
@property (strong, nonatomic) UITableViewController *mainTableView;
@property (nonatomic, retain) NotificationPanel *notificationPanel;

-(void)setupNavBar;
-(void)setupToolbar;
-(void)setupRightBarButtons;
-(void)saveContext;
-(void)resignResponder;
-(void)validateTitle;
@end
