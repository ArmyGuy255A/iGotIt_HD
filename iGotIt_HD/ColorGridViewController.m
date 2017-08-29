//
//  ColorGridViewController.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "ColorGridViewController.h"
#import <CoreData/CoreData.h>
#import "ActionClass.h"

@implementation ColorGridViewController

@synthesize managedObject;
@synthesize mainTableView;
@synthesize aiTV;
@synthesize popoverController;

#define RGBA(r, g, b, a)[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    //Gesture Recognizer
    //self
    
    self.view = [ActionClass createColorGrid:self action:@selector(setColor:) delegate:self];
        
    [super viewDidLoad];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Custom Implementation
-(void)saveContext {
    NSManagedObjectContext *context = [self.managedObject managedObjectContext];
    if (context != nil) {
        [ActionClass saveContext:context];
    }
}

-(void)setColor:(UITapGestureRecognizer *)gesture{
    
    UIView *colorRect = (UIView *)[gesture view];
    UIColor *rectColor = [colorRect backgroundColor];
    
    ////NSLog(@"%@", [rectColor description]);
    //#warning Need a condition for saving "priColor"
    
    [managedObject setValue:rectColor forKey:@"catColor"];
    
    //Refresh the tableViews
    [mainTableView reloadData];
    [aiTV reloadData];
    
    [self saveContext];
    //[mainTableView.mainTableView reloadData];
    [self.popoverController dismissPopoverAnimated:YES];
    
    
}

@end
