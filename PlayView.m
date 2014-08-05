//
//  PlayView.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 224.0/255.0, 0, 112.0/255.0, 1);
    CGContextFillPath(ctx);
}


@end
