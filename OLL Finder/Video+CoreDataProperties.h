//
//  Video+CoreDataProperties.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 21/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "Video+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Video (CoreDataProperties)

+ (NSFetchRequest<Video *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *author;
@property (nullable, nonatomic, copy) NSNumber *start;
@property (nullable, nonatomic, copy) NSString *vidId;
@property (nullable, nonatomic, copy) NSNumber *duration;
@property (nullable, nonatomic, retain) Algorithm *algorithm;

@end

NS_ASSUME_NONNULL_END
