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

@interface WMViewController ()
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, strong) UIButton *unZipBtn;
@end

@implementation WMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.btn];
    [self.view addSubview:self.clearBtn];
}
- (void)downloadData {
    [self downloadMp4];
}
- (void)clearAllData {
    [WMDownloadCacheManager cleanDisk];
    if ([WMDownloadCacheManager fileExistsAtPath:WMDownload_resource_history_cache_PATH]){
        [self.btn setTitle:@"清空失败" forState:(UIControlStateNormal)];
    } else {
        [self.btn setTitle:@"下载" forState:(UIControlStateNormal)];
    }
}
- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _btn.backgroundColor = [UIColor redColor];
        [_btn setTitle:@"下载" forState:(UIControlStateNormal)];
        [_btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_btn addTarget:self action:@selector(downloadData) forControlEvents:(UIControlEventTouchUpInside)];
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
- (void)downloadMp4{
//    @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"
    NSString *url = @"https://image.zmlearn.com/coursewarezmgx/package/mp4/20200401/bdec5ae9e67a4e1193b694a03dda1f87.mp4";
//    NSString *url = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d/4/p_9f7b2874-908d-4d6c-a849-6f411cba7c9d.zip";
//    NSString *url = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/renderer/genius/homework/sdk/12271/20201116-003/1605518812186/product.zip";
    
    /// 文件夹路径
    NSString *direcPath = [WMDownloadCacheManager previewPathWith:@"lessonId001" resourceId:@"resourceId002" version:@"version_2.3.0"];
    /// 真实文件路径
    NSString *filePath = [WMDownloadCacheManager filePathWithDictPath:direcPath url:url];
    if ([WMDownloadCacheManager fileExistsAtPath:filePath]){
        [self.btn setTitle:@"已经下载" forState:(UIControlStateNormal)];
        return;
    }
    /// 没有下载开始下载
    WMDiyDownload *download = [WMDiyDownload downloadWithUrl:url];
    [download configDirecPath:direcPath];
    /// 开启下载文件
    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull response) {
        if (response.respStatus == WMDownloadResponseStatusProgress) {
            NSLog(@"%@",response.progress);
        } else if (response.respStatus == WMDownloadResponseStatusSuccess) {
            NSLog(@"direcPath ===   %@",response.direcPath);
            NSLog(@"filepath ===   %@",response.filePath);
            NSLog(@"zipPath ===   %@",response.unZipFilePath);
            
            if ([WMDownloadCacheManager fileExistsAtPath:response.filePath]){
                [self.btn setTitle:@"已经下载" forState:(UIControlStateNormal)];
            } else {
                [self.btn setTitle:@"下载失败" forState:(UIControlStateNormal)];
            }
            
        } else if (response.respStatus == WMDownloadResponseStatusFailure) {
            NSLog(@"%@",response.error);
        }
    } downloadAdapter:download];
    /// 界面销毁停止请求
    [self autoCancelOnDealloc:download];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
