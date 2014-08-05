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
#import "MovementThing.h"
#import "BieberAlertView.h"
#import "PlayView.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface PlayViewController()

@property (nonatomic, strong) SPTAudioStreamingController *streamingPlayer;
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic) int spm;
@property (nonatomic) Track *currentTrack;

@property (nonatomic) MovementThing *movementThing;

@property (nonatomic) NSDate *lastTrackChange;

@property (nonatomic) UILabel *spmLabel;

@property (nonatomic) BOOL running;

@property (nonatomic) BOOL bieberMode;
@property (nonatomic) UIView *bieberView;
@property (nonatomic) Track *bieberTrack;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];

    self.spm = 0;
    
    self.movementThing = [[MovementThing alloc] init];
    self.movementThing.delegate = self;
    
    UILabel *spm =  [[UILabel alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(self.tableView.bounds), 60)];
    spm.textAlignment = NSTextAlignmentCenter;
    spm.text = [NSString stringWithFormat:@"%d", _spm];
    spm.font = [UIFont fontWithName:@"ProximaNova-Light" size:60];
    spm.textColor = [UIColor whiteColor];
    self.spmLabel = spm;
    
    self.bieberTrack = [[Track alloc] init];
    self.bieberTrack.uri = [[NSURL alloc] initWithString:@"spotify:track:1wF1jbJ52izth0MiWR4oQj"];
    self.bieberTrack.offset = 63;
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
            
            NSLog(@"playlist uri: %@", playlist.uri);
            [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:session callback:^(NSError *error, id object) {
                if (error != nil) {
                    NSLog(@"*** Error fetching playlist: %@", error);
                    return;
                }
                
                SPTPlaylistSnapshot *playlistSnapshot = (SPTPlaylistSnapshot*)object;
                self.playlist = [[Playlist alloc] init];
                self.playlist.name = playlistSnapshot.name;
                self.title = self.playlist.name;
                
                BOOL ready = YES;
                
                AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
                httpManager.requestSerializer = [AFJSONRequestSerializer serializer];
                for(SPTTrack *sptTrack in playlistSnapshot.firstTrackPage.items){
                    
                    Track *track = [[Track alloc] init];
                    track.uri = sptTrack.uri;
                    if( [sptTrack.artists count] > 0){
                        SPTPartialArtist *artist = (SPTPartialArtist*)sptTrack.artists.firstObject;
                        track.artist = artist.name;
                    }
                    track.title = sptTrack.name;
                    
                    NSNumber *trackSpm = [userDefaults objectForKey:[sptTrack.uri absoluteString]];
                    if(!trackSpm){
                        ready = NO;
                        NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/profile?api_key=6HADM8BJ9XUXBMB3M&track_id=%@&bucket=id:spotify&bucket=audio_summary", sptTrack.uri];
                        
                        [httpManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            NSDictionary *response = [ ((NSDictionary*)responseObject) objectForKey:@"response"];
                            NSArray* songs = [response objectForKey:@"songs"];
                            for(NSDictionary *song in songs){
                                NSDictionary *summary = [song objectForKey:@"audio_summary"];
                                NSNumber *tempo = [summary objectForKey:@"tempo"];
                                
                                track.spm = [tempo intValue];
                                
                                [userDefaults setObject:tempo forKey:[sptTrack.uri absoluteString]];

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
                    if(ready){
                        NSData *playlistData = [NSKeyedArchiver archivedDataWithRootObject:self.playlist];
                        [userDefaults setObject:playlistData forKey:[playlist.uri absoluteString]];
                    }
                    Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
                    self.currentTrack = firstTrack;
                }
                
                [self.tableView reloadData];
            }];
        } else {
            
            Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
            self.currentTrack = firstTrack;
            
            [self.tableView reloadData];
        }
       
    }];

}

-(void)playPause:(id)sender {
    NSLog(@"playPause isPlaying: %d", self.streamingPlayer.isPlaying);
	if (self.streamingPlayer.isPlaying) {
        
        [self.streamingPlayer setIsPlaying:NO callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Stop audio, got error: %@", error);
                return;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"pause isPlaying: %d", self.streamingPlayer.isPlaying);
                [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [_movementThing stop];
            });
        }];
        
	} else {
		[self.streamingPlayer playURI:self.currentTrack.uri callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Enabling playback got error: %@", error);
                return;
            }
            
            [_movementThing start];
            
            self.lastTrackChange = [NSDate date];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"play isPlaying: %d", self.streamingPlayer.isPlaying);
                [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
            
        }];
	}
}

