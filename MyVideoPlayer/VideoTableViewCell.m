//
//  VideoTableViewCell.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "VideoTableViewCell.h"

@implementation VideoTableViewCell

@synthesize background;


- (void)setupVideoWithVideoPlayer:(ViewAVPlayer*)mViewAVPlayer {
    
    self.viewAVPlayer = mViewAVPlayer;
    [self.viewAVPlayer.playerLayer setFrame:CGRectMake((self.window.frame.size.width - 300)/2, 0, 300, 270)];
    [self.layer addSublayer:self.viewAVPlayer.playerLayer];
    [self setStatusForVideo];
}

/**
 *  Description: Remove AVPlayer view from cell before reuse.
 */
- (void)prepareForReuse {
    if (self.viewAVPlayer.playerLayer) {
        [self.viewAVPlayer.playerLayer removeFromSuperlayer];
    }
}

/**
 *  Description: update Play/Pause video status folowing VideoData
 */
- (void)setStatusForVideo {
    if (self.viewAVPlayer.videoData.isPlaying == YES) {
        [self.viewAVPlayer playVideo];
    } else {
        [self.viewAVPlayer pauseVideo];
    }
}

-(void)actionToCell {
    if (self.viewAVPlayer.videoData.isPlaying == NO) {
        [self.viewAVPlayer playVideo];
        self.viewAVPlayer.videoData.isPlaying = YES;
    } else {
        [self.viewAVPlayer pauseVideo];
        self.viewAVPlayer.videoData.isPlaying = NO;
    }
}

- (void)dealloc {
    [_viewAVPlayer release];
    [super dealloc];
}

@end

