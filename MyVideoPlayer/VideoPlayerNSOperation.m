//
//  VideoPlayerNSOperation.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "VideoPlayerNSOperation.h"


@implementation VideoPlayerNSOperation

- (instancetype)init {

    self = [super init];
    return self;
    
}

- (void)initWithURL:(NSURL*)url {

    NSAssert(url, @"URL can not be NIL");
    
    self.videoUrl = [url copy];
    
}

/**
 *  Override from NSOperation
 */
- (void)main {
    
    [super main];
    // Check current task is in Cancelled status.
    // Step #1
    if (self.cancelled) {
        return;
    }
    
    // Step #2: Init Video Player.
    VideoPlayerViewController *mVideoPlayerVC = [[VideoPlayerViewController alloc] init];
    mVideoPlayerVC.URL = self.videoUrl;
    
    // Check current task is in Cancelled status.
    // Maybe Operation was cancelled after excute step #2
    // Step #3
    if (self.cancelled) {
        return;
    }
    
    // Step #4: save tmp data.
    if (mVideoPlayerVC) {
        self.videoPlayerVC = mVideoPlayerVC;
    }
    
}

@end

@implementation PendingOperation

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        self.downloadsInProgress = [NSMutableDictionary new];
        self.downloadQueue = [NSOperationQueue new];
        self.downloadQueue.maxConcurrentOperationCount = 4;
        
    }
    return self;
    
}


@end

