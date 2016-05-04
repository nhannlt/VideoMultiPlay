//
//  TableCellVideo.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "TableCellVideo.h"

@implementation TableCellVideo

@synthesize mPlayerViewController;

- (void)setupVideoWithVideoPlayerViewController:(VideoPlayerViewController*)videoPlayerView {
    
        self.mPlayerViewController = videoPlayerView;
        [self.contentView addSubview:self.mPlayerViewController.view];
    
}

- (void)prepareForReuse {

    if (self.mPlayerViewController) {
        [self.mPlayerViewController.view removeFromSuperview];
        self.mPlayerViewController = nil;
    }
    
}

-(void)actionToCell {

    [self.mPlayerViewController pauseOrPlayVideo];

}
@end
