//
//  KGraphView.m
//  KGraph
//
//  Created by 段丽娜 on 2018/4/9.
//  Copyright © 2018年 段丽娜. All rights reserved.
//

#import "KGraphView.h"

#define countOfTimes 240
#define KWIDTH      self.frame.size.width
#define KHEIGHT     self.frame.size.height
#define LHEIGHT     self.frame.size.height * 0.7
#define VHEIGHT     self.frame.size.height - self.frame.size.height *0.7 - 15

#define graphMargin  15
@interface KGraphView ()

//最高价格
@property(nonatomic,assign)float maxPrice;
//最低价格
@property(nonatomic,assign)float minPrice;
//最大利率
@property(nonatomic,assign)float maxRatio;
//最小利率
@property(nonatomic,assign)float minRatio;
//最大成交量
@property(nonatomic,assign)float maxVolume;
//差价
@property(nonatomic,assign)float priceMaxOffset;
//昨日收盘价
@property(nonatomic,assign)float preClosePrice;

//价格间隙高度
@property(nonatomic,assign)float priceUnit;
//时间间隔宽度
@property(nonatomic,assign)float volumeStep;
//成交量等分高度
@property(nonatomic,assign)float volumeUnit;
//成交量柱状图宽度
@property(nonatomic,assign)float volumeW;
//坐标集合
@property(nonatomic,strong)NSMutableArray * positionArray;
@property(nonatomic,strong)NSMutableArray * avgPositionArray;
@property(nonatomic,strong)NSMutableArray * volumeArray;

//呼吸灯
@property(nonatomic,strong)CALayer * animateLayer;
//数据显示
@property(nonatomic,strong)CAShapeLayer * crossLineLayer;
@end

@implementation KGraphView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self drawFrameView];
//        [self addGestures];
        NSDictionary *dict =[self readLoadFileWithName:@"SZ300033"][@"SZ300033"];
        self.preClosePrice = [[dict objectForKey:@"last_close"] floatValue];
        
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray{
    
    _dataArray = dataArray;
    if (_dataArray.count > 0) {
    [self setMaxAndMinData];
    }
    
}

- (NSMutableArray *)positionArray{
    if (_positionArray == nil) {
        _positionArray = [NSMutableArray array];
    }
    return _positionArray;
    
}

- (NSMutableArray *)avgPositionArray{
    if (_avgPositionArray == nil) {
        _avgPositionArray = [[NSMutableArray alloc]init];
    }
    return _avgPositionArray;
}

- (NSMutableArray *)volumeArray{
    
    if (_volumeArray == nil) {
        _volumeArray = [NSMutableArray array];
    }
    return _volumeArray;
    
}
- (CALayer *)animateLayer{
    if (_animateLayer == nil) {
        _animateLayer = [CALayer layer];
        [self.layer addSublayer:_animateLayer];
        _animateLayer.backgroundColor = [UIColor colorWithRed:0 green:149/255.0 blue:1 alpha:1].CGColor;
        _animateLayer.cornerRadius = 1.5;
        _animateLayer.masksToBounds = YES;
        [_animateLayer addAnimation:[self breathingLightAnimate:2] forKey:nil];
    }
    return _animateLayer;
}

- (void)addGestures{
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressEvent:)];
    [self addGestureRecognizer:longPressGesture];
}

- (CAAnimationGroup *)breathingLightAnimate:(float)time {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1);
    scaleAnimation.toValue = @(3.5);
    scaleAnimation.autoreverses = NO;
    scaleAnimation.removedOnCompletion = YES;
    scaleAnimation.repeatCount =  MAXFLOAT;
    scaleAnimation.duration = time;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    opacityAnimation.autoreverses = NO;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.repeatCount = MAXFLOAT;
    opacityAnimation.duration = time;
    opacityAnimation.fillMode = kCAFillModeForwards;
    
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = time;
    animationGroup.autoreverses = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.removedOnCompletion = NO;//需手动释放
    animationGroup.animations = @[scaleAnimation,opacityAnimation];
    return animationGroup;
}

- (void)cleanLayer{
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
}


- (void)longPressEvent:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan || longPress.state == UIGestureRecognizerStateChanged) {
        
    }else if (longPress.state == UIGestureRecognizerStateEnded){
        
    }else{
        
    }
    
}

