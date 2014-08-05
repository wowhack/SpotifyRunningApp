//
//  Playlist.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface Playlist : NSObject

@property (nonatomic) NSString* name;
@property (nonatomic) NSArray* tracks;
@property (nonatomic) double spm;

- (void)addTrack:(Track*)track;

@end
