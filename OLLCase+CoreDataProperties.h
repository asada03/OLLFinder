//
//  OLLCase+CoreDataProperties.h
//  OLL Finder
//
//  Created by Andres Luis Sada Govela on 11/08/17.
//  Copyright © 2017 Andres Sada Govela. All rights reserved.
//

#import "OLLCase+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface OLLCase (CoreDataProperties)

+ (NSFetchRequest<OLLCase *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *algorithm;
@property (nullable, nonatomic, copy) NSNumber *corners;
@property (nullable, nonatomic, copy) NSNumber *cross_type;
@property (nullable, nonatomic, copy) NSString *file_name;
@property (nullable, nonatomic, copy) NSNumber *rotations;
@property (nullable, nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
