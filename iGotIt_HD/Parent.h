//
//  Parent.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Child;

@interface Parent : Item

@property (nonatomic, retain) NSString * ID;
@property (nonatomic, retain) NSSet *children;
@end

@interface Parent (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Child *)value;
- (void)removeChildrenObject:(Child *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
