//
//  PlayViewController.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@class SPTSession;

@interface PlayViewController : UITableViewController<SPTAudioStreamingDelegate>

-(void)handlePlaylist:(SPTPlaylistSnapshot*)playlist session:(SPTSession *)session ;

@end
