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
    self.view.backgroundColor = [UIColor blackColor];
    
    self.title = @"Select playlist";
    
    self.tableView.separatorColor = [UIColor darkGrayColor];
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    //    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
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
    cell.textLabel.font = [UIFont fontWithName:@"Proxima Nova" size:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:224.0/255.0 green:0.0/255.0 blue:112.0/255.0 alpha:1]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