-(void)playTrack:(Track*)track
{
    [self.streamingPlayer playURI:track.uri callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        self.lastTrackChange = [NSDate date];
        
        if(track.offset > 0){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.streamingPlayer seekToOffset:track.offset callback:^(NSError *error) {
                    if (error) {
                        NSLog(@"*** Enabling playback got error: %@", error);
                        return;
                    }
                }];
            });
        }
    }];
}

-(void)changeSpm:(int)spm
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _spm = spm;
        self.playlist.spm = spm;
        self.spmLabel.text = [NSString stringWithFormat:@"%d", spm];

        if(spm < 80 && self.running){
            [self bieberAlert:YES];
            self.running = NO;
        } else if(self.lastTrackChange.timeIntervalSinceNow <= -5 || (self.bieberMode && spm > 100)){
            Track *firstTrack = [self.playlist.tracks objectAtIndex:0];
            if(![self.currentTrack.uri isEqual:firstTrack.uri]){
                self.currentTrack = firstTrack;
                [self playTrack:firstTrack];
            }
            if(spm > 100){
                self.running = YES;
                [self bieberAlert:NO];
            }
            [self.tableView reloadData];
        }
    }];
}

- (void)bieberAlert:(BOOL)show
{
    if(show && !self.bieberView){
        UIView *bieberView = [[BieberAlertView alloc] initWithFrame:self.view.bounds];
        [self.tableView addSubview:bieberView];
        [self.tableView bringSubviewToFront:bieberView];
        [self playTrack:self.bieberTrack];
        self.bieberMode = YES;
        self.bieberView = bieberView;
    } else if(self.bieberView){
        [self.bieberView removeFromSuperview];
        self.bieberView = nil;
        self.bieberMode = NO;
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
    cell.backgroundColor = [UIColor clearColor];

    if(indexPath.section == 0 && indexPath.row == 0){
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CGRectGetWidth(self.tableView.bounds), 20)];
        header.textAlignment = NSTextAlignmentCenter;
        header.text = @"Strides Per Minute";
        header.font = [UIFont fontWithName:@"Proxima Nova" size:20];
        header.textColor = [UIColor lightGrayColor];
        
        self.spmLabel.text = [NSString stringWithFormat:@"%d", _spm];

        [cell.contentView addSubview:header];
        [cell.contentView addSubview:self.spmLabel];

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
        
        if(self.streamingPlayer.isPlaying){
            [play setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            [play setTitle:@"Play" forState:UIControlStateNormal];
        }

        [play addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
    } else {
        Track *track = [self.playlist.tracks objectAtIndex:indexPath.row];
        
        int extra = 0;
        
        if(indexPath.row == 0){
            PlayView *play = [[PlayView alloc] initWithFrame:CGRectMake(15, 15, 10, 30)];
            play.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:play];
            extra = 25;
        }
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15+extra, 5, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        
        title.text = track.title;
        title.font = [UIFont fontWithName:@"Proxima Nova" size:18];
        
        if(indexPath.row == 0){
            title.textColor = [UIColor colorWithRed:224.0/255.0 green:0.0/255.0 blue:112.0/255.0 alpha:1];
        } else {
            title.textColor = [UIColor whiteColor];
        }

        UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + extra, 30, CGRectGetWidth(self.tableView.bounds) - 50, 30)];
        artistLabel.text = track.artist;
        
        artistLabel.font = [UIFont fontWithName:@"Proxima Nova" size:16];
        artistLabel.textColor = [UIColor lightGrayColor];
        
        UILabel *spm = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.bounds) - 40, 5, 50, 30)];
        spm.text = [NSString stringWithFormat:@"%d", track.spm];
        spm.font = [UIFont fontWithName:@"Proxima Nova" size:16];
        spm.textColor = [UIColor lightGrayColor];
        
        [cell.contentView addSubview:title];
        [cell.contentView addSubview:artistLabel];
        [cell.contentView addSubview:spm];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1){
        return 67;
    } else if(indexPath.section == 0 && indexPath.row == 0){
        return 120;
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
        
        if(self.spm == 0){
            self.spm = 80;
        }
        [self changeSpm:self.spm + 1];
        NSLog(@"spm click: %d", self.spm);
    } else if(indexPath.section == 1){
        Track *track = [self.playlist.tracks objectAtIndex:indexPath.row];
        
        [self.streamingPlayer playURI:track.uri callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Enabling playback got error: %@", error);
                return;
            }
            
            if(track.offset > 0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.streamingPlayer seekToOffset:track.offset callback:^(NSError *error) {
                        if (error) {
                            NSLog(@"*** Enabling playback got error: %@", error);
                            return;
                        }
                    }];
                });
            }
            
            self.lastTrackChange = [NSDate date];
        }];
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
