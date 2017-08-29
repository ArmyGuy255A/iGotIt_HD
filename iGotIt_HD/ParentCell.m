//
//  ParentCell.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import "ParentCell.h"
#import "ActionClass.h"



@implementation ParentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    UILabel *mainLabel, *secondLabel, *thirdLabel;
    UIButton *checkBox;
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        /*
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 5.0, 420.0, 15.0)];
        [mainLabel setTag:MAINLABEL_TAG];
        [mainLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [mainLabel setTextAlignment:UITextAlignmentLeft];
        [mainLabel setTextColor:[UIColor blackColor]];
        [mainLabel setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:mainLabel];

        secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 25.0, 420.0, 15.0)];
        [secondLabel setTag:SECONDLABEL_TAG];
        [secondLabel setFont:[UIFont systemFontOfSize:12.0]];
        [secondLabel setTextAlignment:UITextAlignmentLeft];
        [secondLabel setTextColor:[UIColor blackColor]];
        [secondLabel setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:secondLabel];
        
        thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(175.0, 15.0, 125.0, 15.0)];
        [thirdLabel setTag:THIRDLABEL_TAG];
        [thirdLabel setFont:[UIFont systemFontOfSize:12.0]];
        [thirdLabel setTextAlignment:UITextAlignmentRight];
        [thirdLabel setTextColor:[UIColor blueColor]];
        
        //Auto resize to the right margin
        [thirdLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
        [self.contentView addSubview:thirdLabel];
        
        //get the width of the tableview and position the checkbox to the inside edge
        checkBox = [[UIButton alloc] initWithFrame:CGRectMake(6.0, 2.0, 50.0, 40.0)];
        
        [checkBox setTag:CHECKBOX_TAG];
        //[checkBox setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:checkBox];
            
         */
        //Get the cell height
        float cellHeight = self.frame.size.height;
        float cellWidth = self.frame.size.width;
        CGRect checkBoxFrame = CGRectMake(0.0, 0.0, 60.0, cellHeight);
        CGRect thirdLabelFrame = CGRectMake(cellWidth - 125, 0.0, 125, cellHeight);
        CGRect mainLabelFrame = CGRectMake(checkBoxFrame.size.width, 0, cellWidth - thirdLabelFrame.size.width - checkBoxFrame.size.width, cellHeight / 2);
        CGRect secondLabelFrame = CGRectMake(mainLabelFrame.origin.x, mainLabelFrame.size.height, mainLabelFrame.size.width, mainLabelFrame.size.height);
        
        //get the width of the tableview and position the checkbox to the inside edge
        checkBox = [[UIButton alloc] initWithFrame:checkBoxFrame];
        [checkBox setBackgroundColor:[UIColor clearColor]];
        [checkBox setTag:CHECKBOX_TAG];
        //[checkBox setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:checkBox];
        
        /*
         See the ButtonExtras class for the buttonIndexPath method.
         Passing the indexPath to the action to handle checking, unchecking, and 
         writing to CoreData
         */
        
        mainLabel = [[UILabel alloc] initWithFrame:mainLabelFrame];
        [mainLabel setTag:MAINLABEL_TAG];
        [mainLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [mainLabel setTextAlignment:UITextAlignmentLeft];
        [mainLabel setTextColor:[UIColor blackColor]];
        [mainLabel setBackgroundColor:[UIColor clearColor]];
        //[mainLabel setBackgroundColor:[UIColor greenColor]];
        //[mainLabel setAlpha:0.5];
        [mainLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:mainLabel];
        
        secondLabel = [[UILabel alloc] initWithFrame:secondLabelFrame];
        [secondLabel setTag:SECONDLABEL_TAG];
        [secondLabel setFont:[UIFont systemFontOfSize:12.0]];
        [secondLabel setTextAlignment:UITextAlignmentLeft];
        [secondLabel setTextColor:[UIColor blackColor]];
        [secondLabel setBackgroundColor:[UIColor clearColor]];
        //[secondLabel setBackgroundColor:[UIColor redColor]];
        //[secondLabel setAlpha:0.5];
        [secondLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:secondLabel];
        
        
        thirdLabel = [[UILabel alloc] initWithFrame:thirdLabelFrame];
        [thirdLabel setTag:THIRDLABEL_TAG];
        [thirdLabel setFont:[UIFont systemFontOfSize:12.0]];
        [thirdLabel setTextAlignment:UITextAlignmentCenter];
        [thirdLabel setTextColor:[UIColor blackColor]];
        [thirdLabel setBackgroundColor:[UIColor clearColor]];
        //[thirdLabel setBackgroundColor:[UIColor blueColor]];
        //[thirdLabel setAlpha:0.5];
        [thirdLabel setNumberOfLines:0];
        [thirdLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.contentView addSubview:thirdLabel];

    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        //Get the cell height
        float cellHeight = 35;
        float cellWidth = self.frame.size.width;
        CGRect checkBoxFrame = CGRectMake(0.0, 0.0, 50.0, cellHeight);
        CGRect thirdLabelFrame = CGRectMake(cellWidth - 82, 0.0, 82, cellHeight);
        CGRect mainLabelFrame = CGRectMake(checkBoxFrame.size.width, 0, cellWidth - thirdLabelFrame.size.width - checkBoxFrame.size.width, cellHeight / 2);
        CGRect secondLabelFrame = CGRectMake(mainLabelFrame.origin.x, mainLabelFrame.size.height, mainLabelFrame.size.width, mainLabelFrame.size.height);
        
        //get the width of the tableview and position the checkbox to the inside edge
        checkBox = [[UIButton alloc] initWithFrame:checkBoxFrame];
        [checkBox setBackgroundColor:[UIColor clearColor]];
        [checkBox setTag:CHECKBOX_TAG];
        [self.contentView addSubview:checkBox];

        /*
         See the ButtonExtras class for the buttonIndexPath method.
         Passing the indexPath to the action to handle checking, unchecking, and 
         writing to CoreData
         */
        
        mainLabel = [[UILabel alloc] initWithFrame:mainLabelFrame];
        [mainLabel setTag:MAINLABEL_TAG];
        [mainLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        [mainLabel setTextAlignment:UITextAlignmentLeft];
        [mainLabel setTextColor:[UIColor blackColor]];
        [mainLabel setBackgroundColor:[UIColor clearColor]];
        //[mainLabel setBackgroundColor:[UIColor greenColor]];
        //[mainLabel setAlpha:0.5];
        [mainLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:mainLabel];
        
        secondLabel = [[UILabel alloc] initWithFrame:secondLabelFrame];
        [secondLabel setTag:SECONDLABEL_TAG];
        [secondLabel setFont:[UIFont systemFontOfSize:12.0]];
        [secondLabel setTextAlignment:UITextAlignmentLeft];
        [secondLabel setTextColor:[UIColor blackColor]];
        [secondLabel setBackgroundColor:[UIColor clearColor]];
        //[secondLabel setBackgroundColor:[UIColor redColor]];
        //[secondLabel setAlpha:0.5];
        [secondLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:secondLabel];
        
        
        thirdLabel = [[UILabel alloc] initWithFrame:thirdLabelFrame];
        [thirdLabel setTag:THIRDLABEL_TAG];
        [thirdLabel setFont:[UIFont systemFontOfSize:12.0]];
        [thirdLabel setTextAlignment:UITextAlignmentCenter];
        [thirdLabel setTextColor:[UIColor blackColor]];
        [thirdLabel setBackgroundColor:[UIColor clearColor]];
        //[thirdLabel setBackgroundColor:[UIColor blueColor]];
        //[thirdLabel setAlpha:0.5];
        [thirdLabel setNumberOfLines:0];
        [thirdLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.contentView addSubview:thirdLabel];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end


