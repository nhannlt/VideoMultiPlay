//
//  MainViewController.h
//  MainViewController
//
//  Created by Nguyen Le Trong Nhan on 4/29/16.
//
//

#import <UIKit/UIKit.h>
#import "VideoPlayerNSOperation.h"
#import "ViewAVPlayer.h"

@interface MainViewController : UIViewController

@property (strong, nonatomic) NSCache *listVideosCached;

@property (nonatomic, retain) PendingOperation *pendingOperation;


@end
