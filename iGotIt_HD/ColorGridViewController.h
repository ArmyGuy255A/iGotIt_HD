//
//  ColorGridViewController.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AddItemTableViewController.h"

@interface ColorGridViewController : UIViewController <UIGestureRecognizerDelegate>

#pragma mark - FRC Delegate


@property (strong, nonatomic) NSManagedObject *managedObject;

@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) UITableView *aiTV;


@property (strong, nonatomic) UIPopoverController *popoverController;

//-(void)createColorGrid;
-(void)saveContext;

@end