- (void)setMaxAndMinData{
    
    
    self.maxPrice = [self.dataArray[0][@"current"] doubleValue];
    self.minPrice = [self.dataArray[0][@"current"] doubleValue];
    //比例 = （当前价格-昨日收盘价）/ 昨日收盘价
    self.maxRatio = ([self.dataArray[0][@"current"] doubleValue] - self.preClosePrice) / self.preClosePrice;
    self.minRatio = ([self.dataArray[0][@"current"] doubleValue] - self.preClosePrice) / self.preClosePrice;
    self.maxVolume = [self.dataArray[0][@"volume"] doubleValue];
    
    for ( int i = 0; i < self.dataArray.count; i++) {
        NSDictionary *entity = self.dataArray[i];
        self.priceMaxOffset = self.priceMaxOffset > fabs([entity[@"current"] doubleValue] - self.preClosePrice) ? self.priceMaxOffset : fabs([entity[@"current"] doubleValue] - self.preClosePrice);
        self.maxPrice = self.preClosePrice + self.priceMaxOffset;
        self.minPrice = self.preClosePrice - self.priceMaxOffset;
        self.maxRatio = self.priceMaxOffset / self.preClosePrice;
        self.minRatio = - self.maxRatio;
        self.maxVolume = self.maxVolume > [entity[@"volume"] doubleValue] ? self.maxVolume : [entity[@"volume"] doubleValue];
    }
    [self convertToPoints];
    [self drawMarkLayer];
}

- (void)convertToPoints{
    CGFloat maxDiff = self.maxPrice - self.minPrice;
    if (maxDiff > 0) {
        self.priceUnit =( LHEIGHT - 2* 15) / maxDiff;
    }
    if (self.maxVolume > 0) {
        self.volumeUnit =(self.frame.size.height*0.3 - 15) / self.maxVolume;
    }
    self.volumeStep = KWIDTH/countOfTimes;
    
    [self.positionArray removeAllObjects];
    [self.avgPositionArray removeAllObjects];
    for (int i = 0; i < self.dataArray.count; i ++) {
        //价格坐标
        CGFloat centerX = self.volumeStep * i + self.volumeStep/2;
        CGFloat centerY = (self.maxPrice - [self.dataArray[i][@"current"] floatValue]) * self.priceUnit + 15;
        CGPoint pricePoint = CGPointMake(centerX, centerY);
        //均值坐标
        CGFloat avgY = (self.maxPrice - [self.dataArray[i][@"avg_price"] floatValue]) * self.priceUnit + 15;
        CGPoint avgPoint = CGPointMake(centerX, avgY);
        //成交量坐标
         self.volumeW = self.volumeStep - self.volumeStep/3.0;
        CGPoint startPoint = CGPointMake(self.volumeStep * i ,KHEIGHT - [self.dataArray[i][@"volume"] floatValue] * self.volumeUnit);
        CGPoint endPoint = CGPointMake(self.volumeStep * i + self.volumeW, KHEIGHT);
        
     
        
        [self.positionArray addObject:NSStringFromCGPoint(pricePoint)];
        [self.avgPositionArray addObject:NSStringFromCGPoint(avgPoint)];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:NSStringFromCGPoint(startPoint) forKey:@"start"];
        [dict setObject:NSStringFromCGPoint(endPoint) forKey:@"end"];
        [self.volumeArray addObject:dict];
    }
    
    [self drawKLineLayer:self.positionArray];
    [self drawAvgLineLayer:self.avgPositionArray];
    [self drawVomueLayer:self.volumeArray];
}

#pragma mark - 绘制外框
- (void)drawFrameView{
    
    CGFloat frameW = KWIDTH;
    CGFloat frameH = LHEIGHT;
    
    CAShapeLayer *frameLayer = [CAShapeLayer layer];
    CGRect frameRect = CGRectMake(0, 0, frameW, KHEIGHT);
    
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:frameRect];
    
    float unitW = frameW/8;
    float unitH = (frameH - 30)/2;
    
    for (int i = 0; i < 9; i ++) {
        CGPoint startPoint = CGPointMake(unitW * i, 0);
        CGPoint endPoint = CGPointMake(unitW * i, frameH - 30);
        [framePath moveToPoint:startPoint];
        [framePath addLineToPoint:endPoint];
    }
    
    for (int i = 0; i < 3; i ++) {
        CGPoint startPoint  = CGPointMake(0, unitH * i);
        CGPoint endPoint = CGPointMake(frameW, unitH * i);
        [framePath moveToPoint:startPoint];
        [framePath addLineToPoint:endPoint];
    }
    [framePath moveToPoint:CGPointMake(0, LHEIGHT-1)];
    [framePath addLineToPoint:CGPointMake(KWIDTH, LHEIGHT-1)];
    
    [framePath moveToPoint:CGPointMake(0, LHEIGHT + graphMargin)];
    [framePath addLineToPoint:CGPointMake(KWIDTH, LHEIGHT + graphMargin)];
    
    
    
    frameLayer.path = framePath.CGPath;
    frameLayer.lineWidth = 1.0;
    frameLayer.strokeColor = [UIColor colorWithRed:222.f/255.f green:222.f/255.f blue:222.f/255.f alpha:1.f].CGColor;
    frameLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:frameLayer];
}

