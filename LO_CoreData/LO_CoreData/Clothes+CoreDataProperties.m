//
//  Clothes+CoreDataProperties.m
//  LO_CoreData
//
//  Created by weiguang on 2017/7/9.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "Clothes+CoreDataProperties.h"

@implementation Clothes (CoreDataProperties)

+ (NSFetchRequest<Clothes *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Clothes"];
}

@dynamic name;
@dynamic price;
@dynamic type;

@end
