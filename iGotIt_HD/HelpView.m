//
//  HelpView.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "HelpView.h"

@implementation HelpView
@synthesize btnDisableHelp;
@synthesize btnHideHelp;
@synthesize lblMain;
@synthesize menuType;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureButtons];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self setBackgroundColor:[UIColor blackColor]];
    [self configureView];
}



#pragma mark - Custom implementation

-(void)configureView{
    
    
    switch ([menuType intValue]) {
        case kParentHelpMenu:
            [self loadParentHelp];
            break;
        case kChildHelpMenu:
            [self loadChildHelp];
            break;
        case kFavoriteHelpMenu:
            [self loadFavoriteHelp];
            break;
            
        default:
            break;
    }
    
}
-(void)configureButtons{
    CGRect rectNewBtn = CGRectMake(60, 60, 120, 30);
    UIButton *btnDisHlp = [[UIButton alloc] initWithFrame:rectNewBtn];
    UIButton *btnHideHlp = [[UIButton alloc] initWithFrame:rectNewBtn];
    
    [btnDisHlp setTitle:@"Disable Help" forState:UIControlStateNormal];
    [btnHideHlp setTitle:@"Hide Help" forState:UIControlStateNormal];
    CGSize shadowOffset = CGSizeMake(1, 1);
    [btnDisHlp.titleLabel setShadowOffset:shadowOffset]; 
    [btnHideHlp.titleLabel setShadowOffset:shadowOffset];
    
    [self addSubview:btnDisHlp];
    [self addSubview:btnHideHlp];
    
    //background image for buttons
    /*
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"UIToolbarButton3StateNormal" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    */
    UIImage *theImage = [SettingsClass getThemeButtonBackgroundImage:kStateNormal];
    UIEdgeInsets insets = UIEdgeInsetsMake(15, 10, 15, 10);
    
    [btnDisHlp setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    [btnHideHlp setBackgroundImage:[theImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    
    [btnDisHlp addTarget:self action:@selector(disableHelp) forControlEvents:UIControlEventTouchUpInside];
    [btnHideHlp addTarget:self action:@selector(hideHelp) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDisHlp.layer setAnchorPoint:CGPointMake(0.0, 1.0)];
    [btnHideHlp.layer setAnchorPoint:CGPointMake(1.0, 1.0)];
    
    float sidePadding = 15.0f;
    float topPadding = 35.0f;
    CGPoint pntUpperLeft = CGPointMake(sidePadding , topPadding);
    CGPoint pntUpperRight = CGPointMake(self.frame.size.width - sidePadding, topPadding);
    [btnDisHlp.layer setPosition:pntUpperLeft];
    [btnHideHlp.layer setPosition:pntUpperRight];
    
    [SettingsClass setThemeButtonTextColor:btnDisHlp];
    [SettingsClass setThemeButtonTextColor:btnHideHlp];
    
    btnDisableHelp = btnDisHlp;
    btnHideHelp = btnHideHlp;
}

-(void)loadParentHelp {
    float x = 15;
    float y = 50;
    float labelWidth = self.layer.frame.size.width - (x * 2);
    float labelHeight = 30;
    
    UILabel *label1 = [[UILabel alloc] init]; 
    UILabel *label2 = [[UILabel alloc] init];
    UILabel *label3 = [[UILabel alloc] init];
    UILabel *label4 = [[UILabel alloc] init];
    UILabel *label5 = [[UILabel alloc] init];
    
    NSMutableArray *labels = [NSMutableArray arrayWithObjects:label1, label2, label3, label4, label5, nil];
    NSEnumerator *e = [labels objectEnumerator];
    UILabel *workingLabel;
    while (workingLabel = [e nextObject]) {
        
        [workingLabel setFrame:CGRectMake(x, y, labelWidth, labelHeight)];
        [workingLabel setTextColor:[UIColor whiteColor]];
        [workingLabel setBackgroundColor:[UIColor clearColor]];
        [workingLabel setShadowColor:[UIColor lightGrayColor]];
        [workingLabel setShadowOffset:CGSizeMake(0.5, 0.5)];
        [self addSubview:workingLabel];
        y += labelHeight + 10;
    }
    
    
    //Modify Text
    NSString *label1Text = @"• Start a new list by tapping the        button.";
    NSString *label2Text = @"• Tap and hold a List to bring up the 'Edit' menu.";
    NSString *label3Text = @"• Assign a 'Favorite Color' to the list in the 'Edit' menu.";
    NSString *label4Text = @"• Tap a list to view, add, update, and delete its sub-items.";
    NSString *label5Text = @"• Swipe a List to the right to             it.";
    
    
    [label1 setText:label1Text];
    [label2 setText:label2Text];
    [label3 setText:label3Text];
    [label4 setText:label4Text];
    [label5 setText:label5Text];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, btnDisableHelp.frame.origin.y, 300, labelHeight)];
    [title.layer setPosition:CGPointMake(self.frame.size.width / 2, btnDisableHelp.frame.origin.y + btnDisableHelp.frame.size.height / 2)];
    [self addSubview:title];
    
    [title setFont:[UIFont boldSystemFontOfSize:32]];
    [title setTextAlignment:UITextAlignmentCenter];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor lightTextColor]];
    [title setShadowColor:[UIColor darkGrayColor]];
    [title setShadowOffset:CGSizeMake(0.5, 0.5)];
    //title text
    [title setText:@"List Tutorial"];
    
    
    //Add images
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Plus" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *plusIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:plusIV];
    CGRect ivLocation = label1.frame;
    [plusIV setFrame:CGRectMake(ivLocation.origin.x + 240, ivLocation.origin.y, 25, 25)];
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"delete" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *delIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:delIV];
    ivLocation = label5.frame;
    [delIV setFrame:CGRectMake(ivLocation.origin.x + 213, ivLocation.origin.y, 25 * 2, 25)];
}

