//
//  ButtonExtras.m
//  iGotIt_HD
//
//  Created by Phillip Dieppa on 10/12/11.
//  Copyright 2011 Phillip Dieppa. All rights reserved.
//

//#import ""

#import "ControlExtras.h"
#import <objc/runtime.h>


@implementation UIButton(ButtonExtras)

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

static char UIB_PROPERTY_KEY;

@dynamic indexPath;

-(void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    
}

-(NSObject*)indexPath {
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

@end

@implementation UITextField(TextFieldExtras)

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

static char UIB_PROPERTY_KEY;

@dynamic indexPath;

-(void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject*)indexPath {
    return (NSObject*)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}
@end

@implementation UISplitViewController(SplitViewExtras)

- (id)init {
    self = [super init];
    if (self) {
        //Initialization code here.
    }
    return self;
}

static char UIB_PROPERTY_KEY;

@dynamic barButtonItem;

-(void)setBarButtonItem:(UIBarButtonItem *)barButtonItem {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, barButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSObject *)barButtonItem {
    return (NSObject *)objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

@end
