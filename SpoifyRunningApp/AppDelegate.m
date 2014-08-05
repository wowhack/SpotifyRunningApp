//
//  AppDelegate.m
//  SpoifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "PlaylistViewController.h"

static NSString * const kClientId = @"29eca7f48dab4d62bfe330116916c8e1";
static NSString * const kCallbackURL = @"blablabla://callback";

static NSString * const kTokenSwapServiceURL = @"http://localhost:1234/swap";
static NSString * const kTokenRefreshServiceURL = @"http://localhost:1234/refresh";

static NSString * const kSessionUserDefaultsKey = @"SpotifySession";

@interface AppDelegate ()

@property PlaylistViewController *playlistViewCtrl;

@end

@implementation AppDelegate

-(void)enableAudioPlaybackWithSession:(SPTSession *)session {
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionData forKey:kSessionUserDefaultsKey];
    [userDefaults synchronize];
    [self.playlistViewCtrl handleNewSession:session];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"Proxima Nova" size:18]
                                                            }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    self.playlistViewCtrl = [[PlaylistViewController alloc] init];
    UINavigationController *navView = [[UINavigationController alloc] initWithRootViewController:self.playlistViewCtrl];
    self.window.rootViewController = navView;
    [self.window makeKeyAndVisible];
    NSLog(@"application1");
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    SPTAuth *auth = [SPTAuth defaultInstance];

    if (session) {
        if ([session isValid]) {
            [self enableAudioPlaybackWithSession:session];
        } else {
            [auth renewSession:session withServiceEndpointAtURL:[NSURL URLWithString:kTokenRefreshServiceURL] callback:^(NSError *error, SPTSession *session) {
                if (error) {
                    NSLog(@"*** Error renewing session: %@", error);
                    return;
                }
                
                [self enableAudioPlaybackWithSession:session];
            }];
        }
    } else {
        NSURL *loginURL = [auth loginURLForClientId:kClientId
                                declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                scopes:@[SPTAuthStreamingScope]];
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // If you open a URL during application:didFinishLaunchingWithOptions:, you
            // seem to get into a weird state.
            [[UIApplication sharedApplication] openURL:loginURL];
        });
    }
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"application");

    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }

        NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
        [[NSUserDefaults standardUserDefaults] setObject:sessionData
                                                  forKey:kSessionUserDefaultsKey];
        
        [self enableAudioPlaybackWithSession:session];
    };
    
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url
                                            tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapServiceURL]
                                                                 callback:authCallback];
        return YES;
    }
    
    return NO;
}

@end
