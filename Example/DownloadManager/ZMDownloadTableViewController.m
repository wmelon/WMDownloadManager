//
//  ZMDownloadTableViewController.m
//  DownloadManager_Example
//
//  Created by Sper on 2020/12/4.
//  Copyright © 2020 wmelon. All rights reserved.
//

#import "ZMDownloadTableViewController.h"
#import "WMDownloadCell.h"
#import "WMDownloadCacheManager+WMFilePath.h"
#import "NSObject+WMAutoCancel.h"

@interface ZMDownloadTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<WMDownloadAdapter *> *downloads;
@end

@implementation ZMDownloadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WMDownloadCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WMDownloadCell class])];
    [self loadData];
}
- (void)loadData {
    NSMutableArray *array = [NSMutableArray array];
    
    /// mp4下载
    NSString *mp4Url = @"https://image.zmlearn.com/coursewarezmgx/package/mp4/20200401/bdec5ae9e67a4e1193b694a03dda1f87.mp4";
    NSString *mp4UrlDict = [WMDownloadCacheManager previewPathWith:@"lessonId001" resourceId:@"" version:@""];
    WMDownloadAdapter *mp4Down = [WMDownloadAdapter downloadWithUrl:mp4Url direcPath:mp4UrlDict];
    [array addObject:mp4Down];
    
    /// zip下载
    NSString *zipUrl = @"https://rs.hdkj.zmlearn.com/coursewarezmgx-fat/zmg2/renderer/genius/homework/sdk/12271/20201116-003/1605518812186/product.zip";
    NSString *zipUrlDict = [WMDownloadCacheManager previewPathWith:@"lessonId002" resourceId:@"" version:@""];
    WMDownloadAdapter *zipUrlDown = [WMDownloadAdapter downloadWithUrl:zipUrl direcPath:zipUrlDict];
    [array addObject:zipUrlDown];
    
    /// dmg下载
    NSString *dmgUrl = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
    NSString *dmgUrlDict = [WMDownloadCacheManager previewPathWith:@"lessonId003" resourceId:@"" version:@""];
    WMDownloadAdapter *dmgUrlDown = [WMDownloadAdapter downloadWithUrl:dmgUrl direcPath:dmgUrlDict];
    [array addObject:dmgUrlDown];
    
//    for (int i = 0 ;i < 10 ;i ++) {
//        /// dmg下载
//        NSString *dmgUrl111 = @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg";
//        NSString *dmgUrlDict111 = [WMDownloadCacheManager previewPathWith:@"lessonId003" resourceId:[NSString stringWithFormat:@"%d",i] version:@""];
//        WMDownloadAdapter *dmgUrlDown1111 = [WMDownloadAdapter downloadWithUrl:dmgUrl111 direcPath:dmgUrlDict111];
//        [array addObject:dmgUrlDown1111];
//    }
    
    
    self.downloads = array;
    [self.tableView reloadData];
}

- (void)startDownlaod:(WMDownloadAdapter *)download cell:(WMDownloadCell *)cell{
    __weak typeof(self) weakSelf = self;
//    [WMDownloadManager downloadWithcomplete:^(WMDownloadAdapter * _Nonnull response) {
//        if (response.downloadStatus == WMDownloadResponseStatusDownloading) {
//
//            CGFloat currentLength = response.progress.completedUnitCount;
//            CGFloat fileLength = response.progress.totalUnitCount;
//
//            // 下载进度
//            if (fileLength == 0) {
//                cell.progressView.progress = 0.0;
//                cell.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:00.00%%"];
//            } else {
//                cell.progressView.progress =  1.0 * currentLength / fileLength;
//                cell.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%  %@",response.progress.fractionCompleted,response.progress.downloadNetworkSpeed];
//            }
//
//        } else if (response.downloadStatus == WMDownloadResponseStatusSuccess) {
//            NSLog(@"direcPath ===   %@",response.direcPath);
//            NSLog(@"filepath ===   %@",response.filePath);
//            NSLog(@"zipPath ===   %@",response.unZipFilePath);
//
//
//            if (response.filePath.exists){
//                [cell.startBtn setTitle:@"下载完成" forState:(UIControlStateNormal)];
//            } else {
//                [cell.startBtn setTitle:@"下载失败" forState:(UIControlStateNormal)];
//            }
//
//        }
////        else if (response.downloadStatus == WMDownloadResponseStatusFailure) {
////            [weakSelf.startBtn setTitle:@"下载失败" forState:(UIControlStateNormal)];
////        }
//    } downloadAdapter:download];
//    [self autoCancelOnDealloc:download];
}
#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WMDownloadCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WMDownloadAdapter *download = self.downloads[indexPath.row];
//    __weak typeof(self) weakSelf = self;
    [cell startDownload:download handle:^(UIButton * _Nonnull btn) {
//        [weakSelf startDownlaod:download cell:cell];
    }];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [WMDownloadCell cellHeight];
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}
- (void)dealloc {
    NSLog(@"[dealloc %@]" ,self);
}
@end
