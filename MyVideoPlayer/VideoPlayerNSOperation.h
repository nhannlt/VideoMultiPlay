//
//  VideoPlayerNSOperation.h
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import <Foundation/Foundation.h>
#import "VideoPlayerViewController.h"

@interface VideoPlayerNSOperation : NSOperation

@property (strong, nonatomic) NSURL* videoUrl;

@property (strong, nonatomic) VideoPlayerViewController* videoPlayerVC;

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