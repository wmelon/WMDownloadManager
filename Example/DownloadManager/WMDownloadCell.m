//
//  WMDownloadCell.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/12/4.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "WMDownloadCell.h"
#import "NSObject+WMAutoCancel.h"

@interface WMDownloadCell()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (nonatomic, strong) WMDownloadAdapter *download;
@property (nonatomic, copy  ) WMDownActionHandle handle;
@end

@implementation WMDownloadCell

- (void)startDownload:(WMDownloadAdapter *)download handle:(WMDownActionHandle)handle {
    _download = download;
    _handle = handle;
    
    
    CGFloat currentLength = download.progress.completedUnitCount;
    CGFloat fileLength = download.progress.totalUnitCount;
    // 下载进度
    if (fileLength == 0) {
        self.progressView.progress = 0.0;
        self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:00.00%%"];
    } else {
        self.progressView.progress =  1.0 * currentLength / fileLength;
        self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",download.progress.fractionCompleted];
    }
    
    /// 下载速度
    self.speedLabel.text = @"0kb/s";
    
//    [self startDownload];
}

+ (CGFloat)cellHeight {
    return 100;;
}
- (void)startDownload {
    __weak typeof(self) weakSelf = self;
    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull response) {
        if (response.downloadStatus == WMDownloadResponseStatusDownloading) {

            CGFloat currentLength = response.progress.completedUnitCount;
            CGFloat fileLength = response.progress.totalUnitCount;

            // 下载进度
            if (fileLength == 0) {
                weakSelf.progressView.progress = 0.0;
                weakSelf.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:00.00%%"];
            } else {
                weakSelf.progressView.progress =  1.0 * currentLength / fileLength;
                weakSelf.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",response.progress.fractionCompleted];
            }
            
            /// 下载速度
//            weakSelf.speedLabel.text = response.progress.downloadNetworkSpeed;
            
        } else if (response.downloadStatus == WMDownloadResponseStatusSuccess) {
            NSLog(@"direcPath ===   %@",response.direcPath);
            NSLog(@"filepath ===   %@",response.filePath);
            NSLog(@"zipPath ===   %@",response.unZipFilePath);


            if (response.filePath.exists){
                [weakSelf.startBtn setTitle:@"下载完成" forState:(UIControlStateNormal)];
            } else {
                [weakSelf.startBtn setTitle:@"下载失败" forState:(UIControlStateNormal)];
            }

        }
//        else if (response.downloadStatus == WMDownloadResponseStatusFailure) {
//            [weakSelf.startBtn setTitle:@"下载失败" forState:(UIControlStateNormal)];
//        }
    } downloadAdapter:self.download];
    [self autoCancelOnDealloc:self.download];
}
- (void)stopDownload {
    [self.download downloadStop];
}
- (IBAction)downloadAction:(UIButton *)button {
    button.selected = !button.isSelected;
    if (button.isSelected) {
        [self.startBtn setTitle:@"暂停" forState:(UIControlStateNormal)];
        [self startDownload];
    } else {
        [self.startBtn setTitle:@"开始" forState:(UIControlStateNormal)];
        [self stopDownload];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