#pragma mark - 绘制分时线
- (void)drawKLineLayer:(NSArray *)pointArr{
    
    CAShapeLayer *kLineLayer = [CAShapeLayer layer];
    CAShapeLayer *fillColorLayer = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    CGPoint firstPoint = CGPointFromString([pointArr firstObject]);
    [linePath moveToPoint:firstPoint];
    for (int i = 1; i< pointArr.count; i++) {
        CGPoint tempPoint =  CGPointFromString(pointArr[i]);
        [linePath addLineToPoint:tempPoint];
    }
    kLineLayer.path = linePath.CGPath;
    kLineLayer.lineWidth = 1.0;
    kLineLayer.strokeColor = [UIColor colorWithRed:0 green:148/255.f blue:248/255.f alpha:1].CGColor;
    kLineLayer.fillColor = [UIColor clearColor].CGColor;
    
    
    
    [linePath addLineToPoint:CGPointMake(CGPointFromString([pointArr lastObject]).x, LHEIGHT-30)];
    [linePath addLineToPoint:CGPointMake(CGPointFromString([pointArr firstObject]).x, LHEIGHT-30)];
    fillColorLayer.path = linePath.CGPath;
    fillColorLayer.fillColor = [UIColor colorWithRed:227/255.f green:239/255.f blue:255/255.f alpha:1].CGColor;
    fillColorLayer.strokeColor = [UIColor clearColor].CGColor;
    fillColorLayer.zPosition = -1;
    [self.layer addSublayer:kLineLayer];
    [self.layer addSublayer:fillColorLayer];
    
    CGPoint lastPoint = CGPointFromString([pointArr lastObject]);
    self.animateLayer.frame = CGRectMake(lastPoint.x-1.5, lastPoint.y-1.5, 3, 3);
}

#pragma mark - 绘制均线
- (void)drawAvgLineLayer:(NSArray *)pointArr{
    CAShapeLayer *shapLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint firstPoint = CGPointFromString(pointArr[0]);
    [path moveToPoint:firstPoint];
    for (int i = 1; i < pointArr.count; i ++) {
        CGPoint tempPoint = CGPointFromString(pointArr[i]);
        [path addLineToPoint:tempPoint];
    }
    shapLayer.path = path.CGPath;
    shapLayer.lineWidth = 1.0f;
    shapLayer.strokeColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:4/255.0 alpha:1].CGColor;
    shapLayer.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:shapLayer];
}

#pragma mark -绘制成交量
- (void)drawVomueLayer:(NSArray *)vomuePointArr{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
   
 
    
    UIColor *color;
    for (int i = 0; i< vomuePointArr.count; i ++ ) {
        float comparePrice = (i == 0) ? self.preClosePrice : [self.dataArray[i - 1][@"current"] floatValue];

        if ([self.dataArray[i][@"current"] floatValue] < comparePrice) {
            color = [UIColor colorWithRed:29/255.0 green:191/255.0 blue:96/255.0 alpha:1];//绿跌
        }else{
            color = [UIColor colorWithRed:242/255.0 green:73/255.0 blue:87/255.0 alpha:1];//红涨
        }
        
        
        NSDictionary *dict = vomuePointArr[i];
       CAShapeLayer *layer =  [self setOneVomueLayerWithPoint:dict FillColor:color];
        [shapeLayer addSublayer:layer];
    }
       [self.layer addSublayer:shapeLayer];
}


