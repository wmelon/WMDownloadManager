//
//  WMDownloadCell.h
//  DownloadManager_Example
//
//  Created by Sper on 2020/12/4.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMDownloadManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WMDownActionHandle)(UIButton *btn);

@interface WMDownloadCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
//@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
//@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
//@property (weak, nonatomic) IBOutlet UIButton *startBtn;
- (void)startDownload:(WMDownloadAdapter *)download handle:(WMDownActionHandle)handle;
+ (CGFloat)cellHeight;
@end

NS_ASSUME_NONNULL_END
