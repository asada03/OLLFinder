//
//  Algorithm+CoreDataProperties.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 31/10/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//
//

#import "Algorithm+CoreDataProperties.h"

@implementation Algorithm (CoreDataProperties)

+ (NSFetchRequest<Algorithm *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Algorithm"];
}

@dynamic algorithm;
@dynamic rotations;
@dynamic uid;
@dynamic mainOf;
@dynamic ollCase;
@dynamic video;

@end
