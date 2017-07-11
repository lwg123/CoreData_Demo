//
//  Clothes+CoreDataProperties.h
//  LO_CoreData
//
//  Created by weiguang on 2017/7/9.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "Clothes+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Clothes (CoreDataProperties)

+ (NSFetchRequest<Clothes *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int64_t price;
@property (nullable, nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
