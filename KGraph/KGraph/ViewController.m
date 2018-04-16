//
//  ViewController.m
//  KGraph
//
//  Created by 段丽娜 on 2018/4/9.
//  Copyright © 2018年 段丽娜. All rights reserved.
//

#import "ViewController.h"
#import "KGraphView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //加载数据源
    NSDictionary *dict = [self readLoadFileWithName:@"timeLineForDay"];
    NSArray *arr = dict[@"chartlist"];
    NSLog(@"%@",arr);
    
    
    
    KGraphView * tView = [[KGraphView alloc]initWithFrame:CGRectMake(10, 98, self.view.frame.size.width-20, self.view.frame.size.height-500)];
    NSMutableArray *stringArray = [NSMutableArray arrayWithObjects:@"09:30",@"10.30",@"11:30/13:00",@"14:00",@"15:00", nil];
    [tView drawStringView:stringArray];
    [tView setDataArray:arr];
    [self.view addSubview:tView];
    
}


- (NSDictionary *)readLoadFileWithName:(NSString *)name{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return dict;
    
}

@end
