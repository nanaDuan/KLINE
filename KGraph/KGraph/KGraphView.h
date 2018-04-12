//
//  KGraphView.h
//  KGraph
//
//  Created by 段丽娜 on 2018/4/9.
//  Copyright © 2018年 段丽娜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGraphView : UIView
@property(nonatomic,strong)NSArray * dataArray;

/**
 清除layer
 */
- (void)cleanLayer;

/**

 @param stringArr 绘制日期layer
 */
- (void)drawStringView:(NSArray *)stringArr;
@end
