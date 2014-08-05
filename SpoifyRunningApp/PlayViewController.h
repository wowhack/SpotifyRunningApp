//
//  PlayViewController.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "MovementThing.h"

@class SPTSession;

@interface PlayViewController : UITableViewController<SPTAudioStreamingDelegate, MovementThingDelegate>

-(void)handlePlaylist:(SPTPlaylistSnapshot*)playlist session:(SPTSession *)session ;

@end
