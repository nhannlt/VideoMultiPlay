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
    
    // Add neccessary observer.
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
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

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

#pragma KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        [self.player play];
        NSLog(@"Video is playing");
    }
    if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
        NSLog(@"Player item failed:%@",self.player.currentItem.error);
    }
    if (self.player.currentItem.status == AVPlayerItemStatusUnknown) {
        NSLog(@"Player item unknown");
    }
    
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (self.playerItem.playbackBufferEmpty) {
            NSLog(@"Buffer Empty");
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        if (self.playerItem.playbackLikelyToKeepUp) {
            NSLog(@"LikelyToKeepUp");
        }
    }
    
}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    self.playerItem = nil;
    self.playerLayer = nil;
    self.player = nil;
    [super dealloc];
}
@end
