//
//  NowPlayingTableViewCell.h
//  SpotifyRunningApp
//
//  Created by Albert Örwall on 05/08/14.
//  Copyright (c) 2014 Albert Örwall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NowPlayingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *spmLabel;

@end
