//
//  VideoTableViewCell.h
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import <UIKit/UIKit.h>
#import "VideoPlayerViewController.h"
#import "ViewAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoData.h"

@interface VideoTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet ViewAVPlayer *viewAVPlayer;
@property (retain, nonatomic) IBOutlet UILabel *positionLabel
;
@property (retain, nonatomic) IBOutlet UIView *background;

/**
 *  Description: Action Play or Pause video on Cell when user click to cell.
 */
- (void)actionToCell;

/**
 *  Description: setup Video on Cell
 *
 *  @param mViewAVPlayer is an View Controll a video player with type ViewAVPlayer.
 */
- (void)setupVideoWithVideoPlayer:(ViewAVPlayer*)mViewAVPlayer;

@end


