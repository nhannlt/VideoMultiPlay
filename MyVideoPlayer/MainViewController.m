//
//  MainViewController.m
//  MainViewController
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "MainViewController.h"
#import "VideoTableViewCell.h"

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
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"VideoTableViewCellID"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma -mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    VideoTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        [cell actionToCell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoTableViewCellID" forIndexPath:indexPath];
    if (cell) {
        [cell.positionLabel setText:[NSString stringWithFormat:@"%li",indexPath.row+1]];
        ViewAVPlayer *viewAVPlayer = [self.listVideosCached objectForKey:indexPath];
        if (!viewAVPlayer) {
            [self downloadVideoStart:self.videoURL indexPath:indexPath];
        } else {
            [cell setupVideoWithVideoPlayer:viewAVPlayer];
        }
    }
    return cell;
}

#pragma --mark -------
- (void) downloadVideoStart:(NSURL*)videoURL indexPath:(NSIndexPath*)indexPath {
    
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
    VideoPlayerNSOperation *videoPlayerNSOperation = [[VideoPlayerNSOperation alloc] init];
    videoPlayerNSOperation.viewAVPlayer = [[ViewAVPlayer alloc] init];
    [videoPlayerNSOperation.viewAVPlayer setFrame:CGRectMake((self.view.frame.size.width - 220)/2, 25, 220, 200)];
    [videoPlayerNSOperation initWithURL:videoURL];
    __unsafe_unretained VideoPlayerNSOperation *weakVideoPlayerNSOperation = videoPlayerNSOperation;
    
    videoPlayerNSOperation.completionBlock = ^{
        if (weakVideoPlayerNSOperation.cancelled) {
            return;
        }
        [self.listVideosCached setObject:weakVideoPlayerNSOperation.viewAVPlayer forKey:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Download: %li", indexPath.row);
            [self.pendingOperation.downloadsInProgress removeObjectForKey:indexPath];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
    };
    
    // Set current Operation to list download in progress.
    [self.pendingOperation.downloadsInProgress setObject:videoPlayerNSOperation forKey:indexPath];
    // Add task to queue.
    [self.pendingOperation.downloadQueue addOperation:videoPlayerNSOperation];
}

#pragma -mark UIScrollViewDelegate

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

#pragma -mark PendingOperation
/**
 *  Description: Stop all tasks in current queue when call this function.
 */
- (void)suspendAllOperation {
    self.pendingOperation.downloadQueue.suspended = YES;
}

/**
 *  Description: Resume all tasks in current queue when call this function.
 */
- (void)ressumeAllOperation {
    self.pendingOperation.downloadQueue.suspended = NO;
}

/**
 *  Description: Cancel all task not excuted yet in invisible cells.
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
