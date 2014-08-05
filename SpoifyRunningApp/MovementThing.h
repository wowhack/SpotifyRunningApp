//
//  MovementThing.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MovementThingDelegate <NSObject>

-(void)changeSpm:(int)spm;

@end

@interface MovementThing : NSObject

@property (nonatomic, weak) id<MovementThingDelegate> delegate;

- (void)start;

@end
