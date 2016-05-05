//
//  VideoPlayerNSOperation.h
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import <Foundation/Foundation.h>
#import "ViewAVPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface VideoPlayerNSOperation : NSOperation

@property (strong, nonatomic) NSURL* videoUrl;

@property (strong, nonatomic) ViewAVPlayer* viewAVPlayer;

/**
 *  Description: Init NSOperation with video URL to download it.
 *
 *  @param url address of video.
 *  url can not be NIL.
 */
- (void)initWithURL:(NSURL*)url;

@end

@interface PendingOperation : NSObject

/**
 *  Description: Dictionary contains all VideoPlayerNSOperation wait for excute.
 */
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end