//
//  Video+CoreDataProperties.m
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 31/10/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//
//

#import "Video+CoreDataProperties.h"

@implementation Video (CoreDataProperties)

+ (NSFetchRequest<Video *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Video"];
}

@dynamic author;
@dynamic duration;
@dynamic start;
@dynamic vidId;
@dynamic algorithm;

@end
