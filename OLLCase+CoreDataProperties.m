//
//  OLLCase+CoreDataProperties.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 11/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "OLLCase+CoreDataProperties.h"

@implementation OLLCase (CoreDataProperties)

+ (NSFetchRequest<OLLCase *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"OLLCase"];
}

@dynamic algorithm;
@dynamic corners;
@dynamic cross_type;
@dynamic file_name;
@dynamic rotations;
@dynamic type;

@end
