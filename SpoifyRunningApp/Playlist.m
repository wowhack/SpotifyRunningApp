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

- (NSArray*)tracks{
    NSArray *sortedArray = [_unorderedTracks sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = abs([(Track*)a spm] - _spm);
        int second = abs([(Track*)b spm] - _spm);
        return first > second;
    }];

    return sortedArray;
}

@end
