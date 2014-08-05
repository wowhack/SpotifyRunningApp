//
//  PlayViewController.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "PlayViewController.h"
#import <Spotify/Spotify.h>

@interface PlayViewController()

@property (nonatomic, strong) SPTTrackPlayer *trackPlayer;
@property (nonatomic, strong) SPTPlaylistSnapshot *playlist;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)handlePlaylist:(SPTPlaylistSnapshot*)playlist session:(SPTSession *)session {

    [SPTPlaylistSnapshot playlistWithURI:[NSURL URLWithString:@"spotify:user:hvnter:playlist:7v0Gz0KBJ90Fg110YMlHhu"] session:session callback:^(NSError *error, id object) {
        
        if (error != nil) {
            NSLog(@"*** Playlist lookup got error %@", error);
            return;
        }
        NSLog(@"hej: %@", object);
        SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot*)object;
        
        NSLog(@"hej: %ld", (unsigned long)[playlist.firstTrackPage.items count]);
    }];
    
    
	if (self.trackPlayer == nil) {
		self.trackPlayer = [[SPTTrackPlayer alloc] initWithCompanyName:@"Spotify"
															   appName:@"SimplePlayer"];
		self.trackPlayer.delegate = self;
	}
    
    [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:session callback:^(NSError *error, id object) {
        SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot*)object;
        self.playlist = playlist;
        [self.tableView reloadData];
        [self.trackPlayer playTrackProvider:playlist];
    }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playlist.firstTrackPage.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTTrack *track = [self.playlist.firstTrackPage.items objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = track.name;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return -1;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
