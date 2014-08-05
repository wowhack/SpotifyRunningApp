//
//  PlayViewController.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "PlayViewController.h"
#import "Playlist.h"
#import "Track.h"
#import <Spotify/Spotify.h>

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface PlayViewController()

@property (nonatomic, strong) SPTAudioStreamingController *streamingPlayer;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic) int spm;
@property (nonatomic) Track *currentTrack;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];

    _spm = 100;
}

-(void)handlePlaylist:(SPTPlaylistSnapshot*)playlist session:(SPTSession *)session {

    if(self.streamingPlayer == nil) {
        self.streamingPlayer = [[SPTAudioStreamingController alloc] initWithCompanyName:@"Albert"
                                                                                appName:@"SpotifyRunningApp"];
        self.streamingPlayer.delegate = self;
    }
    
    // login session for streaming
    [self.streamingPlayer loginWithSession:session callback:^(NSError *error) {
        
		if (error != nil) {
			NSLog(@"*** Enabling playback got error: %@", error);
			return;
		}

        [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:session callback:^(NSError *error, id object) {
            SPTPlaylistSnapshot *playlistSnapshot = (SPTPlaylistSnapshot*)object;
            self.playlist = [[Playlist alloc] init];
            self.playlist.name = playlistSnapshot.name;
            self.title = self.playlist.name;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
            httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
            for(SPTTrack *sptTrack in playlistSnapshot.firstTrackPage.items){
                Track *track = [[Track alloc] init];
                track.track = sptTrack;
                
                NSNumber *trackSpm = [userDefaults objectForKey:[sptTrack.uri absoluteString]];
                if(!trackSpm){
                    NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/profile?api_key=6HADM8BJ9XUXBMB3M&track_id=%@&bucket=id:spotify&bucket=audio_summary", sptTrack.uri];
                    
                    [httpManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        NSDictionary *response = [ ((NSDictionary*)responseObject) objectForKey:@"response"];
                        NSArray* songs = [response objectForKey:@"songs"];
                        for(NSDictionary *song in songs){
                            NSDictionary *summary = [song objectForKey:@"audio_summary"];
                            NSNumber *tempo = [summary objectForKey:@"tempo"];
                            
                            NSLog(@"title: %@, tempo: %@", sptTrack.name, tempo);
                            
                            [userDefaults setObject:tempo forKey:[sptTrack.uri absoluteString]];
                            track.spm = [tempo intValue];
                            [self.playlist addTrack:track];
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                } else {
                    NSLog(@"title: %@, spm: %@", sptTrack.name, trackSpm);
                    track.spm = [trackSpm intValue];
                    [self.playlist addTrack:track];
                }
            }
            
            NSLog(@"count: %ld", (unsigned long)[self.playlist.tracks count]);
            Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
            self.currentTrack = firstTrack;
            
            [self.tableView reloadData];
        }];
    }];
}

-(void)playPause:(id)sender {
	if (self.streamingPlayer.isPlaying) {
        
        //
	} else {
		[self.streamingPlayer playURI:self.currentTrack.track.uri callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Enabling playback got error: %@", error);
                return;
            }
        }];
	}
}


#pragma mark - Table view stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 3;
    } else {
        return [self.playlist.tracks count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    
    if(indexPath.section == 0 && indexPath.row == 0){
       cell.textLabel.text = self.currentTrack.track.name;
    } else if(indexPath.section == 0 && indexPath.row == 1){
        cell.textLabel.text = [NSString stringWithFormat:@"Steps per minute: %d", _spm];
    } else if(indexPath.section == 0 && indexPath.row == 2){
        cell.textLabel.text = @"PLAY";
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        Track *track = [self.playlist.tracks objectAtIndex:indexPath.row];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        title.text = track.track.name;
        
        UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        
        if( [track.track.artists count] > 0){
            SPTPartialArtist *artist = (SPTPartialArtist*)track.track.artists.firstObject;
            artistLabel.text = artist.name;
        }
        
        
        UILabel *spm = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.bounds) - 40, 10, 50, 30)];
        spm.text = [NSString stringWithFormat:@"%d", track.spm];
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:artistLabel];
        [cell.contentView addSubview:spm];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Proxima Nova" size:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        return 70;
    } else {
        return -1;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 2){
        [self playPause:nil];
    } else if(indexPath.section == 0 && indexPath.row == 1){
        self.spm = self.spm + 1;
        self.playlist.spm = self.spm;
        
        Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
        if(![self.currentTrack.track.uri isEqual:firstTrack.track.uri]){
            self.currentTrack = firstTrack;
            [self.streamingPlayer playURI:self.currentTrack.track.uri callback:^(NSError *error) {

                if (error != nil) {
                    NSLog(@"*** Enabling playback got error: %@", error);
                    return;
                }
                
                if(self.currentTrack.offset > 0){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.streamingPlayer seekToOffset:self.currentTrack.offset callback:^(NSError *error) {
                            if (error) {
                                NSLog(@"*** Enabling playback got error: %@", error);
                                return;
                            }
                        }];
                    });
                }
            }];
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - Audio delegate
- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{
    NSLog(@"message: %@", message);
}


-(void)trackPlayer:(SPTTrackPlayer *)player didReceiveMessageForEndUser:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

@end
