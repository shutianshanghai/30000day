//
//  XHBubblePhotoImageView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHBubblePhotoImageView.h"
#import "XHMacro.h"

#import "UIView+XHRemoteImage.h"

#import "UIImage+Resize.h"

#import "UIImageView+WebCache.h"

@interface XHBubblePhotoImageView ()

@property dispatch_semaphore_t semaphore;

/**
 *  消息类型
 */
@property (nonatomic, assign) XHBubbleMessageType bubbleMessageType;

@end

@implementation XHBubblePhotoImageView {

    UIImageView *_imageView;
}

- (XHBubbleMessageType)getBubbleMessageType {
    return self.bubbleMessageType;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (void)setMessagePhoto:(UIImage *)messagePhoto {
    _messagePhoto = messagePhoto;

    _imageView.image = messagePhoto;
   
     [self setNeedsDisplay];
}

- (void)configureMessagePhoto:(UIImage *)messagePhoto thumbnailUrl:(NSString *)thumbnailUrl originPhotoUrl:(NSString *)originPhotoUrl onBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    
    self.bubbleMessageType = bubbleMessageType;
    
    if (thumbnailUrl) {
        WEAKSELF
        
        [self addSubview:self.activityIndicatorView];
        
        [self.activityIndicatorView startAnimating];
        
        [_imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:nil options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.messagePhoto = image;
                    
                    [weakSelf.activityIndicatorView stopAnimating];
                });
            }
        }];
        
    } else {
        
        self.messagePhoto = messagePhoto;
    }
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    if (self.semaphore) {
        
        dispatch_semaphore_signal(self.semaphore);
    }
    
    _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
    
    _imageView.frame = CGRectMake(9, 9, self.bounds.size.width - 18, self.bounds.size.height - 17.5f);
    
    
//    CGMutablePathRef path = CGPathCreateMutable();
//    
//    _borderLayer.frame = self.bounds;
//    
//    _maskLayer.frame = self.bounds;

//    if (self.bubbleMessageType == XHBubbleMessageTypeSending) {
//        
//        //画图
//        CGFloat width = self.bounds.size.width;
//        
//        CGFloat height = self.bounds.size.height;
//        
//        CGPathMoveToPoint(path, NULL,0,0);
//        
//        CGPathAddLineToPoint(path, NULL, width - 20 , 0);//上面直线
//        CGPathMoveToPoint(path, NULL,width - 20 ,0);
//        
//        CGPathAddLineToPoint(path, NULL, width, 10);
//        CGPathMoveToPoint(path, NULL,width,10);
//        
//        CGPathAddLineToPoint(path, NULL, width + 6, 13);//三角形
//        CGPathMoveToPoint(path, NULL,width + 6,13);
//        
//        CGPathAddLineToPoint(path, NULL, width,16);
//        CGPathMoveToPoint(path, NULL,width,16);
//        
//        CGPathAddLineToPoint(path, NULL, width,height);
//        CGPathMoveToPoint(path, NULL,width,height);
//        
//        CGPathAddLineToPoint(path, NULL, 0,height);
//        CGPathMoveToPoint(path, NULL,0,height);
//        
//        CGPathAddLineToPoint(path, NULL, 0,0);
//        CGPathMoveToPoint(path, NULL,0,0);
//        
//        _borderLayer.strokeColor = LOWBLUECOLOR.CGColor;
//        
//    } else {
//        
//        CGFloat width = self.bounds.size.width;
//        
//        CGFloat height = self.bounds.size.height;
//        
//        CGPathMoveToPoint(path, NULL,0,0);
//        
//        CGPathAddLineToPoint(path, NULL, width, 0);//上面直线
//        CGPathMoveToPoint(path, NULL,width,0);
//        
//        
//        CGPathAddLineToPoint(path, NULL, width, height);
//        CGPathMoveToPoint(path, NULL,width,height);
//        
//        
//        CGPathAddLineToPoint(path, NULL,0,height);//三角形
//        CGPathMoveToPoint(path, NULL,0,height);
//        
//        CGPathAddLineToPoint(path, NULL, 0,16);
//        CGPathMoveToPoint(path, NULL,0,16);
//        
//        
//        CGPathAddLineToPoint(path, NULL, -6,13);
//        CGPathMoveToPoint(path, NULL,-6,13);
//        
//        
//        CGPathAddLineToPoint(path, NULL, 0,10);
//        CGPathMoveToPoint(path, NULL,0,10);
//        
//        CGPathAddLineToPoint(path, NULL, 0,0);
//        CGPathMoveToPoint(path, NULL,0,0);
//        
//        _borderLayer.strokeColor = RGBACOLOR(200, 200, 200, 1).CGColor;
//    }
//    
//    _borderLayer.lineWidth  = 3.0f;
//    
//    _maskLayer.path = path;
//    
//    _borderLayer.path = path;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        
        _imageView = imageView;
        
        imageView.layer.cornerRadius = 5;
        
        imageView.layer.masksToBounds = YES;
