//
//  TableCellVideo.h
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import <UIKit/UIKit.h>
#import "VideoPlayerViewController.h"

@interface TableCellVideo : UITableViewCell

@property (nonatomic,assign) VideoPlayerViewController *mPlayerViewController;

/**
 *  Description: Action Play or Pause video on Cell
 */
- (void)actionToCell;

/**
 *  Description: setup Video on Cell
 *
 *  @param videoPlayerView is an View Controll a video player with type VideoPlayerViewController.
 */
- (void)setupVideoWithVideoPlayerViewController:(VideoPlayerViewController*)videoPlayerView;

@end