-(void)loadChildHelp {
    float x = 15;
    float y = 50;
    float labelWidth = self.layer.frame.size.width - (x * 2);
    float labelHeight = 30;
    
    UILabel *label1 = [[UILabel alloc] init]; 
    UILabel *label2 = [[UILabel alloc] init];
    UILabel *label3 = [[UILabel alloc] init];
    UILabel *label4 = [[UILabel alloc] init];
    UILabel *label5 = [[UILabel alloc] init];
    UILabel *label6 = [[UILabel alloc] init];
    
    NSMutableArray *labels = [NSMutableArray arrayWithObjects:label1, label2, label3, label4, label5, label6, nil];
    NSEnumerator *e = [labels objectEnumerator];
    UILabel *workingLabel;
    while (workingLabel = [e nextObject]) {
        
        [workingLabel setFrame:CGRectMake(x, y, labelWidth, labelHeight)];
        [workingLabel setTextColor:[UIColor whiteColor]];
        [workingLabel setBackgroundColor:[UIColor clearColor]];
        [workingLabel setShadowColor:[UIColor lightGrayColor]];
        [workingLabel setShadowOffset:CGSizeMake(0.5, 0.5)];
        [self addSubview:workingLabel];
        y += labelHeight + 10;
    }
    
    
    //Modify Text
    NSString *label1Text = @"• Use the        button in the 'New Item' menu to rapidly create sub-items.";
    NSString *label2Text = @"• The 'Auto Number' will attempt to automagically number your list.";
    NSString *label3Text = @"• Use the              located in the section titles to check/uncheck all sub-items.";
    NSString *label4Text = @"• View your favorites by tapping 'Favorites'";
    NSString *label5Text = @"• All        will convert the List into a favorite.";
    NSString *label6Text = @"• Sub-Items can contain additional sub-items.";
    
    [label1 setText:label1Text];
    [label2 setText:label2Text];
    [label3 setText:label3Text];
    [label4 setText:label4Text];
    [label5 setText:label5Text];
    [label6 setText:label6Text];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, btnDisableHelp.frame.origin.y, 300, labelHeight)];
    [title.layer setPosition:CGPointMake(self.frame.size.width / 2, btnDisableHelp.frame.origin.y + btnDisableHelp.frame.size.height / 2)];
    [self addSubview:title];
    
    [title setFont:[UIFont boldSystemFontOfSize:32]];
    [title setTextAlignment:UITextAlignmentCenter];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor lightTextColor]];
    [title setShadowColor:[UIColor darkGrayColor]];
    [title setShadowOffset:CGSizeMake(0.5, 0.5)];
    //title text
    [title setText:@"Sub-Item Tutorial"];
    
    //Add images
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"RapidAdd" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *plusIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:plusIV];
    CGRect ivLocation = label1.frame;
    [plusIV setFrame:CGRectMake(ivLocation.origin.x + 81, ivLocation.origin.y + 5, 15, 15)];
    
    //imagePath = [[NSBundle mainBundle] pathForResource:@"CheckAll" ofType:@"png"];
    //theImage = [UIImage imageWithContentsOfFile:imagePath];
    theImage = [SettingsClass getThemeCheckBoxAllImage];
    UIImageView *chkIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:chkIV];
    ivLocation = label3.frame;
    [chkIV setFrame:CGRectMake(ivLocation.origin.x + 83, ivLocation.origin.y, 25, 25)];
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"UNCHK_ALL" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *unchkIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:unchkIV];
    ivLocation = label3.frame;
    [unchkIV setFrame:CGRectMake(chkIV.frame.origin.x + 13, ivLocation.origin.y, 25, 25)];
    
    //copy this item to add more images
    //imagePath = [[NSBundle mainBundle] pathForResource:@"favoriteButton" ofType:@"png"];
    //theImage = [UIImage imageWithContentsOfFile:imagePath];
    theImage = [SettingsClass getThemeFavoriteButtonImage];
    UIImageView *favIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:favIV];
    ivLocation = label5.frame;
    [favIV setFrame:CGRectMake(ivLocation.origin.x + 38, ivLocation.origin.y, 25, 25)];
    
   
}

