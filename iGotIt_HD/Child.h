//
//  Child.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Parent.h"

@class Parent;

@interface Child : Parent

@property (nonatomic, retain) NSString * parentID;
@property (nonatomic, retain) Parent *parent;

@end
