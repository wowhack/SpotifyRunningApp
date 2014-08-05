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
}

- (void)updateSpm:(BOOL)addStep {
    
    dispatch_sync(_serialQ, ^{
        
        if(addStep){
            [self.steps addObject:[NSDate date]];
        }
        
        NSMutableArray *filteredSteps = [[NSMutableArray alloc] init];
        for(NSDate *step in self.steps) {
            if(step.timeIntervalSinceNow > -kSeconds){
                [filteredSteps addObject:step];
            }
        }
        
        long spm = filteredSteps.count * 3;
        if((!self.lastUpdate || self.lastUpdate.timeIntervalSinceNow < -1) && abs(_spm-spm) > 5){
            NSLog(@"spm: %ld", spm);
            _spm = spm;
            [self.delegate changeSpm:(int)spm];
            self.lastUpdate = [NSDate date];
        }
        
        /*
         if(self.items.isEmpty || self.items[self.items.endIndex-1].0.timeIntervalSinceNow < -10)
         {
         self.items += (NSDate(), spm)
         self.tableView.reloadData()
         }*/
        
//        NSLog(@"steps per minute: %ld", spm);
    });
}


@end