- (void)drawStringView:(NSArray *)stringArr{
    CGFloat frameW = KWIDTH;
    CGFloat frameH = LHEIGHT;
    float unitW = frameW/8;
    
    CGFloat textY = 0;
    for (int i = 0; i < stringArr.count; i ++ ) {
        CGRect textRect;
        if (i == 0 || i == stringArr.count - 1) {
        textRect = CGRectMake(textY, frameH - 30, unitW, 30);
            textY = textY + unitW;
        }else{
        textRect = CGRectMake(textY, frameH - 30, unitW * 2, 30);
            textY = textY + unitW * 2;
        }
        
        CATextLayer *textLayer =  [self setTextLayerWithString:stringArr[i] textColor:[UIColor grayColor] textFontSize:12 bgColor:[UIColor clearColor] textAlignment:1 frame:textRect];
        [self.layer addSublayer:textLayer];
    }
    
}

#pragma mark - 绘制利率标签
- (void)drawMarkLayer{
    
    CATextLayer *maxRadiolayer = [self setMarkLayerWithFrame:CGRectMake(10, 10, 100, 15) text:[NSString stringWithFormat:@"%.2f%%",self.maxRatio* 100] isLeft:YES];
    CATextLayer *minRadiolayer = [self setMarkLayerWithFrame:CGRectMake(10, LHEIGHT - 30 - 25, 100, 15) text:[NSString stringWithFormat:@"%.2f%%",self.minRatio* 100] isLeft:YES];
    CATextLayer *maxPricelayer = [self setMarkLayerWithFrame:CGRectMake(KWIDTH - 110, 10, 100, 15) text:[NSString stringWithFormat:@"%.2f",self.maxPrice] isLeft:NO];
    CATextLayer *minPricelayer = [self setMarkLayerWithFrame:CGRectMake(KWIDTH - 110, LHEIGHT - 30 - 25, 100, 15) text:[NSString stringWithFormat:@"%.2f",self.minPrice] isLeft:NO];
    CATextLayer *centerPricelayer = [self setMarkLayerWithFrame:CGRectMake(KWIDTH - 110, (LHEIGHT - 30)/2-8, 100, 20) text:[NSString stringWithFormat:@"%.2f",self.preClosePrice] isLeft:NO];
    CATextLayer *volumeLater = [self setMarkLayerWithFrame:CGRectMake(KWIDTH - 110, KWIDTH - (KWIDTH - LHEIGHT - 15)-8, 100, 20) text:[NSString stringWithFormat:@"%.2f",self.maxVolume] isLeft:NO];
    [self.layer addSublayer:maxRadiolayer];
    [self.layer addSublayer:minRadiolayer];
    [self.layer addSublayer:maxPricelayer];
    [self.layer addSublayer:minPricelayer];
    [self.layer addSublayer:centerPricelayer];
    [self.layer addSublayer:volumeLater];
}

- (CAShapeLayer *)setOneVomueLayerWithPoint:(NSDictionary *)dict FillColor:(UIColor *)color{
    CAShapeLayer *shapeLayer =[CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointFromString(dict[@"start"])];
    [path addLineToPoint:CGPointFromString(dict[@"end"])];
    shapeLayer.path = path.CGPath;
    path.lineWidth = self.volumeW;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = color.CGColor;
    
    return shapeLayer;
}

- (CATextLayer *)setMarkLayerWithFrame:(CGRect)frame text:(NSString *)text isLeft:(BOOL)isLeft{
    
    CATextLayer *textLayer  = [self setTextLayerWithString:text textColor:[UIColor grayColor] textFontSize:12 bgColor:[UIColor clearColor] textAlignment:isLeft == YES ? 0 : 2 frame:frame];
    return textLayer;
}

- (CATextLayer *)setTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)color
                           textFontSize:(NSInteger)fontSize
                                bgColor:(UIColor *)bgColor
                          textAlignment:(NSInteger)textAlignment
                                  frame:(CGRect)frame
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = text;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = color.CGColor;
    textLayer.backgroundColor = bgColor.CGColor;
    
    switch (textAlignment) {
        case 0:
        {
             textLayer.alignmentMode = kCAAlignmentLeft;
            break;
        }
        case 1:
        {
            textLayer.alignmentMode = kCAAlignmentCenter;
            break;
        }
        case 2:
        {
            textLayer.alignmentMode = kCAAlignmentRight;
            break;
        }
        default:
        {
             textLayer.alignmentMode = kCAAlignmentCenter;
            break;
        }
            
    }
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    return textLayer;
    
}



- (NSDictionary *)readLoadFileWithName:(NSString *)name{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return dict;
    
}



@end
