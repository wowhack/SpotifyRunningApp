//
//  BieberAlertView.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "BieberAlertView.h"

@implementation BieberAlertView

NSArray *backgroundColours;
int backgroundLoop;
UIView *rect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundColours = [NSArray arrayWithObjects:
                                  [UIColor redColor],
                                  [UIColor blueColor],
                                  [UIColor yellowColor],
                                  [UIColor purpleColor], nil];
        
        backgroundLoop = 0;
        
        rect = [[UIView alloc] initWithFrame:CGRectMake(60, 120, CGRectGetWidth(frame)-120, CGRectGetWidth(frame)-120)];
        
        [self addSubview:rect];
        
        [self animateBackgroundColour];
        
        UILabel *bieberLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 120, CGRectGetWidth(frame)-120, CGRectGetWidth(frame)-120)];
        bieberLabel.numberOfLines = 0;
        bieberLabel.lineBreakMode = NSLineBreakByWordWrapping;
        bieberLabel.textAlignment = NSTextAlignmentCenter;
        bieberLabel.text = @"BIEBER ALERT! RUN!";
        bieberLabel.font = [UIFont systemFontOfSize:30];
        [self addSubview:bieberLabel];
        
        UIImage *image = [UIImage imageNamed:@"photo.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 75, 75)];
        imageView.image = image;
        [self addSubview:imageView];
        [self runSpinAnimationOnView:imageView duration:5 rotations:1 repeat:100000];

        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-95, 50, 75, 75)];
        imageView2.image = image;
        [self addSubview:imageView2];
        [self runSpinAnimationOnView:imageView2 duration:5 rotations:1 repeat:100000];
        
        UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetWidth(frame)-35, 75, 75)];
        imageView3.image = image;
        [self addSubview:imageView3];
        [self runSpinAnimationOnView:imageView3 duration:5 rotations:1 repeat:100000];
        
        UIImageView *imageView4 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-95, CGRectGetWidth(frame)-35, 75, 75)];
        imageView4.image = image;
        [self addSubview:imageView4];
        [self runSpinAnimationOnView:imageView4 duration:5 rotations:1 repeat:100000];
        
    }
    
    return self;
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) animateBackgroundColour
{
    
    if (backgroundLoop < backgroundColours.count - 1)
    {
        backgroundLoop ++;
    } else {
        backgroundLoop = 0;
    }
    
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         rect.backgroundColor = [backgroundColours objectAtIndex:backgroundLoop];
                     } completion:^(BOOL finished) {
                         if(finished){
                            [self animateBackgroundColour];
                         }
    }];
}

@end
