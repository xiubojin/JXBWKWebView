//
//  ViewController.m
//  JXBWebKitProject
//
//  Created by 金修博 on 2018/8/3.
//  Copyright © 2018年 金修博. All rights reserved.
//

#import "ViewController.h"
#import <JXBWebViewController.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SSZipArchive.h>
#import "H5EnterModel.h"
#import "HybridViewController.h"
#import "TestWebViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *models;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.navigationController.navigationBar.translucent = NO;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.models = @[].mutableCopy;
    
    H5EnterModel *model1 = [[H5EnterModel alloc] init];
    model1.title = @"百度";
    model1.detailTitle = @"https://www.baidu.com";
    model1.url = @"https://www.baidu.com";
    [self.models addObject:model1];
    
    H5EnterModel *model2 = [[H5EnterModel alloc] init];
    model2.title = @"post请求";
    model2.detailTitle = @"body={username=zhangsan&password=123456}";
    model2.url = @"http://www.mocky.io/v2/5adef15a3300002500e4d6bb";
    [self.models addObject:model2];
    
    H5EnterModel *model3 = [[H5EnterModel alloc] init];
    model3.title = @"交互测试";
    model3.detailTitle = @"使用的本地h5.html文件";
    model3.url = [NSString stringWithFormat:@"file://%@",[[NSBundle mainBundle] pathForResource:@"h5" ofType:@"html"]];
    [self.models addObject:model3];
    
    H5EnterModel *model4 = [[H5EnterModel alloc] init];
    model4.title = @"请求带cookie";
    model4.detailTitle = @"cookie={key1=value1;key2=value2}";
    model4.url = @"http://passport.58corp.com";
    model4.cookie = @{@"key1":@"value1", @"key2":@"value2"};
    [self.models addObject:model4];
    
    H5EnterModel *model5 = [[H5EnterModel alloc] init];
    model5.title = @"H5秒开优化方案1 - 模板渲染";
    model5.detailTitle = @"服务端下发html模板和数据，客户端负责渲染，适合类似新闻详情页等业务场景";
    [self.models addObject:model5];
    
    H5EnterModel *model6 = [[H5EnterModel alloc] init];
    model6.title = @"H5秒开优化方案2 - 离线包";
    model6.detailTitle = @"将html、css、js等静态资源分离，资源可以做到增量更新，适合所有业务场景";
    [self.models addObject:model6];
    
    H5EnterModel *model7 = [[H5EnterModel alloc] init];
    model7.title = @"新浪网";
    model7.detailTitle = @"https://www.sina.com.cn";
    model7.url = @"https://www.sina.com.cn";
    [self.models addObject:model7];
    
    H5EnterModel *model8 = [[H5EnterModel alloc] init];
    model8.title = @"搜狐网";
    model8.detailTitle = @"http://www.sohu.com";
    model8.url = @"http://www.sohu.com";
    [self.models addObject:model8];
    
    H5EnterModel *model9 = [[H5EnterModel alloc] init];
    model9.title = @"爱奇艺";
    model9.detailTitle = @"https://v.qq.com";
    model9.url = @"https://v.qq.com";
    [self.models addObject:model9];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    H5EnterModel *model = self.models[indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseid"];
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    cell.detailTextLabel.text = model.detailTitle;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    H5EnterModel *model = self.models[indexPath.row];
    
    if (indexPath.row == 0 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8) {
        TestWebViewController *webVC = [[TestWebViewController alloc] initWithURLString:model.url];
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 1) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:model.url]];
        request.HTTPMethod = @"POST";
        NSString *str = @"username=jxb&password=123456";
        request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        JXBWebViewController *webVC = [[JXBWebViewController alloc] initWithURLRequest:request];
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 2) {
        JXBWebViewController *webVC = [[JXBWebViewController alloc] initWithURLString:model.url];
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 3) {
//        JXBWebViewController *webVC = [[JXBWebViewController alloc] initWithURL:[NSURL URLWithString:model.url] cookie:model.cookie];
//        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 4) {
        HybridViewController *webVC = [[HybridViewController alloc] init];
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.row == 5) {
        [self requestOfflinePkg];
    }
}

//下载离线包html+css
- (void)requestOfflinePkg {
    NSString *zipName    = @"offline_pkg";
    NSString *zipUrl     = [NSString stringWithFormat:@"http://localhost:9090/source/%@.zip", zipName];
    NSURL    *url        = [NSURL URLWithString:zipUrl];
    NSString *md5        = [self md5:zipUrl];
    NSArray  *pathes     = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path       = [pathes objectAtIndex:0];
    NSString *zipPath    = [NSString stringWithFormat:@"%@/zipDownload/%@",path,md5];
    NSString *unzipPath  = [NSString stringWithFormat:@"%@/%@.zip",path,md5];


    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error) {
            [data writeToFile:unzipPath options:0 error:nil];

            BOOL result = [SSZipArchive unzipFileAtPath:unzipPath toDestination:zipPath];

            //解压缩成功
            if (result) {
                //删除zip
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:unzipPath error:nil];

                //开始渲染
                NSString *filePath = [NSString stringWithFormat:@"file://%@/%@/%@",zipPath,zipName,@"offline.html"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    JXBWebViewController *webVC = [[JXBWebViewController alloc] initWithURLString:filePath];
                    [self.navigationController pushViewController:webVC animated:YES];
                });
            }
        }else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请部署接口服务" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];

    [task resume];
}

- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr,(CC_LONG)strlen(cStr), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
