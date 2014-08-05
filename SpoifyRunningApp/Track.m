//
//  Track.m
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "Track.h"

@implementation Track

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.uri = [decoder decodeObjectForKey:@"uri"];
        self.artist = [decoder decodeObjectForKey:@"artist"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.spm = [[decoder decodeObjectForKey:@"spm"] intValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uri forKey:@"uri"];
    [encoder encodeObject:self.artist forKey:@"artist"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:[NSNumber numberWithInt:self.spm] forKey:@"spm"];
}

- (NSTimeInterval)offset
{
    if([[self.uri absoluteString] isEqualToString:@"spotify:track:5VVuxxuQIJD0pjjFls1DKL"]){
        return 4;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:3WibbMr6canxRJXhNtAvLU"]){
        return 7;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:5al9is1AQnaI3lTi20DUG6"]){
        return 11;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:6Ou08NE0N5z8eRL1siDtAK"]){
        return 20;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:3AVZaAbDvR6rs2NN4n0aAF"]){
        return 8;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:1aXpAbAo5rLbAQy2FRhoSI"]){
        return 4;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:6CfUJrawW1KHnh4VkZvuwx"]){
        return 29;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:7IMnGsxf6VkLMWs0d7vVLf"]){
        return 4;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:0DFYU6PSXQpDK80C5fvmcI"]){
        return 4;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:1ixtaZc0Adil3yD1ItPqSl"]){
        return 2;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:3AszgPDZd9q0DpDFt4HFBy"]){
        return 2;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:6bUNEbXT7HovLW6BgPCBsb"]){
        return 18;
    } else if([[self.uri absoluteString] isEqualToString:@"spotify:track:6cS2reOYomC1kVSeNR9Isp"]){
        return 7;
    } else {
        return 0;
    }
}

@end
