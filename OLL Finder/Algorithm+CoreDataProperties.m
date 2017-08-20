//
//  Algorithm+CoreDataProperties.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 20/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "Algorithm+CoreDataProperties.h"

@implementation Algorithm (CoreDataProperties)

+ (NSFetchRequest<Algorithm *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Algorithm"];
}

@dynamic rotations;
@dynamic algorithm;
@dynamic uid;
@dynamic ollCase;
@dynamic videos;

@end
