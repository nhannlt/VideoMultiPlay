//
//  ViewAVPlayer.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 5/5/16.
//
//

#import "ViewAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation ViewAVPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoData = [[VideoData alloc] init];
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode {
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void)pauseVideo {
    [self.player pause];
}

- (void)playVideo {
    [self.player play];
}

@end
