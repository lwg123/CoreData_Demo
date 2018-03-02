//
//  ViewController.m
//  LO_CoreData
//
//  Created by weiguang on 2017/7/9.
//  Copyright © 2017年 weiguang. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Clothes+CoreDataClass.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;
// 后台操作context
@property (nonatomic,strong) NSManagedObjectContext *backgroundContext;

// 通过这个appdelegate对象引入管理器
@property (nonatomic,strong) AppDelegate *myAppdelegate;

@end

@implementation ViewController

// 插入数据
- (IBAction)addModel:(UIBarButtonItem *)sender {
    
    // 创建实体描述对象
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Clothes" inManagedObjectContext:_myAppdelegate.persistentContainer.viewContext];
    
    //创建实体模型
    Clothes *cloth = [[Clothes alloc] initWithEntity:description insertIntoManagedObjectContext:_myAppdelegate.persistentContainer.viewContext];
    
    cloth.name = @"Puma";
    cloth.price = arc4random() % 1000 + 1;
    
    // 插入数据源数组
    [self.dataSource addObject:cloth];
    
    NSIndexPath *indexpath= [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];

    [self.tableView insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    
    //[self.tableView reloadData];
    
    // 保存在数据管理器
    [_myAppdelegate saveContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataSource = [NSMutableArray array];
    
    self.myAppdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.tableView.rowHeight = 40;
    
    NSManagedObjectContext *backgroundContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).persistentContainer.newBackgroundContext;
    self.backgroundContext = backgroundContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveContextSave:) name:NSManagedObjectContextDidSaveNotification object:self.backgroundContext];
    // 首先获取数据库中的数据
    [self getData];
    // 执行异步操作的数据
    [self performSelector:@selector(doSometingInBackground) withObject:nil afterDelay:3.0];
}

// 获取数据源
- (void)getData {
    [self.dataSource removeAllObjects];
    //查询
    // 1.NSFetchRequest对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Clothes"];
    
    // 2.设置排序
    // 2.1 NSSortDescriptor创建排序描述对象
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    request.sortDescriptors = @[sortDescriptor]; // 是一个数组，可以添加多个排序对象
    
    // 3.执行查询请求,返回一个数组
    NSError *error = nil;
    NSArray *result = [self.myAppdelegate.persistentContainer.viewContext executeFetchRequest:request error:&error];
    
    // 4.给数据源数组中添加数据
    [self.dataSource addObjectsFromArray:result];
}

/*
 后台 context的操作放在 performBlock 或 performBlockAndWait 方法里执行，
 performBlock 会异步的执行，不会阻塞当前的线程，
 而 performBlockAndWait 则会阻塞当前的线程直到方法返回才会继续向下执行
 */
- (void)doSometingInBackground {
    // 在后台从事一些耗时操作
    [self.backgroundContext performBlock:^{
        for (NSUInteger i = 0; i < 10; i++) {
            NSString *name = [NSString stringWithFormat:@"Puma-%d", arc4random_uniform(99)];
            int64_t price = arc4random() % 1000 + 1;
            
            Clothes *cloth = [NSEntityDescription insertNewObjectForEntityForName:@"Clothes" inManagedObjectContext:self.backgroundContext];
            cloth.name = name;
            cloth.price = price;
        }
        
        NSError *error;
        [self.backgroundContext save:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getData];
            [_tableView reloadData];
        });
    }];
}

- (void)receiveContextSave:(NSNotification *)note {
    [self.myAppdelegate.persistentContainer.viewContext mergeChangesFromContextDidSaveNotification:note];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TableView的数据源和代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"加载数据-----");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Clothes *cloth = self.dataSource[indexPath.row];
    cell.textLabel.text  = [NSString stringWithFormat:@"%@ -- %lld",cloth.name,cloth.price];
    
    return cell;
}

// tableView编辑的方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除数据源
        Clothes *cloth = self.dataSource[indexPath.row];
        [self.dataSource removeObject:cloth];
        
        // 删除数据管理器中的数据
        [self.myAppdelegate.persistentContainer.viewContext deleteObject:cloth];
        
        //将更改进行保存
        [self.myAppdelegate saveContext];
        
        // 删除单元格
        [_tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];
        
        
    }
}


// 点击cell修改数据源
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 1.先找到模型对象
    Clothes *cloth = self.dataSource[indexPath.row];
    
    // 修改模型数据
    cloth.name = @"Nick";
    
    // 刷新单元行
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // 通过saveContext保存
    [self.myAppdelegate saveContext];
}




@end
