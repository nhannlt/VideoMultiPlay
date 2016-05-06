//
//  ViewAVPlayer.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 5/5/16.
//
//

#import "ViewAVPlayer.h"

@interface ViewAVPlayer ()

@property (nonatomic, strong) AVPlayerItem *playerItem;


@end

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

- (void)initPlayerWithURL:(NSURL *)url {
    
    self.asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset];
    
    // Re-play when reach to end by default nofitication
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    // Init AVPlayerLayer item
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer =  [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
    
}

/**
 *  // Re-play when reach to end by default nofitication
 *
 *  @param notification contains AVPlayerItem
 */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    self.playerItem = nil;
    self.playerLayer = nil;
    self.player = nil;
    [super dealloc];
}
@end
