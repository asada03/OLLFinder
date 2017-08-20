//
//  OLLCase+CoreDataProperties.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 20/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "OLLCase+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OLLCase (CoreDataProperties)

+ (NSFetchRequest<OLLCase *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *corners;
@property (nullable, nonatomic, copy) NSNumber *cross_type;
@property (nullable, nonatomic, copy) NSString *uid;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, retain) NSSet<Algorithm *> *algorithms;
@property (nullable, nonatomic, retain) Algorithm *main;

@end

@interface OLLCase (CoreDataGeneratedAccessors)

- (void)addAlgorithmsObject:(Algorithm *)value;
- (void)removeAlgorithmsObject:(Algorithm *)value;
- (void)addAlgorithms:(NSSet<Algorithm *> *)values;
- (void)removeAlgorithms:(NSSet<Algorithm *> *)values;

@end

NS_ASSUME_NONNULL_END
