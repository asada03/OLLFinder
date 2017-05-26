//
//  OLLCase.h
//  OLL Finder
//
//  Created by Vortex on 01/03/15.
//  Copyright (c) 2015 Andres Sada Govela. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OLLCase : NSManagedObject

@property (nonatomic, retain) NSString * file_name;
@property (nonatomic, retain) NSString * algorithm;
@property (nonatomic, retain) NSNumber * cross_type;
@property (nonatomic, retain) NSNumber * corners;
@property (nonatomic, retain) NSNumber * rotations;

@end
