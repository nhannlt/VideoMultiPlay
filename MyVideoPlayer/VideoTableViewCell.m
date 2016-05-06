//
//  VideoTableViewCell.m
//  MyVideoPlayer
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "VideoTableViewCell.h"

@implementation VideoTableViewCell


- (void)setupVideoWithVideoPlayer:(ViewAVPlayer*)mViewAVPlayer {
    self.viewAVPlayer = mViewAVPlayer;
    [self.viewAVPlayer.playerLayer setFrame:CGRectMake((self.window.frame.size.width - 300)/2, 0, 300, 250)];
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

- (UIWebView *)embedVideoYoutubeWithURL:(NSString *)urlString andFrame:(CGRect)frame {
    NSString *videoID = [self extractYoutubeVideoID:urlString];
    
    NSString *embedHTML = @"\
    <html><head>\
    <style type=\"text/css\">\
    body {\
    background-color: transparent;\
    color: white;\
    }\
    </style>\
    </head><body style=\"margin:0\">\
    <embed id=\"yt\" src=\"http://www.youtube.com/v/%@\" type=\"application/x-shockwave-flash\" \
    width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </body></html>";
    NSString *html = [NSString stringWithFormat:embedHTML, videoID, frame.size.width, frame.size.height];
    UIWebView *videoWebView = [[UIWebView alloc] initWithFrame:frame];
    [videoWebView loadHTMLString:html baseURL:nil];
    
    return videoWebView;
}

/**
 @see https://devforums.apple.com/message/705665#705665
 extractYoutubeVideoID: works for the following URL formats:
 
 www.youtube.com/v/VIDEOID
 www.youtube.com?v=VIDEOID
 www.youtube.com/watch?v=WHsHKzYOV2E&feature=youtu.be
 www.youtube.com/watch?v=WHsHKzYOV2E
 youtu.be/KFPtWedl7wg_U923
 www.youtube.com/watch?feature=player_detailpage&v=WHsHKzYOV2E#t=31s
 youtube.googleapis.com/v/WHsHKzYOV2E
 */

- (NSString *)extractYoutubeVideoID:(NSString *)urlYoutube {
    NSString *regexString = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:urlYoutube options:0 range:NSMakeRange(0, [urlYoutube length])];
    
    if(!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        NSString *substringForFirstMatch = [urlYoutube substringWithRange:rangeOfFirstMatch];
        
        return substringForFirstMatch;
    }
    
    return nil;
}

@end

