//
//  Algorithm+CoreDataProperties.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 20/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "Algorithm+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Algorithm (CoreDataProperties)

+ (NSFetchRequest<Algorithm *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *rotations;
@property (nullable, nonatomic, copy) NSString *algorithm;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, retain) OLLCase *ollCase;
@property (nullable, nonatomic, retain) NSSet<Video *> *videos;

@end

@interface Algorithm (CoreDataGeneratedAccessors)

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet<Video *> *)values;
- (void)removeVideos:(NSSet<Video *> *)values;

@end

NS_ASSUME_NONNULL_END
