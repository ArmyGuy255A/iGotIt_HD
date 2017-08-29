//
//  Item.h
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDate * dateEnd;
@property (nonatomic, retain) NSString * catTitle;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * catNumber;
@property (nonatomic, retain) NSNumber * autoNumberValue;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * priNumber;
@property (nonatomic, retain) id priColor;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * dateStart;
@property (nonatomic, retain) id catColor;
@property (nonatomic, retain) NSNumber * sortValue;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * permanentID;
@property (nonatomic, retain) NSNumber * checked;

@end
