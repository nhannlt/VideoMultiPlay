//
//  VideoData.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 5/5/16.
//
//

#import "VideoData.h"

@implementation VideoData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isPlaying = YES;
        self.isDownloaded = NO;
    }
    return self;
}

@end