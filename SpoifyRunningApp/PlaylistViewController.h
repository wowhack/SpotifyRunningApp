//
//  ViewController.h
//  SpoifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPTSession;

@interface PlaylistViewController : UITableViewController

-(void)handleNewSession:(SPTSession *)session;

@end

