//
//  Track.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>

@interface Track : NSObject<NSCoding>

@property (nonatomic) NSURL *uri;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *title;
@property (nonatomic) int spm;
@property (nonatomic) NSTimeInterval offset;

@end
