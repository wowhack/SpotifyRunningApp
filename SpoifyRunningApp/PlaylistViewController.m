//
//  ViewController.m
//  SpoifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "PlaylistViewController.h"
#import "PlayViewController.h"
#import <Spotify/Spotify.h>


@interface PlaylistViewController ()

@property (nonatomic) SPTSession *session;
@property (nonatomic) NSArray *playlists;

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
        
        SPTPlaylistList *playlists = (SPTPlaylistList*)object;
        
        self.playlists = playlists.items;
        self.session = session;
        
        [self.tableView reloadData];
        
        for(SPTPlaylistSnapshot *playlist in playlists.items){
            NSLog(@"name: %@", playlist.name);
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTPlaylistSnapshot *playlist = [self.playlists objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = playlist.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return -1;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTPlaylistSnapshot *playlist = [self.playlists objectAtIndex:indexPath.row];
    
    PlayViewController *playView = [[PlayViewController alloc] init];
    [playView handlePlaylist:playlist session:self.session];
    
    [self presentViewController:playView animated:YES completion:nil];
}



@end
