//
//  Video+CoreDataProperties.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 20/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "Video+CoreDataProperties.h"

@implementation Video (CoreDataProperties)

+ (NSFetchRequest<Video *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Video"];
}

@dynamic start;
@dynamic uid;
@dynamic author;
@dynamic algorithm;

@end
