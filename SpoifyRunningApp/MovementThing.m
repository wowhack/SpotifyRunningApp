//
//  MovementThing.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "MovementThing.h"
#import <CoreMotion/CoreMotion.h>

typedef enum {
    kForward,
    kBackward
} ArmDirection;

const double kSeconds = 20.0;

@interface MovementThing()

@property (nonatomic) NSMutableArray *steps;
@property (nonatomic) ArmDirection armDirection;
@property (nonatomic) double lastZ;
@property (nonatomic) long spm;
@property (nonatomic) NSDate *lastUpdate;
@property (nonatomic) BOOL on;

@end

@implementation MovementThing

CMMotionManager *_motionManager;
dispatch_queue_t _serialQ;

- (id)init
{
    self = [super init];
    if(self){
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.1;
        _serialQ = dispatch_queue_create("serial_queue", nil);
        _steps = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)start
{
    NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
    
    CMGyroHandler gyroHandler = ^(CMGyroData *gyroData, NSError *error) {
        CMRotationRate rotation = gyroData.rotationRate;
        
        if(self.lastZ && (!self.armDirection || self.armDirection == kForward) && self.lastZ < rotation.z-1.5){
            self.armDirection = kBackward;
//            NSLog(@"backward z: %f", rotation.z);
            [self updateSpm:YES];
        } else if(self.lastZ && (!self.armDirection || self.armDirection == kBackward) && self.lastZ > rotation.z+1.5){
            self.armDirection = kForward;
//            NSLog(@"forward z: %f", rotation.z);
            [self updateSpm:YES];
        } else {
            [self updateSpm:NO];
        }
        
        self.lastZ = rotation.z;
    };

    [_motionManager startGyroUpdatesToQueue:opQueue withHandler:gyroHandler];
    self.on = YES;
    [self sendSpm];
}

- (void)sendSpm {
    
    NSMutableArray *filteredSteps = [[NSMutableArray alloc] init];
    for(NSDate *step in self.steps) {
        if(step.timeIntervalSinceNow > -kSeconds){
            [filteredSteps addObject:step];
        }
    }
    
    // send every X second
    long spm = filteredSteps.count * 3;
    
    NSLog(@"spm: %ld", spm);
    _spm = spm;
    [self.delegate changeSpm:(int)spm];
    self.lastUpdate = [NSDate date];
    
    if(self.on){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendSpm];
        });
    }
}

- (void)stop
{
    self.on = NO;
    [_motionManager stopGyroUpdates];
}

- (void)updateSpm:(BOOL)addStep {
    
    dispatch_sync(_serialQ, ^{
        if(addStep){
            [self.steps addObject:[NSDate date]];
        }
    });
}


@end