-(void)loadFavoriteHelp {
    float x = 15;
    float y = 65;
    float labelWidth = self.layer.frame.size.width - (x * 2);
    float labelHeight = 35;
    
    UILabel *label1 = [[UILabel alloc] init]; 
    UILabel *label2 = [[UILabel alloc] init];
    UILabel *label3 = [[UILabel alloc] init];
    UILabel *label4 = [[UILabel alloc] init];
    UILabel *label5 = [[UILabel alloc] init];
    UILabel *label6 = [[UILabel alloc] init];
    
    NSMutableArray *labels = [NSMutableArray arrayWithObjects:label1, label2, label3, label4, label5, label6, nil];
    NSEnumerator *e = [labels objectEnumerator];
    UILabel *workingLabel;
    while (workingLabel = [e nextObject]) {
        
        [workingLabel setFrame:CGRectMake(x, y, labelWidth, labelHeight)];
        [workingLabel setTextColor:[UIColor whiteColor]];
        [workingLabel setBackgroundColor:[UIColor clearColor]];
        [workingLabel setShadowColor:[UIColor lightGrayColor]];
        [workingLabel setShadowOffset:CGSizeMake(0.5, 0.5)];
        [workingLabel setFont:[UIFont systemFontOfSize:12.0]];
        [workingLabel setNumberOfLines:2];
        [self addSubview:workingLabel];
        y += labelHeight + 10;
    }
    [label1 setNumberOfLines:1];
    [label1 setFont:[UIFont boldSystemFontOfSize:14]];
    [label1 setTextAlignment:UITextAlignmentCenter];
    
    //Modify Text
    NSString *label1Text = @"Favorites allow you to reuse your lists!";
    NSString *label2Text = @"• Tap              then             to add your favorite list to the active list in the main window.";
    NSString *label3Text = @"• Tap the item to modify its sub-items.";
    NSString *label4Text = @"• Tap and hold the item to bring up the 'Edit' menu.";
    NSString *label5Text = @"• Change the 'Favorites Category' to help organize your favorites.";
    NSString *label6Text = @"• Swipe a Favorite to the right to             it.";
    
    [label1 setText:label1Text];
    [label2 setText:label2Text];
    [label3 setText:label3Text];
    [label4 setText:label4Text];
    [label5 setText:label5Text];
    [label6 setText:label6Text];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, labelHeight)];
    [title.layer setPosition:CGPointMake(self.frame.size.width / 2, 55)];
    [self addSubview:title];
    
    [title setFont:[UIFont boldSystemFontOfSize:20]];
    [title setTextAlignment:UITextAlignmentCenter];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor lightTextColor]];
    [title setShadowColor:[UIColor darkGrayColor]];
    [title setShadowOffset:CGSizeMake(0.5, 0.5)];
    //title text
    [title setText:@"Favorites Tutorial"];
    
    //Add images
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Insert" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *plusIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:plusIV];
    CGRect ivLocation = label2.frame;
    [plusIV setFrame:CGRectMake(ivLocation.origin.x + 34, ivLocation.origin.y + 2, 34, 17)];
    
    //copy this item to add more images
    imagePath = [[NSBundle mainBundle] pathForResource:@"Confirm" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *favIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:favIV];
    //ivLocation = label2.frame;
    [favIV setFrame:CGRectMake(plusIV.frame.origin.x + 69, plusIV.frame.origin.y, 34, 17)];
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"delete" ofType:@"png"];
    theImage = [UIImage imageWithContentsOfFile:imagePath];
    UIImageView *delIV = [[UIImageView alloc] initWithImage:theImage];
    [self addSubview:delIV];
    ivLocation = label6.frame;
    [delIV setFrame:CGRectMake(plusIV.frame.origin.x + 140, ivLocation.origin.y + 7, 34, 17)];
}

-(void)disableHelp{
    NSString *message = [NSString stringWithFormat:@"Don't Worry! \n\nHelp Menu's can be re-enabled through your device's 'Settings' application. \n\nLook for 'iGotIt' and switch 'Show Help Tutorials' back on!"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disabling Help Menus" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [SettingsClass setShowHelp:NO];
    [ActionClass hideHelpMenu:YES menuType:kParentHelpMenu];
    [ActionClass hideHelpMenu:YES menuType:kFavoriteHelpMenu];
}
-(void)hideHelp{
    if ([menuType intValue] == 0) {
        [ActionClass hideHelpMenu:YES menuType:kFavoriteHelpMenu];
    } else {
        [ActionClass hideHelpMenu:YES menuType:kParentHelpMenu];
    }
}

#pragma mark - View lifecycle


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
@end
