//
//  AppDelegate.h
//  LO_CoreData
//
//  Created by weiguang on 2017/7/9.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 CoreData Stack容器
 内部包含：
 管理对象上下文：NSManagedObjectContext *viewContext;
 对象管理模型：NSManagedObjectModel *managedObjectModel
 存储调度器：NSPersistentStoreCoordinator *persistentStoreCoordinator;
 */

@property (readonly, strong) NSPersistentContainer *persistentContainer;

//以下三个属性都属于persistentContainer
////被管理对象模型（数据模型）
//@property(strong,nonatomic,readonly)NSManagedObjectModel* managedObjectModel;
//
//// 被管理对象上下文（数据管理器）
//@property(strong,nonatomic,readonly)NSManagedObjectContext* managedObjectContext;
//
//// 持久化存储助理（数据连接器）
//@property(strong,nonatomic,readonly)NSPersistentStoreCoordinator* persistentStoreCoordinator;
//
- (void)saveContext;


@end