//
//        imageView.layer.borderColor = RGBACOLOR(200, 200, 200, 1).CGColor;
//        
//        imageView.layer.borderWidth = 1.0f;
        
        [self addSubview:imageView];

    }
    return self;
}

- (void)dealloc {
    
    _messagePhoto = nil;
    
    [self.activityIndicatorView stopAnimating];
    
    self.activityIndicatorView = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    rect.origin = CGPointZero;
    
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height + 1;//莫名其妙会出现绘制底部有残留 +1像素遮盖
    
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = 6;
    
    CGFloat margin = 8 ;//留出上下左右的边距
    
    CGFloat triangleSize = 8;//三角形的边长
    
    CGFloat triangleMarginTop = 8;//三角形距离圆角的距离
    
    //获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context,104.0f/255.0f,149.0f/255.0f,232.0f/255.0f,1);//画笔颜色
    
    CGContextSetLineWidth(context, 0.7f);//画笔宽度
    
    // 移动到初始点
    CGContextMoveToPoint(context, radius + margin, margin);
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius - margin, margin);
    
    CGContextAddArc(context, width - radius - margin, radius + margin, radius, - 0.5 * M_PI, 0.0, 0);
    
    // 闭合路径
    //    CGContextClosePath(context);
    
    float arcSize = 3;//角度的大小
    
    if (self.bubbleMessageType == XHBubbleMessageTypeSending) {
        
        float arcStartY = margin + radius + triangleMarginTop + triangleSize - (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = width - arcSize;//圆弧起始X值
        float centerOfCycleX = width - arcSize - pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        
        //绘制右边三角形
        CGContextMoveToPoint(context, width - margin,margin + radius);
        
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop);
        
        
        
        CGContextMoveToPoint(context, width - margin,margin + radius + triangleMarginTop + triangleSize);
        
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, angelOfCycle / 2, 0.0 - angelOfCycle / 2, 1);
        
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop);
        
        
        
        CGContextMoveToPoint(context, width - margin,margin + radius + triangleMarginTop + triangleSize);
        
        CGContextAddLineToPoint(context, width - margin , height - radius - margin);
        
    } else {
        
        CGContextMoveToPoint(context, width - margin,margin + radius);
        
        CGContextAddLineToPoint(context, width - margin,height - margin - radius);
    }
    
    CGContextMoveToPoint(context, width - margin, height - radius - margin);
    
    CGContextAddArc(context, width - radius - margin, height - radius - margin, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextMoveToPoint(context, width - margin - radius, height - margin);
    
    CGContextAddLineToPoint(context,margin + radius, height - margin);
    
    CGContextAddArc(context,margin + radius, height - radius - margin, radius, 0.5 * M_PI, M_PI, 0);
    
    if (self.bubbleMessageType == XHBubbleMessageTypeReceiving) {
        
        float arcStartY = margin + radius + triangleMarginTop + (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = arcSize;//圆弧起始X值
        
        float centerOfCycleX = arcSize + pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        
        //绘制左边三角形
        CGContextMoveToPoint(context, margin,margin + radius);
        
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop);
        
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, M_PI + angelOfCycle / 2, M_PI - angelOfCycle / 2, 1);
        
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop + triangleSize);
        
        CGContextAddLineToPoint(context, margin, height - margin - radius);//连接3/4圆弧的线
        
    } else {
        
        CGContextMoveToPoint(context, margin,margin + radius);
        
        CGContextAddLineToPoint(context, margin, height - margin - radius);//连接3/4圆弧的线
    }
    // 绘制第4条线和第4个1/4圆弧
    CGContextMoveToPoint(context, margin, radius + margin);
    
    CGContextAddArc(context, radius + margin, margin + radius, radius, M_PI, 1.5 * M_PI, 0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextDrawPath(context, kCGPathStroke);
}


@end
