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

@interface WMViewController ()
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *clearBtn;
@end

@implementation WMViewController

- (void)viewDidLoad
{
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
    NSString *url = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/renderer/genius/homework/sdk/12271/20201116-003/1605518812186/product.zip";
    NSString *filePath = [WMDownloadCacheManager previewPathWith:@"123" resourceId:@"456" version:@"3.2.1" url:url];
    
    if ([WMDownloadCacheManager fileExistsAtPath:filePath]){
        [self.btn setTitle:@"已经下载" forState:(UIControlStateNormal)];
        return;
    }
    /// 没有下载开始下载
    WMDownloadAdapter *download = [WMDownloadAdapter downloadWithUrl:url];
    [download configFilePath:filePath];
    /// 开启下载文件
    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull response) {
        if (response.respStatus == WMDownloadResponseStatusProgress) {
            NSLog(@"%@",response.progress);
        } else if (response.respStatus == WMDownloadResponseStatusSuccess) {
            NSLog(@"filepath ===   %@",response.storeFilePath);
            NSLog(@"filename ===   %@",response.storeFileName);
        } else if (response.respStatus == WMDownloadResponseStatusFailure) {
            NSLog(@"%@",response.error);
        }
        
        if ([WMDownloadCacheManager fileExistsAtPath:filePath]){
            [self.btn setTitle:@"已经下载" forState:(UIControlStateNormal)];
        } else {
            [self.btn setTitle:@"下载失败" forState:(UIControlStateNormal)];
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
