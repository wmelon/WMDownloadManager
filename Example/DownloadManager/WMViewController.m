//
//  WMViewController.m
//  DownloadManager
//
//  Created by wmelon on 11/19/2020.
//  Copyright (c) 2020 wmelon. All rights reserved.
//

#import "WMViewController.h"
#import "WMDownloadManager.h"
#import "NSObject+WMAutoCancel.h"
#import "WMDownloadCacheManager+WMFilePath.h"
#import "WMDiyDownload.h"
#import "ZMDownloadTableViewController.h"

typedef NS_ENUM(NSInteger,WMButtonStatus) {
    WMButtonStatus_start,   /// 开始
    WMButtonStatus_resume,  /// 重新开始
    WMButtonStatus_pause  /// 暂停
};

@interface WMViewController ()

@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *unZipBtn;
@property (nonatomic, strong) WMDiyDownload *download;
@property (nonatomic, strong) UIProgressView *progressView;
/** 下载进度条Label */
@property (strong, nonatomic) UILabel *progressLabel;
@property (nonatomic, assign) WMButtonStatus type;
@end

@implementation WMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.btn];
    [self.view addSubview:self.clearBtn];
    
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.progressLabel];
}
/// 下载和暂停按钮
- (void)downloadData:(UIButton *)button {
    ZMDownloadTableViewController *vc = [ZMDownloadTableViewController new];
    [self presentViewController:vc animated:YES completion:nil];
    
    
//    button.selected = !button.isSelected;
//    if (button.isSelected) {
//        [self downloadMp4];
//    } else {
//        [WMDownloadManager downloadStopWithRequest:self.download];
//    }
//    
//    if (self.type == WMButtonStatus_start){ /// 开始下载
//        [self.btn setTitle:@"暂停下载" forState:(UIControlStateNormal)];
//        self.type = WMButtonStatus_pause;
//
        
//
//    } else if (self.type == WMButtonStatus_pause) {
//        [self.btn setTitle:@"继续下载" forState:(UIControlStateNormal)];
//        self.type = WMButtonStatus_resume;
//
//        [WMDownloadManager pauseDownload:self.download];
//
//    } else if (self.type == WMButtonStatus_resume) {
//        self.type = WMButtonStatus_pause;
//        [self.btn setTitle:@"暂停下载" forState:(UIControlStateNormal)];
//
//        [self resumeDownload];
//    }
//    [self batchDownload];
}
- (void)clearAllData {
    [[WMDownloadCacheManager sharedInstance] removeAllItems];
    self.type = WMButtonStatus_start;
    [self.btn setTitle:@"开始下载" forState:(UIControlStateNormal)];
}

- (void)resumeDownload {
//    [WMDownloadManager resumeDownload:self.download];
}
- (void)batchDownload {
    [self downZip];
    [self downDmg];
    [self downloadMp4];
}

- (void)downZip {
//    NSString *zipUrl = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d/4/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d.zip";
//    NSString *zipDict = [WMDownloadCacheManager previewPathWith:@"lessonId001" resourceId:@"resourceId002" version:@"version_2.3.02"];
//
//    WMDownloadAdapter *zipDown = [WMDownloadAdapter downloadWithUrl:zipUrl];
//    [zipDown configDirecPath:zipDict];
//    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull responses) {
//
//        if (zipDown.respStatus & WMDownloadResponseStatusSuccess) {
//            NSLog(@"zipDown  ---- filePath ===== %@",zipDown.filePath);
//        }
//
//    } downloadAdapter:zipDown];
//    [self autoCancelOnDealloc:zipDown];
}
- (void)downDmg {
//    NSString *dmgUrl = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
//    NSString *dmgDict = [WMDownloadCacheManager previewPathWith:@"lessonId001" resourceId:@"resourceId002" version:@"version_2.3.01"];
//
//    WMDownloadAdapter *dmgDown = [WMDownloadAdapter downloadWithUrl:dmgUrl];
//    [dmgDown configDirecPath:dmgDict];
//
//    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull responses) {
//        if (dmgDown.respStatus & WMDownloadResponseStatusSuccess) {
//            NSLog(@"dmgDown  ---- filePath ===== %@",dmgDown.filePath);
//        }
//    } downloadAdapter:dmgDown];
//    [self autoCancelOnDealloc:dmgDown];
}

- (void)downloadMp4{
//    
//    [WMDownloadCacheManager removeItemAtPath:@"/Users/sper/Library/Developer/CoreSimulator/Devices/E8435D0C-ADF6-4C4A-B8C4-3BEF60AF01CF/data/Containers/Data/Application/C128D014-6D03-4D0A-9071-317FB3EF19F8/Library/Caches/com.AiKit.download.files/preview/lessonId001/resourceId002/version_2.3.0/729f072d452cddc443ecebd546b9eddf.mp4"];
//    
//    return;
    

//    NSString *url = @"https://image.zmlearn.com/coursewarezmgx/package/mp4/20200401/bdec5ae9e67a4e1193b694a03dda1f87.mp4";
    
//    NSString *url = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d/4/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d.zip";
    
//    NSString *url = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/renderer/genius/homework/sdk/12271/20201116-003/1605518812186/product.zip";
    
    
    NSString *url = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
    /// 文件夹路径
    NSString *direcPath = [WMDownloadCacheManager previewPathWith:@"lessonId001" resourceId:@"" version:@""];
    
    __weak typeof(self) weakSelf = self;
    /// 没有下载开始下载
    WMDiyDownload *download = [WMDiyDownload downloadWithUrl:url direcPath:direcPath];

    /// 开启下载文件
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
                weakSelf.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%  %@",response.progress.fractionCompleted,response.progress.downloadNetworkSpeed];
            }
            NSLog(@"%@",weakSelf.progressLabel.text);
        } else if (response.downloadStatus == WMDownloadResponseStatusSuccess) {
            NSLog(@"direcPath ===   %@",response.direcPath);
            NSLog(@"filepath ===   %@",response.filePath);
            NSLog(@"zipPath ===   %@",response.unZipFilePath);


            if (response.filePath.exists){
                [weakSelf.btn setTitle:@"已经下载" forState:(UIControlStateNormal)];
            } else {
                [weakSelf.btn setTitle:@"下载失败" forState:(UIControlStateNormal)];
            }

        } else if (response.downloadStatus == WMDownloadResponseStatusFailure) {
            NSLog(@"%@",response.error);
        }
    } downloadAdapter:download];
    self.download = download;
    /// 界面销毁停止请求
    [self autoCancelOnDealloc:download];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:(UIProgressViewStyleDefault)];
        _progressView.frame = CGRectMake(20, CGRectGetMaxY(self.clearBtn.frame) + 50, 300, 30);
    }
    return _progressView;
}
- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.progressView.frame) + 40, 300, 40)];
        _progressLabel.textColor = [UIColor blackColor];
    }
    return _progressLabel;
}
- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _btn.backgroundColor = [UIColor redColor];
        [_btn setTitle:@"开始" forState:(UIControlStateNormal)];
        [_btn setTitle:@"暂停" forState:(UIControlStateSelected)];
        self.type = WMButtonStatus_start;
        [_btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_btn addTarget:self action:@selector(downloadData:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _btn;
}
- (UIButton *)clearBtn {
    if (!_clearBtn) {
        _clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 210, 100, 100)];
        _clearBtn.backgroundColor = [UIColor yellowColor];
        [_clearBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        [_clearBtn setTitle:@"清空" forState:(UIControlStateNormal)];
        [_clearBtn addTarget:self action:@selector(clearAllData) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    return _clearBtn;
}
@end
