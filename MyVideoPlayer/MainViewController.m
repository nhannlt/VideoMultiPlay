//
//  MainViewController.m
//  MainViewController
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import "MainViewController.h"
#import "VideoTableViewCell.h"

@interface MainViewController  () <UITableViewDelegate,UITableViewDataSource, AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *videoURLs;

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
    self.videoURLs = [NSArray arrayWithObjects:
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/2/21/21fdad97-5a9a-400d-9c03-f7aa69328311_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/c/cb/cb1bcbee-36b7-4fec-a9d1-1d3ea7aecc01_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/2/27/27081582-02a5-4a59-832d-2de57957c571_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/1/17/17433308-68d9-45dc-8cd8-6f4e77d75a06_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/04/1/13/1322c8ef-882e-4232-9e45-6c258c74b015_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/04/e/e8/e895bb1c-a55e-46a8-90f8-fbb006454d81_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/a/a5/a5e5e467-5068-44cd-a1c2-044c356b5510_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2016/05/2/27/27081582-02a5-4a59-832d-2de57957c571_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2014/06/e/e1/e1204d1c-6b96-4240-9ca6-4e0270261b9f_hq.mp4"],
                      [NSURL URLWithString:@"http://av.voanews.com/Videoroot/Pangeavideo/2014/06/b/be/be85630e-08ac-4d4c-9d90-27eec1771364_hq.mp4"],
                      nil];
    
    // Set up UITableView
    CGRect frame = self.view.frame;
    frame.origin.y = 10;
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:@"VideoTableViewCellID"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma -mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
        [cell.positionLabel setText:[NSString stringWithFormat:@"%i",indexPath.row+1]];
        ViewAVPlayer *viewAVPlayer = [self.listVideosCached objectForKey:indexPath];
        if (!viewAVPlayer) {
            [self downloadVideoStart:self.videoURLs[indexPath.row] indexPath:indexPath];
        } else {
            [cell setupVideoWithVideoPlayer:viewAVPlayer];
        }
    }
    return cell;
}

#pragma --mark -------
- (void) downloadVideoStart:(nonnull NSURL*)videoURL indexPath:(nonnull NSIndexPath*)indexPath {
    
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
    [videoPlayerNSOperation initWithURL:videoURL];
    __unsafe_unretained VideoPlayerNSOperation *weakVideoPlayerNSOperation = videoPlayerNSOperation;
    
    videoPlayerNSOperation.completionBlock = ^{
        if (weakVideoPlayerNSOperation.cancelled) {
            return;
        }
        [self.listVideosCached setObject:weakVideoPlayerNSOperation.viewAVPlayer forKey:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Download: %i", indexPath.row);
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
