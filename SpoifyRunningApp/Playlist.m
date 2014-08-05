//
//  Playlist.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "Playlist.h"
#import "Track.h"

@interface Playlist()

@property (nonatomic) NSMutableArray *unorderedTracks;

@end

@implementation Playlist

- (id)init
{
    self = [super init];
    if(self){
        _unorderedTracks = [[NSMutableArray alloc] init];
        _spm = 100;
    }
    
    return self;
}

- (void)addTrack:(Track*)track
{
    [_unorderedTracks addObject:track];
}

- (NSArray*)tracks{
    NSArray *sortedArray = [_unorderedTracks sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        double first = abs([(Track*)a spm] - _spm);
        double second = abs([(Track*)b spm] - _spm);
        return first > second;
    }];

    return sortedArray;
}

@end
