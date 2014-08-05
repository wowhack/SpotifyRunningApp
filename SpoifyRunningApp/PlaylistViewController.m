//
//  ViewController.m
//  SpoifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "PlaylistViewController.h"
#import <Spotify/Spotify.h>

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)handleNewSession:(SPTSession *)session {
    
        
    [SPTRequest playlistsForUserInSession:session callback:^(NSError *error, id object) {
        
        if (error != nil) {
            NSLog(@"*** Playlist lookup got error %@", error);
            return;
        }
        
        SPTPlaylistList *playlistList = (SPTPlaylistList*)object;
        for(SPTPlaylistSnapshot *playlist in playlistList.items){
            NSLog(@"name: %@", playlist.name);
        }
        
    }];
    
    
}@end
