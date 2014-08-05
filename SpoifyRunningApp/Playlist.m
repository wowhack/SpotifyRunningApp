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

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.unorderedTracks = [decoder decodeObjectForKey:@"unorderedTracks"];
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.unorderedTracks forKey:@"unorderedTracks"];
    [encoder encodeObject:self.name forKey:@"name"];
}

- (void)addTrack:(Track*)track
{
    [_unorderedTracks addObject:track];
}

- (long)closestTrack:(int)spm {
    
    long closest = 0;
    int closestSpm = 9999;
    
    int i = 0;
    for(Track *track in self.tracks){
        int spmDiff = abs(track.spm - spm);
        if(spmDiff < closestSpm){
            closestSpm = spmDiff;
            closest = i;
        }
        i++;
    }
    return closest;
}


- (NSArray*)tracks{
    NSArray *sortedArray = [_unorderedTracks sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [(Track*)a spm];
        int second = [(Track*)b spm];
        return first > second;
    }];

    return sortedArray;
}

@end
