//
//  MainViewController.m
//  MainViewController
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "MainViewController.h"
#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TableCellVideo.h"

@interface MainViewController  () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSURL *videoURL;

@end

@implementation MainViewController

- (void)dealloc {
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupViewAndData];
    
}

/**
 *  Description: Set up sub views and Data source.
 */
- (void)setupViewAndData {
    
    // Setup data
    self.listVideosCached = [NSCache new];
    [self.listVideosCached setCountLimit:15];
    self.pendingOperation = [[PendingOperation alloc] init];
    self.videoURL = [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/2/21/21fdad97-5a9a-400d-9c03-f7aa69328311.mp4"];
    
    // Set up UITableView
    CGRect frame = self.view.frame;
    frame.origin.y = 20;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableCellVideo" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
}

#pragma -mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 100;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 250;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TableCellVideo *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        // Demo Play/Pause video
        [cell actionToCell];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableCellVideo *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell) {
        VideoPlayerViewController *videoPlayerVC = [self.listVideosCached objectForKey:indexPath];
        if (!videoPlayerVC) {
            [self startDownloadVideo:self.videoURL indexPath:indexPath];
        } else {
            
            [cell setupVideoWithVideoPlayerViewController:videoPlayerVC];
        }
        
    }
    return cell;
    
}

- (void) startDownloadVideo:(NSURL*)videoURL indexPath:(NSIndexPath*)indexPath {
    
    NSAssert(videoURL, @"Video URL can not be NIL");
    NSAssert(indexPath, @"IndexPath can not be NIL");
    
    // Return if video was cached.
    if ([self.listVideosCached objectForKey:indexPath]) {
        return;
    }
    
    // Return if download video is in progress.
    if ([self.pendingOperation.downloadsInProgress objectForKey:indexPath]) {
        return;
    }
    
    // Init operation and excute task.
    VideoPlayerNSOperation *downloader = [[VideoPlayerNSOperation alloc] init];
    [downloader initWithURL:videoURL];
    __unsafe_unretained VideoPlayerNSOperation *weakDownloader = downloader;
    downloader.completionBlock = ^{
        if (weakDownloader.cancelled) {
            return;
        }
        [self.listVideosCached setObject:weakDownloader.videoPlayerVC forKey:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Downloaded: %i", indexPath.row);
            
            [self.pendingOperation.downloadsInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
        
    };
    
    // Set current Operation to list download in progress.
    [self.pendingOperation.downloadsInProgress setObject:downloader forKey:indexPath];
    
    // Add task to queue.
    [self.pendingOperation.downloadQueue addOperation:downloader];
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // When user start scrolling, suppend all task in queue.
    [self suspendAllOperation];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // When end decelerate, Reload visible cells and Resume all task in current queue
    [self cancelPendingOpenration];
    [self ressumeAllOperation];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (decelerate == NO) {
        [self cancelPendingOpenration];
        [self ressumeAllOperation];
    }
    
}

/**
 *  Description: Stop all task in current queue when call.
 */
- (void)suspendAllOperation {
    
    self.pendingOperation.downloadQueue.suspended = YES;
    
}

/**
 *  Description: Resume all task in current queue when call.
 */

- (void)ressumeAllOperation {
    
    self.pendingOperation.downloadQueue.suspended = NO;
    
}

/**
 *  Description: Cancel all task not excute yet in invisible cells.
 */
- (void)cancelPendingOpenration {
    
    NSArray *listIndexPathsVisible = [self.tableView indexPathsForVisibleRows];
    NSMutableArray *listKeysAll = [NSMutableArray arrayWithArray:[self.pendingOperation.downloadsInProgress allKeys]];
    [listKeysAll removeObjectsInArray:listIndexPathsVisible];
    for (NSIndexPath *index in listKeysAll) {
        [[self.pendingOperation.downloadsInProgress objectForKey:index] cancel];
        [self.pendingOperation.downloadsInProgress removeObjectForKey:index];
    }
    
}

@end
