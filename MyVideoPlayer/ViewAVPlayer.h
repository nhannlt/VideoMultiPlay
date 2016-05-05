//
//  ViewAVPlayer.h
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 5/5/16.
//
//

#import <UIKit/UIKit.h>
#import "VideoData.h"

@class AVPlayer;

@interface ViewAVPlayer : UIView

@property (nonatomic, retain) AVPlayer *player;

@property (nonatomic, strong) VideoData *videoData;

/**
 *  Description: Set AVPlayer for player view.
 *
 *  @param player is AVPlayer
 */
- (void)setPlayer:(AVPlayer*)player;

/**
 *  Description: Set fill mode for video view
 *
 *  @param fillMode: Mode of video gravity. 
 */
- (void)setVideoFillMode:(NSString *)fillMode;

/**
 *  Pause video
 */
- (void)pauseVideo;

/**
 *  Description: Play video
 */
- (void)playVideo;

@end