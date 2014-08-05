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
#import <QuartzCore/QuartzCore.h>

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
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        id playlistData = [userDefaults objectForKey:[playlist.uri absoluteString]];
        self.playlist = playlistData ? [NSKeyedUnarchiver unarchiveObjectWithData:playlistData] : nil;

        if(!self.playlist){
            
            [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:session callback:^(NSError *error, id object) {
                if (error != nil) {
                    NSLog(@"*** Error fetching playlist: %@", error);
                    return;
                }
                
                SPTPlaylistSnapshot *playlistSnapshot = (SPTPlaylistSnapshot*)object;
                self.playlist = [[Playlist alloc] init];
                self.playlist.name = playlistSnapshot.name;
                self.title = self.playlist.name;
                
                AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
                httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
                for(SPTTrack *sptTrack in playlistSnapshot.firstTrackPage.items){
                    
                    Track *track = [[Track alloc] init];
                    track.uri = sptTrack.uri;
                    if( [sptTrack.artists count] > 0){
                        SPTPartialArtist *artist = (SPTPartialArtist*)sptTrack.artists.firstObject;
                        track.artist = artist.name;
                    }
                    
                    NSNumber *trackSpm = [userDefaults objectForKey:[sptTrack.uri absoluteString]];
                    if(!trackSpm){
                        NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/profile?api_key=6HADM8BJ9XUXBMB3M&track_id=%@&bucket=id:spotify&bucket=audio_summary", sptTrack.uri];
                        
                        [httpManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            NSDictionary *response = [ ((NSDictionary*)responseObject) objectForKey:@"response"];
                            NSArray* songs = [response objectForKey:@"songs"];
                            for(NSDictionary *song in songs){
                                NSDictionary *summary = [song objectForKey:@"audio_summary"];
                                NSNumber *tempo = [summary objectForKey:@"tempo"];
                                
                                [userDefaults setObject:tempo forKey:[sptTrack.uri absoluteString]];
                                track.spm = [tempo intValue];
                                [self.playlist addTrack:track];
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                        }];
                        
                    } else {
                        track.spm = [trackSpm intValue];
                        [self.playlist addTrack:track];
                    }
                }
                
                NSLog(@"count: %ld", (unsigned long)[self.playlist.tracks count]);
                if([self.playlist.tracks count] > 0){
                    NSData *playlistData = [NSKeyedArchiver archivedDataWithRootObject:self.playlist];
                    [userDefaults setObject:playlistData forKey:[playlist.uri absoluteString]];
                    Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
                    self.currentTrack = firstTrack;
                }
                
                [self.tableView reloadData];
            }];
        }
    }];
}

-(void)playPause:(id)sender {
	if (self.streamingPlayer.isPlaying) {
        
        //
	} else {
		[self.streamingPlayer playURI:self.currentTrack.uri callback:^(NSError *error) {
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
        return 2;
    } else {
        return [self.playlist.tracks count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if(indexPath.section == 0 && indexPath.row == 0){
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.tableView.bounds), 20)];
        header.textAlignment = NSTextAlignmentCenter;
        header.text = @"Strides Per Minute";
        header.font = [UIFont fontWithName:@"Proxima Nova" size:20];
        header.textColor = [UIColor lightGrayColor];
        
        UILabel *spm =  [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.tableView.bounds), 60)];
        spm.textAlignment = NSTextAlignmentCenter;
        spm.text = [NSString stringWithFormat:@"%d", _spm];
        spm.font = [UIFont fontWithName:@"ProximaNova-Light" size:60];
        spm.textColor = [UIColor whiteColor];
        
        [cell.contentView addSubview:header];
        [cell.contentView addSubview:spm];

        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if(indexPath.section == 0 && indexPath.row == 1){
        UIButton *play = [[UIButton  alloc] initWithFrame:CGRectMake(20, 5, CGRectGetWidth(self.tableView.bounds) - 40, 35)];
        play.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:0.0/255.0 blue:112.0/255.0 alpha:1];
        play.titleLabel.textAlignment = NSTextAlignmentCenter;
        play.layer.cornerRadius = 18.0;
        play.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
        play.titleLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:play];
        [play setTitle:@"Play" forState:UIControlStateNormal];
        [play addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else {
        Track *track = [self.playlist.tracks objectAtIndex:indexPath.row];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        title.text = track.title;
        
        if(indexPath.row == 0){
            title.textColor = [UIColor colorWithRed:224.0/255.0 green:0.0/255.0 blue:112.0/255.0 alpha:1];
        } else {
            title.textColor = [UIColor whiteColor];
        }
        title.font = [UIFont fontWithName:@"Proxima Nova" size:18];

        UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        artistLabel.text = track.artist;
        

        artistLabel.font = [UIFont fontWithName:@"Proxima Nova" size:16];
        artistLabel.textColor = [UIColor grayColor];
        
        UILabel *spm = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.bounds) - 40, 5, 50, 30)];
        spm.text = [NSString stringWithFormat:@"%d", track.spm];
        spm.font = [UIFont fontWithName:@"Proxima Nova" size:16];
        spm.textColor = [UIColor grayColor];
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:artistLabel];
        [cell.contentView addSubview:spm];
    }
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        return 70;
    } else if(indexPath.section == 0 && indexPath.row == 0){
        return 100;
    } else {
        return -1;
    }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 1){
        [self playPause:nil];
    } else if(indexPath.section == 0 && indexPath.row == 0){
        self.spm = self.spm + 1;
        self.playlist.spm = self.spm;
        
        Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
        if(![self.currentTrack.uri isEqual:firstTrack.uri]){
            self.currentTrack = firstTrack;
            [self.streamingPlayer playURI:self.currentTrack.uri callback:^(NSError *error) {

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
